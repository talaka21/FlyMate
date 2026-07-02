<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class AirportFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name'      => fake()->city() . ' International Airport',
            'iata_code' => strtoupper(fake()->unique()->lexify('???')),
            'city'      => fake()->city(),
            'country'   => fake()->country(),
        ];
    }
}
