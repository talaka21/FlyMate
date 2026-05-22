<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class FlightSeeder extends Seeder
{
    public function run(): void
    {
        $airports = DB::table('airports')->get();
        $airlines = DB::table('airlines')->pluck('id')->toArray();

        if ($airports->isEmpty() || empty($airlines)) {
            $this->command->warn('Database tables for airports or airlines are empty!');
            return;
        }

        $startDate = Carbon::today();
        $days = 7;

        foreach ($airports as $origin) {
            foreach ($airports as $destination) {
                if ($origin->id === $destination->id) continue;

                for ($day = 0; $day < $days; $day++) {
                    $departureDate = $startDate->copy()->addDays($day);

                    $departureAt = $departureDate->copy()->setHour(rand(6, 20))->setMinute(rand(0, 5) * 12);
                    $arrivalAt = $departureAt->copy()->addHours(rand(1, 4));

                    $totalSeats = 150;
                    $availableSeats = rand(40, $totalSeats);

                    // تقسيم المقاعد عشوائياً على الدرجات
                    $first = rand(2, 10);
                    $business = rand(5, 20);
                    $economy = $availableSeats - ($first + $business);

                    $originCode = $origin->iata_code ?? substr($origin->name, 0, 3);

                    DB::table('flights')->insert([
                        'flight_number'            => strtoupper($originCode) . '-' . $destination->id . '-' . $departureDate->format('Ymd') . '-' . rand(100, 999),
                        'airline_id'               => $airlines[array_rand($airlines)],
                        'origin_airport_id'        => $origin->id,
                        'destination_airport_id'   => $destination->id,
                        'departure_at'             => $departureAt,
                        'arrival_at'               => $arrivalAt,
                        'aircraft_type'            => 'Boeing 737',
                        'total_seats'              => $totalSeats,
                        'available_seats'          => $availableSeats,

                        // تمرير القيم العشوائية للأعمدة الجديدة
                        'available_seats_first'    => $first,
                        'available_seats_business' => $business,
                        'available_seats_economy'  => $economy,
                        'mock_price'               => rand(150, 650),

                        'frequency'                => 'daily',
                        'status'                   => 'on_time',
                        'created_at'               => now(),
                        'updated_at'               => now(),
                    ]);
                }
            }
        }

        $this->command->info('Flights generated successfully with custom seats and prices.');
    }
}
