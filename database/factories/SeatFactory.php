<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class SeatFactory extends Factory
{
    public function definition(): array
    {
        return [
            'flight_id'    => \App\Models\Flight::factory(),
            'seat_number'  => strtoupper(fake()->bothify('??##')),
            'class' => fake()->randomElement(['economy', 'business', 'first_class']),
            'is_available' => true,
        ];
    }
}
