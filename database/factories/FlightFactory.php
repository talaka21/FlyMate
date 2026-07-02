<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class FlightFactory extends Factory
{
    public function definition(): array
    {
        return [
            'flight_number'          => strtoupper(fake()->bothify('FM###')),
            'airline_id'             => \App\Models\Airline::factory(),
            'origin_airport_id'      => \App\Models\Airport::factory(),
            'destination_airport_id' => \App\Models\Airport::factory(),
            'departure_at'           => now()->addDays(3),
            'arrival_at'             => now()->addDays(3)->addHours(3),
            'aircraft_type'          => fake()->randomElement(['Boeing 737', 'Airbus A320', 'Boeing 777']),
            'total_seats'            => 180,
            'available_seats'        => 180,
            'status' => 'on_time',
        ];
    }
}
