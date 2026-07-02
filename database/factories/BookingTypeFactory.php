<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class BookingTypeFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name'                     => 'Economy Flex',
            'type'                     => 'one_way',
            'cancellation_fee_72h'     => 0,
            'cancellation_fee_24h'     => 20,
            'cancellation_fee_less_24h'=> 50,
            'baggage_allowance'        => 23,
            'is_active'                => true,
        ];
    }
}
