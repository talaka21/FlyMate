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
        ['name' => 'Damascus International Airport',        'iata_code' => 'DAM', 'city' => 'Damascus',   'country' => 'Syria', 'terminals' => 1],
        ['name' => 'Bassel Al-Assad International Airport', 'iata_code' => 'LTK', 'city' => 'Latakia',    'country' => 'Syria', 'terminals' => 1],
        ['name' => 'Aleppo International Airport',          'iata_code' => 'ALP', 'city' => 'Aleppo',     'country' => 'Syria', 'terminals' => 1],
        ['name' => 'Deir ez-Zor Airport',                   'iata_code' => 'DEZ', 'city' => 'Deir ez-Zor','country' => 'Syria', 'terminals' => 1],
    ];

    foreach ($airports as $airport) {
        \App\Models\Airport::create($airport);
    }
}
}
