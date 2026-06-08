<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\RescheduleBookingRequest;
use App\Http\Requests\StoreBookingRequest;
use App\Http\Requests\UpgradeBookingRequest;
use App\Services\BookingService;
use App\Http\Resources\BookingResource;
use Illuminate\Http\Request;
use Exception;
use App\Models\Flight;
use App\Traits\ApiResponse;
use App\Models\Reward;
use App\Models\Booking;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Stripe\Stripe;
use Stripe\PaymentIntent;
use Stripe\Webhook;
use Illuminate\Support\Facades\Log;

class BookingController extends Controller
{
    use ApiResponse;

    protected $bookingService;

    public function __construct(BookingService $bookingService)
    {
        $this->bookingService = $bookingService;
    }

    /**
     * عرض جميع حجوزات المستخدم الحالي.
     */
    public function index(Request $request)
    {
        $bookings = $this->bookingService->getAllUserBookings($request->user()->id);

        // استخدام collection لأن النتائج عبارة عن قائمة
        return $this->success(BookingResource::collection($bookings));
    }

    /**
     * عرض تفاصيل حجز محدد.
     */
    public function show(Request $request, $id)
    {
        try {
            $booking = $request->user()->bookings()->with(['flight', 'seat'])->findOrFail($id);
            return $this->success(new BookingResource($booking));
        } catch (Exception $e) {
            return $this->error(__('bookings.not_found'), 404);
        }
    }

    /**
     * إنشاء حجز جديد (يدعم حجز عدة مقاعد بطلب واحد).
     */
    public function store(StoreBookingRequest $request)
    {
        try {
            $bookings = $this->bookingService->createBooking($request->validated(), $request->user());

            // نستخدم collection لعرض قائمة الحجوزات التي تمت بنجاح
            return $this->success(
                BookingResource::collection($bookings),
                __('bookings.created'),
                201
            );
        } catch (Exception $e) {
            return $this->error($e->getMessage());
        }
    }

    /**
     * إلغاء حجز.
     */
    public function cancel(Request $request, $id)
    {
        try {
            $booking = $request->user()->bookings()->findOrFail($id);
            $this->bookingService->cancelBooking($booking);
            return $this->success(null, __('bookings.cancelled'));
        } catch (Exception $e) {
            return $this->error($e->getMessage());
        }
    }

    /**
     * تعديل موعد حجز.
     */
    public function reschedule(RescheduleBookingRequest $request, $id)
    {
        try {
            $booking = $request->user()->bookings()->findOrFail($id);
            $result = $this->bookingService->rescheduleBooking($booking, $request->validated());
            return $this->success(new BookingResource($result), __('bookings.rescheduled'));
        } catch (Exception $e) {
            return $this->error($e->getMessage());
        }
    }

    /**
     * ترقية درجة الحجز.
     */
    public function upgrade(UpgradeBookingRequest $request, $id)
    {
        try {
            $booking = $request->user()->bookings()->findOrFail($id);
            $result = $this->bookingService->upgradeBooking($booking, $request->new_class);
            return $this->success(new BookingResource($result), __('bookings.upgraded'));
        } catch (Exception $e) {
            return $this->error($e->getMessage());
        }
    }

    /**
     * توليد وإرسال البوردينج باص عبر الإيميل.
     */
    public function generateBoardingPass(Request $request, $id)
    {
        try {
            $booking = $request->user()->bookings()->with(['flight', 'seat'])->findOrFail($id);

            $this->bookingService->sendBoardingPassEmail($booking);

            return $this->success(
                new BookingResource($booking),
                __('bookings.boarding_pass_ready')
            );
        } catch (Exception $e) {
            return $this->error($e->getMessage());
        }
    }public function createPaymentIntent(Request $request)
    {
        $request->validate([
            'flight_id' => 'required|exists:flights,id',
            'class'     => 'required|in:economy,business,first_class',
            'reward_id' => 'nullable|exists:rewards,id',
        ]);

        return DB::transaction(function () use ($request) {
            $user = User::where('id', $request->user()->id)->lockForUpdate()->first();
            $flight = Flight::findOrFail($request->flight_id);

            // جلب السعر ديناميكياً من خوارزمية اللحظة الأخيرة
            $flightPrice = $flight->getCurrentPrice($request->class);

            // 🛠️ حماية إضافية: إذا كانت خوارزمية السعر ترجع null أو 0 بسبب عدم تهيئة الجداول بالشكل الصحيح
            if (!$flightPrice || $flightPrice == 0) {
                $priceRecord = $flight->prices()->where('class', $request->class)->first();
                $flightPrice = $priceRecord ? $priceRecord->base_price : 249.00; // القيمة الاحتياطية الآمنة
            }

            $finalPrice = $flightPrice;
            $rewardApplied = null;

            if ($request->filled('reward_id')) {
                $reward = Reward::findOrFail($request->reward_id);
                if ($user->loyalty_points < $reward->points_cost) {
                    return response()->json(['status' => 'Error', 'message' => 'Insufficient points'], 400);
                }
                $user->decrement('loyalty_points', $reward->points_cost);
                $rewardApplied = $reward;
                if ($reward->type === 'ticket_discount') {
                    $finalPrice = $flightPrice - (($flightPrice * $reward->value) / 100);
                }
            }

            // 1. أولاً: إنشاء سجل الحجز الأولي بحالة معلقة
            $booking = Booking::create([
                'user_id'         => $user->id,
                'flight_id'       => $flight->id,
                'seat_class'      => $request->class,
                'total_price'     => $flightPrice,
                'paid_price'      => $finalPrice,
                'reward_id'       => $rewardApplied ? $rewardApplied->id : null,
                'status'          => Booking::STATUS_PENDING,
                'seat_id'         => 1, // رقم افتراضي للربط المؤقت
                'booking_type_id' => 1,
                'adult_count'     => 1,
                'child_count'     => 0,
                'infant_count'    => 0,
            ]);

            // 2. ثانياً: الاتصال بـ Stripe لتهيئة الدفع (تحويل القيمة لسنتات)
            Stripe::setApiKey(env('STRIPE_SECRET'));
            $paymentIntent = PaymentIntent::create([
                'amount'   => intval($finalPrice * 100),
                'currency' => 'usd',
                'automatic_payment_methods' => [
                    'enabled'         => true,
                    'allow_redirects' => 'never',
                ],
                'metadata' => [
                    'booking_id' => $booking->id,
                ]
            ]);

            return response()->json([
                'status'        => 'Success',
                'client_secret' => $paymentIntent->client_secret,
                'booking_id'    => $booking->id,
            ]);
        });
    }

    /**
     * استقبال التحديثات من سيرفرات Stripe لحفظ حالة الدفع وإضافة نقاط الولاء.
     */
   public function handleStripeWebhook(Request $request)
{
    try {
        $payload = $request->getContent();

        // ❌ علّقي هدول الأسطر مؤقتاً عشان الفحص اليدوي بالبوست مان:
        $sigHeader = $request->header('Stripe-Signature');
        $endpointSecret = env('STRIPE_WEBHOOK_SECRET');
        $event = \Stripe\Webhook::constructEvent($payload, $sigHeader, $endpointSecret);

        $event = json_decode($payload);

        if ($event->type === 'payment_intent.succeeded') {
            $paymentIntent = $event->data->object;
            $bookingId = $paymentIntent->metadata->booking_id ?? null;

            Log::info('Webhook Booking ID:', ['id' => $bookingId]);

            if (!$bookingId) {
                return response()->json(['error' => 'No booking_id in metadata'], 400);
            }

            $booking = \App\Models\Booking::with('user')->find($bookingId);

            if ($booking) {
                $booking->update([
                    'status' => 'confirmed',
                    'stripe_payment_id' => $paymentIntent->id,
                ]);

                // حساب النقاط: 249 تقسيم 10 = 24 نقطة
                $pointsEarned = intval($booking->paid_price / 10);
                if ($pointsEarned > 0) {
                    $booking->user->increment('loyalty_points', $pointsEarned);
                    Log::info("Points added: {$pointsEarned} to user {$booking->user->id}");
                }

                Log::info('Booking confirmed: ' . $bookingId);
            }
        }

        return response()->json(['status' => 'success']);

    } catch (\Exception $e) {
        Log::error('Webhook Error: ' . $e->getMessage());
        return response()->json(['error' => $e->getMessage()], 500);
    }
}
}

