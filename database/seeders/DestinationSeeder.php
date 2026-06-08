<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DestinationSeeder extends Seeder
{
    public function run(): void
    {
        // دبي
        $dubai = DB::table('destinations')->insertGetId([
            'name'            => 'Dubai',
            'country'         => 'UAE',
            'iata_code'       => 'DXB',
            'tagline'         => 'The city of the future',
            'description'     => 'A global city known for luxury, innovation, and record-breaking architecture.',
            'avg_temperature' => 34,
            'best_months'     => 'Sep,Oct,Nov,Mar,Apr',
            'is_popular'      => true,
            'created_at'      => now(),
            'updated_at'      => now(),
        ]);

        // Neighborhoods دبي
        $neighborhoods = [
            [
                'name'        => 'Dubai Marina',
                'tags'        => json_encode(['Luxury', 'Waterfront']),
                'description' => 'A stunning waterfront district with skyscrapers, restaurants, and a vibrant nightlife.',
            ],
            [
                'name'        => 'Old Deira',
                'tags'        => json_encode(['Heritage', 'Shopping']),
                'description' => 'The historic heart of Dubai with traditional souks and rich culture.',
            ],
            [
                'name'        => 'Jumeirah',
                'tags'        => json_encode(['Beach', 'Luxury', 'Family']),
                'description' => 'Upscale beachside neighbourhood famous for its white-sand beaches, luxury hotels, and the iconic sail-shaped Burj Al Arab.',
            ],
            [
                'name'        => 'Downtown Dubai',
                'tags'        => json_encode(['Luxury', 'Shopping', 'Family']),
                'description' => 'Home to Burj Khalifa, Dubai Mall, and the famous Dubai Fountain.',
            ],
        ];

        foreach ($neighborhoods as $n) {
            $neighborhoodId = DB::table('destination_neighborhoods')->insertGetId([
                'destination_id' => $dubai,
                'name'           => $n['name'],
                'tags'           => $n['tags'],
                'description'    => $n['description'],
                'created_at'     => now(),
                'updated_at'     => now(),
            ]);

            // Spots لكل Neighborhood
            $spots = match($n['name']) {
                'Jumeirah' => [
                    ['name' => 'Jumeirah Beach',    'subtitle' => 'Free public beach',              'icon' => '🏖️'],
                    ['name' => 'Burj Al Arab View', 'subtitle' => 'Iconic sail-shaped hotel',       'icon' => '🏨'],
                    ['name' => 'Jumeirah Mosque',   'subtitle' => 'Open to visitors · Tours daily', 'icon' => '🕌'],
                    ['name' => 'La Mer',            'subtitle' => 'Beachfront dining & shops',      'icon' => '🌊'],
                ],
                'Downtown Dubai' => [
                    ['name' => 'Burj Khalifa (Level 124)', 'subtitle' => 'Book tickets online to skip the queue', 'icon' => '🏙️'],
                    ['name' => 'Dubai Mall & Aquarium',    'subtitle' => 'The aquarium tunnel is free to walk through', 'icon' => '🐠'],
                    ['name' => 'Dubai Fountain Show',      'subtitle' => 'Best viewed from the waterfront promenade', 'icon' => '⛲'],
                    ['name' => 'Dinner at Souk Al Bahar',  'subtitle' => 'Great views of the lit-up Burj Khalifa', 'icon' => '🍽️'],
                ],
                'Dubai Marina' => [
                    ['name' => 'Marina Walk',     'subtitle' => 'Scenic waterfront promenade', 'icon' => '🚶'],
                    ['name' => 'Yacht Tours',     'subtitle' => 'Sunset cruises available',    'icon' => '⛵'],
                    ['name' => 'JBR Beach',       'subtitle' => 'Open beach with activities',  'icon' => '🏄'],
                    ['name' => 'The Beach Mall',  'subtitle' => 'Outdoor shopping & dining',   'icon' => '🛍️'],
                ],
                'Old Deira' => [
                    ['name' => 'Gold Souk',       'subtitle' => 'Largest gold market in the world', 'icon' => '💛'],
                    ['name' => 'Spice Souk',      'subtitle' => 'Traditional herbs and spices',     'icon' => '🌿'],
                    ['name' => 'Dubai Creek',     'subtitle' => 'Historic waterway & Abra rides',   'icon' => '🚤'],
                    ['name' => 'Al Fahidi Fort',  'subtitle' => 'Oldest building in Dubai',         'icon' => '🏰'],
                ],
                default => []
            };

            foreach ($spots as $spot) {
                DB::table('destination_spots')->insert([
                    'neighborhood_id' => $neighborhoodId,
                    'name'            => $spot['name'],
                    'subtitle'        => $spot['subtitle'],
                    'icon'            => $spot['icon'],
                    'created_at'      => now(),
                    'updated_at'      => now(),
                ]);
            }
        }

        $this->command->info('create successful');
    }
}
