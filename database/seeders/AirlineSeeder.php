<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Airline;

class AirlineSeeder extends Seeder
{
    public function run(): void
    {
        $airlines = [
            [
                'name'               => 'Qatar Airways',
                'code'               => 'QR',
                'hub_city'           => 'Doha',
                'tagline'            => "World's Best Airline",
                'baggage_kg'         => 30,
                'rating'             => 4.9,
                'destinations_count' => 170,
                'contact_info'       => 'info@qatarairways.com',
                'is_active'          => true,
                'facilities'         => ['30kg Baggage', 'Qmiles Program', 'Oryx Entertainment', 'Lounge Access']
            ],
            [
                'name'               => 'Turkish Airlines',
                'code'               => 'TK',
                'hub_city'           => 'Istanbul',
                'tagline'            => 'Star Alliance Member',
                'baggage_kg'         => 30,
                'rating'             => 4.5,
                'destinations_count' => 340,
                'contact_info'       => 'info@turkishairlines.com',
                'is_active'          => true,
                'facilities'         => ['30kg Baggage', 'Miles & Smiles', 'Lounge Access', 'Wi-Fi Available']
            ],
            [
                'name'               => 'Royal Jordanian',
                'code'               => 'RJ',
                'hub_city'           => 'Amman',
                'tagline'            => "Jordan's Official Carrier",
                'baggage_kg'         => 23,
                'rating'             => 4.1,
                'destinations_count' => 61,
                'contact_info'       => 'info@rj.com',
                'is_active'          => true,
                'facilities'         => ['23kg Baggage', 'Royal Plus Program', 'First Class Available', 'Onboard Meals']
            ],
            [
                'name'               => 'Syrian Airlines',
                'code'               => 'RB',
                'hub_city'           => 'Damascus',
                'tagline'            => 'National Carrier · Est. 1946',
                'baggage_kg'         => 23,
                'rating'             => 3.8,
                'destinations_count' => 18,
                'contact_info'       => 'info@syriaair.com',
                'is_active'          => true,
                'facilities'         => ['23kg Baggage', 'Free Meal', 'First Class Available', 'Airport Check-in']
            ],
            [
                'name'               => 'Flyadeal',
                'code'               => 'F3',
                'hub_city'           => 'Jeddah',
                'tagline'            => 'Saudi Low Cost',
                'baggage_kg'         => 23,
                'rating'             => 3.7,
                'destinations_count' => 25,
                'contact_info'       => 'info@flyadeal.com',
                'is_active'          => true,
                'facilities'         => ['23kg Baggage', 'Budget Friendly', 'Online Check-in', 'Onboard Purchase']
            ],
            [
                'name'               => 'Jazeera Airways',
                'code'               => 'J9',
                'hub_city'           => 'Kuwait',
                'tagline'            => 'Low Cost Carrier',
                'baggage_kg'         => 20,
                'rating'             => 3.9,
                'destinations_count' => 30,
                'contact_info'       => 'info@jazeeraairways.com',
                'is_active'          => true,
                'facilities'         => ['20kg Baggage', 'JazeeraPlus Program', 'Onboard Snacks', 'Online Check-in']
            ],
            [
                'name'               => 'FlyCham',
                'code'               => 'S8',
                'hub_city'           => 'Damascus',
                'tagline'            => 'Syrian Private',
                'baggage_kg'         => 20,
                'rating'             => 3.5,
                'destinations_count' => 12,
                'contact_info'       => 'info@flycham.com',
                'is_active'          => true,
                'facilities'         => ['20kg Baggage', 'Onboard Meals', 'Airport Check-in']
            ],
        ];

        foreach ($airlines as $airline) {
            Airline::create($airline);
        }
    }
}
