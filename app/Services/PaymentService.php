<?php

namespace App\Services;

use App\Models\Booking;
use App\Models\Payment;
use App\Mail\PaymentConfirmationMail;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\DB;
use Stripe\Stripe;
use Stripe\PaymentIntent;
use Exception;

class PaymentService
{
    public function processPayment(Booking $booking, array $data, $user)
    {
        if ($booking->status !== Booking::STATUS_PENDING) {
            throw new Exception(__('payments.already_paid'));
        }

        return DB::transaction(function () use ($booking, $data, $user) {

            // 1. اتصلي بـ Stripe
            Stripe::setApiKey(config('services.stripe.secret'));

            // 2. إنشاء PaymentIntent
            $intent = PaymentIntent::create([
                'amount'   => $booking->total_price * 100, // Stripe بيحسب بالسنتات
                'currency' => 'usd',
                'metadata' => [
                    'booking_id' => $booking->id,
                    'user_id'    => $user->id,
                ],
            ]);

            // 3. احفظي الدفع
            $payment = Payment::create([
                'booking_id'     => $booking->id,
                'user_id'        => $user->id,
                'amount'         => $booking->total_price,
                'payment_method' => $data['payment_method'],
                'status'         => 'success',
                'transaction_id' => $intent->id, // TXN حقيقي من Stripe
            ]);

            // 4. حدثي الحجز
            $booking->update([
                'status' => Booking::STATUS_CONFIRMED,
            ]);

            // 5. أرسلي إيميل التأكيد
            Mail::to($user->email)->send(new PaymentConfirmationMail($booking));

            return [
                'booking'        => $booking,
                'payment'        => $payment,
                'reference' => $booking->boarding_code,
                'client_secret'  => $intent->client_secret, // للموبايل
            ];
        });
    }
}
