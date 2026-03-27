<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class AirlineSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
       $airlines = [
        ['name' => 'Royal Jordanian', 'code' => 'RJ', 'contact_info' => 'info@rj.com', 'is_active' => true],
        ['name' => 'Emirates',        'code' => 'EK', 'contact_info' => 'info@emirates.com', 'is_active' => true],
        ['name' => 'Qatar Airways',   'code' => 'QR', 'contact_info' => 'info@qatar.com', 'is_active' => true],
        ['name' => 'Air Arabia',      'code' => 'G9', 'contact_info' => 'info@airarabia.com', 'is_active' => true],
        ['name' => 'Flydubai',        'code' => 'FZ', 'contact_info' => 'info@flydubai.com', 'is_active' => false],
    ];

    foreach ($airlines as $airline) {
        \App\Models\Airline::create($airline);
    }
    }
}
