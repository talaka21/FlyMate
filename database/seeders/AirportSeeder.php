<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Airport;

class AirportSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $airports = [
            // 🇸🇾 المطارات السورية (الداخلية الثابتة عندكِ)
            ['name' => 'Damascus International Airport',        'iata_code' => 'DAM', 'city' => 'Damascus',   'country' => 'Syria', 'terminals' => 1],
            ['name' => 'Bassel Al-Assad International Airport', 'iata_code' => 'LTK', 'city' => 'Latakia',    'country' => 'Syria', 'terminals' => 1],
            ['name' => 'Aleppo International Airport',          'iata_code' => 'ALP', 'city' => 'Aleppo',     'country' => 'Syria', 'terminals' => 1],
            ['name' => 'Deir ez-Zor Airport',                   'iata_code' => 'DEZ', 'city' => 'Deir ez-Zor','country' => 'Syria', 'terminals' => 1],

            // ✈️ المطارات الخارجية المطابقة تماماً لشركات الطيران اللي عندكِ (Hub Cities)
            [
                'name' => 'Hamad International Airport',
                'iata_code' => 'DOH',
                'city' => 'Doha',
                'country' => 'Qatar',
                'terminals' => 1
            ], // مطابقة لـ Qatar Airways
            [
                'name' => 'Istanbul Airport',
                'iata_code' => 'IST',
                'city' => 'Istanbul',
                'country' => 'Turkey',
                'terminals' => 1
            ], // مطابقة لـ Turkish Airlines
            [
                'name' => 'Queen Alia International Airport',
                'iata_code' => 'AMM',
                'city' => 'Amman',
                'country' => 'Jordan',
                'terminals' => 2
            ], // مطابقة لـ Royal Jordanian وبوست مان
            [
                'name' => 'King Abdulaziz International Airport',
                'iata_code' => 'JED',
                'city' => 'Jeddah',
                'country' => 'Saudi Arabia', 'terminals' => 3
            ], // مطابقة لـ Flyadeal (Jeddah)
            [
                'name' => 'Kuwait International Airport',
                'iata_code' => 'KWI',
                'city' => 'Kuwait',
                'country' => 'Kuwait',
                'terminals' => 2
            ], // مطابقة لـ Jazeera Airways
        ];

        foreach ($airports as $airport) {
            Airport::create($airport);
        }
    }
}
