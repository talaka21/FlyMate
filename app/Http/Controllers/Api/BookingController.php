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
use App\Traits\ApiResponse;

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
    }
}
