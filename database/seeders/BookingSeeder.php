<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Booking;
use App\Models\Flight;
use App\Models\User;
use App\Models\Seat;
use App\Models\BookingType;

class BookingSeeder extends Seeder
{
    public function run(): void
    {
        // 1. جلب بيانات أساسية للربط
        $user = User::first() ?? User::factory()->create(['name' => 'Sara Hassan']);
        $flight = Flight::where('flight_number', 'RJ101')->first();
        $bookingType = BookingType::first() ?? BookingType::create(['name' => 'Online Booking']);

        if ($flight) {
            // 2. جلب أول مقعد متاح في هذه الرحلة
            $seat = Seat::where('flight_id', $flight->id)
                        ->where('is_available', true)
                        ->first();

            if ($seat) {
                // 3. إنشاء الحجز
            // داخل BookingSeeder.php
Booking::create([
    'user_id'         => $user->id,
    'flight_id'       => $flight->id,
    'seat_id'         => $seat->id,
    'booking_type_id' => $bookingType->id,
    'seat_class'      => $seat->class,
    'status'          => Booking::STATUS_CONFIRMED,
    'total_price'     => 250.00,
    'boarding_code'   => 'FM-' . strtoupper(\Illuminate\Support\Str::random(8)), // الحل المضمون للسيدر
]);

                // 4. تحديث حالة المقعد ليصبح غير متاح
                $seat->update(['is_available' => false]);
            }
        }
    }
}
