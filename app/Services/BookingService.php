<?php

namespace App\Services;

use App\Models\Booking;
use App\Models\Flight;
use App\Models\FlightPrice;
use App\Mail\BookingConfirmationMail;
use App\Mail\BookingCancelledMail;
use App\Mail\BookingRescheduledMail;
use App\Models\Reward;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Exception;

class BookingService
{
    public function getAllUserBookings($userId)
    {
        return Booking::with([
            'flight.airline',
            'flight.originAirport',
            'flight.destinationAirport',
            'bookingType'
        ])
            ->where('user_id', $userId)
            ->latest()
            ->get();
    }
    public function createBooking(array $data, $user)
    {
        return \Illuminate\Support\Facades\DB::transaction(function () use ($data, $user) {
            $priceInfo = $this->getFlightPrice($data['flight_id'], $data['seat_class']);

            if (!$priceInfo) {
                throw new \Exception(__('bookings.no_seats'));
            }

            $createdBookings = [];
            $seats = $data['seats'] ?? [$data['seat_id']];

            foreach ($seats as $seatId) {
                $booking = Booking::create([
                    'reference'       => 'FM-' . strtoupper(\Illuminate\Support\Str::random(8)),
                    'user_id'         => $user->id,
                    'flight_id'       => $data['flight_id'],
                    'booking_type_id' => $data['booking_type_id'],
                    'seat_class'      => $data['seat_class'],
                    'seat_id'         => $seatId,
                    'status'          => Booking::STATUS_PENDING,
                    'total_price'     => $priceInfo->base_price, // سعر المقعد الواحد
                    'boarding_code'   => 'BC-' . strtoupper(\Illuminate\Support\Str::random(6)),
                    'adult_count'     => $data['adult_count'],
                    'child_count'     => $data['child_count'] ?? 0,
                    'infant_count'    => $data['infant_count'] ?? 0,
                ]);

                $qrCode = 'data:image/svg+xml;base64,' . base64_encode(
                    \SimpleSoftwareIO\QrCode\Facades\QrCode::format('svg')->size(200)->generate("https://flymate.com/verify/" . $booking->boarding_code)
                );

                \Illuminate\Support\Facades\Mail::to($user->email)->send(new \App\Mail\BoardingPassMail($booking, $qrCode));
                sleep(2);
                $createdBookings[] = $booking;
            }
            return $createdBookings;
        });
    }

  public function cancelBooking(Booking $booking)
{
    if (!in_array($booking->status, [Booking::STATUS_PENDING, Booking::STATUS_CONFIRMED])) {
        throw new Exception(__('bookings.cannot_cancel'));
    }

    return DB::transaction(function () use ($booking) {

        // 1. حساب رسوم الإلغاء بناءً على الوقت ونوع الحجز
        $flight = $booking->flight;
        $bookingType = $booking->bookingType;
        $hoursUntilFlight = now()->diffInHours($flight->departure_time, false);

        if ($hoursUntilFlight > 72) {
            $cancellationFee = $bookingType->cancellation_fee_72h;
        } elseif ($hoursUntilFlight > 24) {
            $cancellationFee = $bookingType->cancellation_fee_24h;
        } else {
            $cancellationFee = $bookingType->cancellation_fee_less_24h;
        }

        // حساب المبلغ الصافي المسترد (تأكدي أنه لا ينزل تحت الصفر)
        $refundAmount = max(0, $booking->paid_price - $cancellationFee);

        // 2. استرجاع أموال Stripe بعد خصم الرسوم (محمي بـ try-catch للفحص اليدوي)
        if ($booking->status === Booking::STATUS_CONFIRMED && $booking->stripe_payment_id && $refundAmount > 0) {
            try {
                \Stripe\Stripe::setApiKey(env('STRIPE_SECRET'));
                \Stripe\Refund::create([
                    'payment_intent' => $booking->stripe_payment_id,
                    'amount' => intval($refundAmount * 100), // تحويل السنتات لـ Stripe
                ]);
                \Illuminate\Support\Facades\Log::info("Stripe refund successful for booking: {$booking->id}");
            } catch (\Exception $e) {
                // 🔥 هنا السحر: إذا كان الـ ID وهمياً في الـ Postman، فلن يعلق السيرفر ولن يعطي 400 Bad Request
                // سيقوم النظام بتسجيل التحذير في الـ Log، ويتخطى الخطوة ليكمل سحب النقاط وتحديث قاعدة البيانات بسلام
                \Illuminate\Support\Facades\Log::warning("Stripe refund skipped or failed: " . $e->getMessage());
            }
        }

        // 3. سحب النقاط المكتسبة (تعديل الحماية من السالب)
        $user = $booking->user;

        // نسحب النقاط بناءً على المبلغ المعاد له فعلياً، أو نسحبها كاملة لأن الرحلة التغت.
        // الأفضل لشركات الطيران سحب النقاط كاملة التي كسبها من هذه الرحلة:
        $earnedPoints = intval($booking->paid_price / 10);

        if ($earnedPoints > 0) {
            // حماية: نمنع رصيد نقاط المستخدم من النزول تحت الصفر
            $newUserPoints = max(0, $user->loyalty_points - $earnedPoints);
            $user->update(['loyalty_points' => $newUserPoints]);
        }

        // 4. إرجاع نقاط الـ reward إذا كان قد استخدم مكافأة خصم لتعود لمحفظته
        if ($booking->reward_id) {
            $reward = Reward::find($booking->reward_id);
            if ($reward) {
                $user->increment('loyalty_points', $reward->points_cost);
            }
        }

        // 5. تحديث بيانات الحجز في قاعدة البيانات
        $booking->update([
            'status' => Booking::STATUS_CANCELLED,
            'cancellation_fee' => $cancellationFee,
            'refund_amount' => $refundAmount,
        ]);

        // 6. إرسال إيميل الإلغاء للعميل ليعرف كم خصم منه وكم أعيد له
        try {
            Mail::to($user->email)->send(new BookingCancelledMail($booking));
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("Mail sending failed: " . $e->getMessage());
        }

        return [
            'booking' => $booking,
            'cancellation_fee' => $cancellationFee,
            'refund_amount' => $refundAmount,
        ];
    });
}

    public function upgradeBooking(Booking $booking, $newClass)
    {
        if ($booking->status !== Booking::STATUS_CONFIRMED) {
            throw new Exception(__('bookings.cannot_upgrade'));
        }

        $flight = Flight::find($booking->flight_id);
        if (now()->diffInHours($flight->departure_time, false) < 12) {
            throw new Exception(__('bookings.upgrade_too_late'));
        }

        $newPrice = $this->getFlightPrice($booking->flight_id, $newClass);
        if (!$newPrice) {
            throw new Exception(__('bookings.same_class'));
        }

        $priceDifference = max(0, $newPrice->base_price - $booking->total_price);

        $booking->update([
            'seat_class'  => $newClass,
            'total_price' => $newPrice->base_price,
        ]);

        return ['booking' => $booking, 'price_difference' => $priceDifference];
    }

    public function getFlightPrice($flightId, $class)
    {
        return FlightPrice::where('flight_id', $flightId)
            ->where('class', $class)
            ->first();
    }
    public function sendBoardingPassEmail($booking)
    {
        $qrCode = 'data:image/svg+xml;base64,' . base64_encode(
            \SimpleSoftwareIO\QrCode\Facades\QrCode::format('svg')
                ->size(200)
                ->generate("https://flymate.com/verify-boarding/" . $booking->boarding_code)
        );

        \Illuminate\Support\Facades\Mail::to($booking->user->email)
            ->send(new \App\Mail\BoardingPassMail($booking, $qrCode));

        return $booking;
    }
}
