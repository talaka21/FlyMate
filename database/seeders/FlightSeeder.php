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

        $days = 7;
        $classes = ['economy', 'business', 'first_class'];

        foreach ($airports as $origin) {
            foreach ($airports as $destination) {
                if ($origin->id === $destination->id) continue;

                for ($day = 0; $day < $days; $day++) {
                    $departureAt = Carbon::now()->addHours(13 + ($day * 24))->setMinute(rand(0, 5) * 12);
                    $arrivalAt = $departureAt->copy()->addHours(rand(1, 4));

                    $originCode = $origin->iata_code ?? substr($origin->name, 0, 3);

                    // أ) إدخال الرحلة
                    $flightId = DB::table('flights')->insertGetId([
                        'flight_number'          => strtoupper($originCode) . '-' . $destination->id . '-' . $departureAt->format('Ymd') . '-' . rand(100, 999),
                        'airline_id'             => $airlines[array_rand($airlines)],
                        'origin_airport_id'      => $origin->id,
                        'destination_airport_id' => $destination->id,
                        'departure_at'           => $departureAt,
                        'arrival_at'             => $arrivalAt,
                        'aircraft_type'          => 'Boeing 737',
                        'total_seats'            => 150,
                        'available_seats'        => 150,
                        'frequency'              => 'daily',
                        'status'                 => 'on_time',
                        'created_at'             => now(),
                        'updated_at'             => now(),
                    ]);
                    $priceEconomy  = rand(100, 250);
                    $priceBusiness = $priceEconomy + rand(150, 250);
                    $priceFirst    = $priceBusiness + rand(300, 500);

                    DB::table('flight_prices')->insert([
                        [
                            'flight_id'  => $flightId,
                            'class'      => 'economy',
                            'base_price' => $priceEconomy,
                            'created_at' => now(), 'updated_at' => now()
                        ],
                        [
                            'flight_id'  => $flightId,
                            'class'      => 'business',
                            'base_price' => $priceBusiness,
                            'created_at' => now(), 'updated_at' => now()
                        ],
                        [
                            'flight_id'  => $flightId,
                            'class'      => 'first_class',
                            'base_price' => $priceFirst,     
                            'created_at' => now(), 'updated_at' => now()
                        ],
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
        }

        $this->command->info('Perfect! Flights, Prices, and Seats populated successfully.');
    }
}
