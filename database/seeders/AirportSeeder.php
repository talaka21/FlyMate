<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class AirportSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $airports = [
        ['name' => 'Queen Alia International Airport', 'iata_code' => 'AMM', 'city' => 'Amman',  'country' => 'Jordan', 'terminals' => 2],
        ['name' => 'Dubai International Airport',      'iata_code' => 'DXB', 'city' => 'Dubai',  'country' => 'UAE',    'terminals' => 3],
        ['name' => 'Doha Hamad International Airport', 'iata_code' => 'DOH', 'city' => 'Doha',   'country' => 'Qatar',  'terminals' => 1],
        ['name' => 'Cairo International Airport',      'iata_code' => 'CAI', 'city' => 'Cairo',  'country' => 'Egypt',  'terminals' => 3],
        ['name' => 'Beirut Rafic Hariri Airport',      'iata_code' => 'BEY', 'city' => 'Beirut', 'country' => 'Lebanon','terminals' => 1],
    ];

    foreach ($airports as $airport) {
        \App\Models\Airport::create($airport);
    }
    }
}
