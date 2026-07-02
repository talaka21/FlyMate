<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class BookingFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id'         => \App\Models\User::factory(),
            'flight_id'       => \App\Models\Flight::factory(),
            'seat_id'         => \App\Models\Seat::factory(),
            'booking_type_id' => \App\Models\BookingType::factory(),
            'seat_class'      => 'economy',
            'status'          => 'pending',
            'adult_count'     => 1,
            'child_count'     => 0,
            'infant_count'    => 0,
            'total_price'     => 200.00,
            'paid_price'      => 0,
        ];
    }
}
