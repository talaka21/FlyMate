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
                'name'               => 'Emirates',
                'code'               => 'EK',
                'hub_city'           => 'Dubai',
                'tagline'            => 'Largest ME Carrier',
                'baggage_kg'         => 35,
                'rating'             => 4.8,
                'destinations_count' => 230,
                'has_wifi'           => true,
                'has_lounge'         => true,
                'has_meals'          => true,
                'has_entertainment'  => true,
                'contact_info'       => 'info@emirates.com',
                'is_active'          => true,
            ],
            [
                'name'               => 'Royal Jordanian',
                'code'               => 'RJ',
                'hub_city'           => 'Amman',
                'tagline'            => "Jordan's Official Carrier",
                'baggage_kg'         => 23,
                'rating'             => 4.1,
                'destinations_count' => 61,
                'has_wifi'           => false,
                'has_lounge'         => false,
                'has_meals'          => true,
                'has_entertainment'  => false,
                'contact_info'       => 'info@rj.com',
                'is_active'          => true,
            ],
            [
                'name'               => 'Syrian Airlines',
                'code'               => 'RB',
                'hub_city'           => 'Damascus',
                'tagline'            => 'National Carrier · Est. 1946',
                'baggage_kg'         => 23,
                'rating'             => 3.8,
                'destinations_count' => 18,
                'has_wifi'           => false,
                'has_lounge'         => false,
                'has_meals'          => true,
                'has_entertainment'  => false,
                'contact_info'       => 'info@syriaair.com',
                'is_active'          => true,
            ],
            [
                'name'               => 'Flyadeal',
                'code'               => 'F3',
                'hub_city'           => 'Jeddah',
                'tagline'            => 'Saudi Low Cost',
                'baggage_kg'         => 23,
                'rating'             => 3.7,
                'destinations_count' => 25,
                'has_wifi'           => false,
                'has_lounge'         => false,
                'has_meals'          => false,
                'has_entertainment'  => false,
                'contact_info'       => 'info@flyadeal.com',
                'is_active'          => true,
            ],
            [
                'name'               => 'Turkish Airlines',
                'code'               => 'TK',
                'hub_city'           => 'Istanbul',
                'tagline'            => 'Star Alliance Member',
                'baggage_kg'         => 30,
                'rating'             => 4.5,
                'destinations_count' => 340,
                'has_wifi'           => true,
                'has_lounge'         => true,
                'has_meals'          => true,
                'has_entertainment'  => false,
                'contact_info'       => 'info@turkishairlines.com',
                'is_active'          => true,
            ],
            [
                'name'               => 'Qatar Airways',
                'code'               => 'QR',
                'hub_city'           => 'Doha',
                'tagline'            => "World's Best Airline",
                'baggage_kg'         => 30,
                'rating'             => 4.9,
                'destinations_count' => 170,
                'has_wifi'           => true,
                'has_lounge'         => true,
                'has_meals'          => true,
                'has_entertainment'  => true,
                'contact_info'       => 'info@qatarairways.com',
                'is_active'          => true,
            ],
            [
                'name'               => 'Jazeera Airways',
                'code'               => 'J9',
                'hub_city'           => 'Kuwait',
                'tagline'            => 'Low Cost Carrier',
                'baggage_kg'         => 20,
                'rating'             => 3.9,
                'destinations_count' => 30,
                'has_wifi'           => false,
                'has_lounge'         => false,
                'has_meals'          => false,
                'has_entertainment'  => false,
                'contact_info'       => 'info@jazeeraairways.com',
                'is_active'          => true,
            ],
            [
                'name'               => 'FlyCham',
                'code'               => 'S8',
                'hub_city'           => 'Damascus',
                'tagline'            => 'Syrian Private',
                'baggage_kg'         => 20,
                'rating'             => 3.5,
                'destinations_count' => 12,
                'has_wifi'           => false,
                'has_lounge'         => false,
                'has_meals'          => true,
                'has_entertainment'  => false,
                'contact_info'       => 'info@flycham.com',
                'is_active'          => true,
            ],
        ];

        foreach ($airlines as $airline) {
            Airline::create($airline);
        }
    }
}
