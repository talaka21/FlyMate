<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class PaymentFactory extends Factory
{
    public function definition(): array
    {
        return [
            'booking_id'     => \App\Models\Booking::factory(),
            'user_id'        => \App\Models\User::factory(),
            'amount'         => 200.00,
            'payment_method' => 'credit_card',
            'status'         => 'success',
            'transaction_id' => fake()->uuid(),
        ];
    }
}
