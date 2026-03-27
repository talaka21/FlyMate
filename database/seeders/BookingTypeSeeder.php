<?php

namespace Database\Seeders;

use App\Models\BookingType;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class BookingTypeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $types = [
            [
                'name'                      => 'One Way',
                'type'                      => 'one_way',
                'cancellation_fee_72h'      => 0,
                'cancellation_fee_24h'      => 20,
                'cancellation_fee_less_24h' => 50,
                'baggage_allowance'         => 23,
                'is_active'                 => true,
            ],
            [
                'name'                      => 'Round Trip',
                'type'                      => 'round_trip',
                'cancellation_fee_72h'      => 0,
                'cancellation_fee_24h'      => 15,
                'cancellation_fee_less_24h' => 40,
                'baggage_allowance'         => 23,
                'is_active'                 => true,
            ],
            [
                'name'                      => 'Multi City',
                'type'                      => 'multi_city',
                'cancellation_fee_72h'      => 10,
                'cancellation_fee_24h'      => 25,
                'cancellation_fee_less_24h' => 60,
                'baggage_allowance'         => 30,
                'is_active'                 => true,
            ],
        ];

        foreach ($types as $type) {
            BookingType::create($type);
        }
    }
    }

