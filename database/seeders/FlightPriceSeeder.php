<?php

namespace Database\Seeders;

use App\Models\FlightPrice;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class FlightPriceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
         $prices = [
            // Flight 1 - RJ101
            ['flight_id' => 1, 'class' => 'economy',     'base_price' => 150, 'min_price' => 120, 'max_price' => 200],
            ['flight_id' => 1, 'class' => 'business',    'base_price' => 350, 'min_price' => 300, 'max_price' => 450],
            ['flight_id' => 1, 'class' => 'first_class', 'base_price' => 600, 'min_price' => 500, 'max_price' => 800],

            // Flight 2 - EK202
            ['flight_id' => 2, 'class' => 'economy',     'base_price' => 200, 'min_price' => 180, 'max_price' => 280],
            ['flight_id' => 2, 'class' => 'business',    'base_price' => 500, 'min_price' => 450, 'max_price' => 650],
            ['flight_id' => 2, 'class' => 'first_class', 'base_price' => 900, 'min_price' => 800, 'max_price' => 1200],

            // Flight 3 - QR303
            ['flight_id' => 3, 'class' => 'economy',     'base_price' => 180, 'min_price' => 150, 'max_price' => 250],
            ['flight_id' => 3, 'class' => 'business',    'base_price' => 420, 'min_price' => 380, 'max_price' => 550],
            ['flight_id' => 3, 'class' => 'first_class', 'base_price' => 750, 'min_price' => 650, 'max_price' => 950],
        ];

        foreach ($prices as $price) {
            FlightPrice::create($price);
        }
    }
}
