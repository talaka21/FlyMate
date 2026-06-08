<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class FlightSeeder extends Seeder
{
    public function run(): void
    {
        $allowedOrigins = ['Damascus', 'Latakia', 'Deir ez-Zor', 'Aleppo'];

        $originAirports = DB::table('airports')
            ->whereIn('city', $allowedOrigins)
            ->pluck('id', 'city');

        $allAirports = DB::table('airports')->pluck('id', 'city');

        $airlines = DB::table('airlines')->pluck('id')->toArray();

        if ($originAirports->isEmpty() || empty($airlines)) {
            $this->command->warn('شغّل AirportSeeder و AirlineSeeder أولاً');
            return;
        }

        // IDs المطارات السورية لمنع الرحلات الداخلية
        $syrianAirportIds = $originAirports->values()->toArray();

        $startDate = Carbon::today();
        $days = 30;

        $departureTimes = [
            ['hour' => 6,  'minute' => 0,  'duration' => 2],
            ['hour' => 12, 'minute' => 30, 'duration' => 3],
            ['hour' => 18, 'minute' => 0,  'duration' => 2],
        ];

        $statusPool = array_merge(
            array_fill(0, 70, 'on_time'),
            array_fill(0, 20, 'delayed'),
            array_fill(0, 10, 'cancelled')
        );

        $aircraftTypes = ['Boeing 737', 'Airbus A320', 'Boeing 777', 'Airbus A380'];

        $counter = 1;

        foreach ($originAirports as $originCity => $originId) {
            foreach ($allAirports as $destCity => $destinationId) {
                // تجنب نفس المطار
                if ($originId === $destinationId) continue;

                // تجنب الرحلات بين المطارات السورية مع بعض
                if (in_array($destinationId, $syrianAirportIds)) continue;

                for ($day = 0; $day < $days; $day++) {
                    foreach ($departureTimes as $time) {
                        $departureAt = $startDate->copy()
                            ->addDays($day)
                            ->setHour($time['hour'])
                            ->setMinute($time['minute'])
                            ->setSecond(0);

                        $arrivalAt = $departureAt->copy()->addHours($time['duration']);

                        $status = $statusPool[array_rand($statusPool)];

                        if ($status === 'delayed') {
                            $arrivalAt->addMinutes(rand(30, 120));
                        }

                        DB::table('flights')->insert([
                            'flight_number'           => strtoupper(substr($originCity, 0, 2)) . strtoupper(substr($destCity, 0, 2)) . str_pad($counter, 4, '0', STR_PAD_LEFT),
                            'airline_id'              => $airlines[array_rand($airlines)],
                            'origin_airport_id'       => $originId,
                            'destination_airport_id'  => $destinationId,
                            'departure_at'            => $departureAt,
                            'arrival_at'              => $arrivalAt,
                            'aircraft_type'           => $aircraftTypes[array_rand($aircraftTypes)],
                            'total_seats'             => [120, 150, 180, 220][array_rand([120, 150, 180, 220])],
                            'frequency'               => 'daily',
                            'status'                  => $status,
                            'created_at'              => now(),
                            'updated_at'              => now(),
                        ]);

                        $counter++;
                    }
                }
            }
        }

        $this->command->info('create successful' . ($counter - 1));
    }
}
