<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Booking;
use App\Models\Flight;
use App\Models\User;
use App\Models\Seat;
use App\Models\BookingType;
use App\Models\Payment;
use Carbon\Carbon;
use Illuminate\Support\Str;

class BookingSeeder extends Seeder
{
    public function run(): void
    {
        $bookingType = BookingType::first() ?? BookingType::create(['name' => 'Online Booking']);

        $users = User::where('role', 'passenger')->get();
        if ($users->isEmpty()) {
            $users = User::factory()->count(10)->create(['role' => 'passenger']);
        }

        $flights = Flight::take(30)->get();

        if ($flights->isEmpty()) {
            $this->command->warn('No flights found!');
            return;
        }

        $count = 0;
        $currentYear = 2026;

        for ($month = 1; $month <= 12; $month++) {

            // 👇 تم تقليل عدد الحجوزات في الشهر لتبدو لوحة التحكم هادئة وأقل ازدحاماً
            $monthlyBookingsCount = rand(2, 5);

            for ($i = 0; $i < $monthlyBookingsCount; $i++) {
                $flight = $flights->random();
                $seat = Seat::where('flight_id', $flight->id)->where('is_available', true)->first();

                if (!$seat) {
                    continue;
                }

                $bookingDate = Carbon::create($currentYear, $month, rand(1, 28), rand(8, 22), rand(0, 59));

                // 👇 تم تصغير أسعار الرحلات هنا لخفض إجمالي الـ Revenue العام
                $price = rand(60, 140);
                $randomUser = $users->random();

                $booking = Booking::create([
                    'user_id'         => $randomUser->id,
                    'flight_id'       => $flight->id,
                    'seat_id'         => $seat->id,
                    'booking_type_id' => $bookingType->id,
                    'seat_class'      => $seat->class,
                    'status'          => Booking::STATUS_CONFIRMED,
                    'total_price'     => $price . '.00',
                    'paid_price'      => $price . '.00',
                    'boarding_code'   => 'FM-' . strtoupper(Str::random(8)),
                    'created_at'      => $bookingDate,
                    'updated_at'      => $bookingDate,
                ]);

                Payment::create([
                    'booking_id'     => $booking->id,
                    'user_id'        => $randomUser->id,
                    'amount'         => $price . '.00',
                    'payment_method' => 'credit_card',
                    'status'         => 'success',
                    'transaction_id' => 'ch_' . Str::random(24),
                    'created_at'     => $bookingDate,
                    'updated_at'     => $bookingDate,
                ]);

                $seat->update(['is_available' => false]);
                $count++;
            }
        }

        $this->command->info("Successfully created {$count} clean, lower-scale bookings!");
    }
}
