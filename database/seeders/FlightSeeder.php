<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class FlightSeeder extends Seeder
{
    public function run(): void
    {
        // 1. جلب مطار دمشق الدولي حصراً ليكون المحور (Hub)
        $damascusAirport = DB::table('airports')->where('iata_code', 'DAM')->first();

        // 2. جلب باقي المطارات الدولية (دبي، القاهرة، إسطنبول، بيروت...)
        $internationalAirports = DB::table('airports')->where('iata_code', '!=', 'DAM')->get();

        // 3. جلب جميع شركات الطيران المتاحة (سواء قطرية، تركية، أو سورية)
        $airlines = DB::table('airlines')->pluck('id')->toArray();

        if (!$damascusAirport || $internationalAirports->isEmpty() || empty($airlines)) {
            $this->command->warn('Ensure Damascus airport (DAM), international airports, and airlines exist in database!');
            return;
        }

        $days = 7;
        $classes = ['economy', 'business', 'first_class'];

        // توليد الرحلات: كل رحلة يجب أن تكون إما مغادرة من دمشق أو قادمة إلى دمشق
        foreach ($internationalAirports as $airport) {

            for ($day = 0; $day < $days; $day++) {

                // --- (النوع الأول: رحلة مغادرة من دمشق إلى الخارج) ---
                $this->createFlightPair($damascusAirport, $airport, $airlines, $classes, $day);

                // --- (النوع الثاني: رحلة قادمة من الخارج إلى دمشق) ---
                $this->createFlightPair($airport, $damascusAirport, $airlines, $classes, $day);
            }
        }

        $this->command->info('Perfect! All flights are strictly connected to Damascus International Airport.');
    }

    // تابع مساعد لتوليد بيانات الرحلة والأسعار والمقاعد لمنع تكرار الكود
    private function createFlightPair($origin, $destination, $airlines, $classes, $day): void
    {
        $departureAt = Carbon::now()->addHours(10 + ($day * 24))->setMinute(rand(0, 5) * 12);
        $arrivalAt = $departureAt->copy()->addHours(rand(2, 5)); // مدة الطيران الدولية من 2 إلى 5 ساعات
        $originCode = $origin->iata_code ?? substr($origin->name, 0, 3);

        $flightId = DB::table('flights')->insertGetId([
            'flight_number'          => strtoupper($originCode) . '-' . $destination->id . '-' . $departureAt->format('Ymd') . '-' . rand(100, 999),
            'airline_id'             => $airlines[array_rand($airlines)], // اختيار شركة طيران عشوائية (قطرية، تركية، سورية...)
            'origin_airport_id'      => $origin->id,
            'destination_airport_id' => $destination->id,
            'departure_at'           => $departureAt,
            'arrival_at'             => $arrivalAt,
            'aircraft_type'          => 'Boeing 737-800',
            'total_seats'            => 150,
            'available_seats'        => 150,
            'frequency'              => 'daily',
            'status'                 => 'on_time',
            'created_at'             => now(),
            'updated_at'             => now(),
        ]);

        // إدخال أسعار عشوائية متناسقة مع الرحلات الدولية
        $priceEconomy  = rand(150, 300);
        $priceBusiness = $priceEconomy + rand(200, 350);
        $priceFirst    = $priceBusiness + rand(400, 600);

        DB::table('flight_prices')->insert([
            ['flight_id' => $flightId, 'class' => 'economy', 'base_price' => $priceEconomy, 'created_at' => now(), 'updated_at' => now()],
            ['flight_id' => $flightId, 'class' => 'business', 'base_price' => $priceBusiness, 'created_at' => now(), 'updated_at' => now()],
            ['flight_id' => $flightId, 'class' => 'first_class', 'base_price' => $priceFirst, 'created_at' => now(), 'updated_at' => now()],
        ]);

        // إنشاء المقاعد
        $seatCounter = 1;
        foreach ($classes as $class) {
            $seatsToCreate = ($class === 'economy') ? 10 : (($class === 'business') ? 4 : 2);
            for ($i = 0; $i < $seatsToCreate; $i++) {
                DB::table('seats')->insert([
                    'flight_id'    => $flightId,
                    'seat_number'  => strtoupper(substr($class, 0, 1)) . $seatCounter++,
                    'class'        => $class,
                    'is_available' => rand(0, 1),
                    'created_at'   => now(),
                    'updated_at'   => now(),
                ]);
            }
        }
    }
}
