<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Flight;
use Illuminate\Support\Facades\DB;

class FlightSeeder extends Seeder
{
    public function run(): void
    {
        $flights = [
            [
                'flight_number'          => 'RJ101',
                'airline_id'             => 1,
                'origin_airport_id'      => 1,
                'destination_airport_id' => 2,
                'departure_at'           => '2026-03-26 08:00:00',
                'arrival_at'             => '2026-03-26 11:00:00',
                'aircraft_type'          => 'Boeing 787',
                'total_seats'            => 200,
                'status'                 => 'on_time',
            ],
            [
                'flight_number'          => 'EK202',
                'airline_id'             => 2,
                'origin_airport_id'      => 2,
                'destination_airport_id' => 3,
                'departure_at'           => '2026-03-26 10:00:00',
                'arrival_at'             => '2026-03-26 11:30:00',
                'aircraft_type'          => 'Airbus A380',
                'total_seats'            => 500,
                'status'                 => 'on_time',
            ],
        ];

        foreach ($flights as $flightData) {
            // 1. تحديث أو إنشاء الرحلة
            $flight = Flight::updateOrCreate(
                ['flight_number' => $flightData['flight_number']],
                $flightData
            );

            // 2. تنظيف البيانات القديمة المرتبطة بهذه الرحلة فقط
            DB::table('flight_prices')->where('flight_id', $flight->id)->delete();
            DB::table('seats')->where('flight_id', $flight->id)->delete();

            // 3. تعريف الدرجات وعدد المقاعد الوهمية لكل درجة
            $config = [
                'economy'     => ['count' => 15, 'prefix' => 'E'],
                'business'    => ['count' => 10, 'prefix' => 'B'],
                'first_class' => ['count' => 5,  'prefix' => 'F'],
            ];

            foreach ($config as $class => $details) {
                // إنشاء السعر لهذه الدرجة
                DB::table('flight_prices')->insert([
                    'flight_id'  => $flight->id,
                    'class'      => $class,
                    'base_price' => $this->getRandomPrice($class),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                // إنشاء المقاعد لهذه الدرجة
                for ($i = 1; $i <= $details['count']; $i++) {
                    DB::table('seats')->insert([
                        'flight_id'    => $flight->id,
                        'seat_number'  => $details['prefix'] . $i,
                        'class'        => $class,
                        'is_available' => true, // لكي يقرأها الـ Resource كـ Available
                        'created_at'   => now(),
                        'updated_at'   => now(),
                    ]);
                }
            }
        }
    }

    private function getRandomPrice($class) {
        return match($class) {
            'economy'     => rand(100, 250),
            'business'    => rand(300, 600),
            'first_class' => rand(700, 1200),
            default       => 150,
        };
    }
}
