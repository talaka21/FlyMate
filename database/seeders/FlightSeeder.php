<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class FlightSeeder extends Seeder
{
    public function run(): void
    {
        // 1. تحديد الأكواد الصارمة للمطارات السورية (المطارات الداخلية)
        $syrianCodes = ['DAM', 'ALP', 'LTK', 'DEZ'];

        // 2. جلب المطارات السورية فقط (لتكون هي نقطة الانطلاق دائماً)
        $syrianAirports = DB::table('airports')
            ->whereIn('iata_code', $syrianCodes)
            ->get();

        // 3. جلب المطارات الدولية الخارجية (لتكون هي وجهة الهبوط دائماً)
        $internationalAirports = DB::table('airports')
            ->whereNotIn('iata_code', $syrianCodes)
            ->get();

        // 4. جلب شركات الطيران المتاحة
        $airlines = DB::table('airlines')->pluck('id')->toArray();

        // فحص أمان للتأكد من وجود البيانات
        if ($syrianAirports->isEmpty() || $internationalAirports->isEmpty() || empty($airlines)) {
            $this->command->warn('Warning: Make sure you have both Syrian airports and International airports in your AirportSeeder!');
            return;
        }

        $days = 7;
        $classes = ['economy', 'business', 'first_class'];

        // 🔥 الربط الموجه الصارم الجديد: من (مطار داخلي سوري) إلى (مطار خارجي دولي) فقط!
        foreach ($syrianAirports as $syrianAirport) {
            foreach ($internationalAirports as $internationalAirport) {

                for ($day = 0; $day < $days; $day++) {

                    // ✅ رحلة مغادرة فقط: من مطار سوري إلى مطار دولي خارج سوريا
                    $this->createFlightPair($syrianAirport, $internationalAirport, $airlines, $classes, $day);

                    // ❌ تم حذف سطر توليد الرحلات القادمة (من برا لجوا) بناءً على طلبكِ
                }
            }
        }

        $this->command->info('Success! Flights can ONLY depart from Syrian internal airports to the outside world.');
    }

    // التابع المساعد لتوليد البيانات والأسعار والمقاعد
    private function createFlightPair($origin, $destination, $airlines, $classes, $day): void
    {
        $departureAt = Carbon::now()->addHours(10 + ($day * 24))->setMinute(rand(0, 5) * 12);
        $arrivalAt = $departureAt->copy()->addHours(rand(2, 5));
        $originCode = $origin->iata_code ?? substr($origin->name, 0, 3);

        $flightId = DB::table('flights')->insertGetId([
            'flight_number'          => strtoupper($originCode) . '-' . $destination->id . '-' . $departureAt->format('Ymd') . '-' . rand(100, 999),
            'airline_id'             => $airlines[array_rand($airlines)],
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

        $priceEconomy  = rand(150, 300);
        $priceBusiness = $priceEconomy + rand(200, 350);
        $priceFirst    = $priceBusiness + rand(400, 600);

        DB::table('flight_prices')->insert([
            ['flight_id' => $flightId, 'class' => 'economy', 'base_price' => $priceEconomy, 'created_at' => now(), 'updated_at' => now()],
            ['flight_id' => $flightId, 'class' => 'business', 'base_price' => $priceBusiness, 'created_at' => now(), 'updated_at' => now()],
            ['flight_id' => $flightId, 'class' => 'first_class', 'base_price' => $priceFirst, 'created_at' => now(), 'updated_at' => now()],
        ]);

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
