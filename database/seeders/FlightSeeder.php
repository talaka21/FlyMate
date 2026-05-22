<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class FlightSeeder extends Seeder
{
    public function run(): void
    {
        // المطارات المسموح بالإقلاع منها
        $allowedOrigins = ['Damascus', 'Latakia', 'Deir ez-Zor', 'Aleppo'];

        // جيب IDs المطارات المحددة فقط للإقلاع
        $originAirports = DB::table('airports')
            ->whereIn('city', $allowedOrigins)
            ->pluck('id', 'city');

        // جيب باقي المطارات كوجهات
        $allAirports = DB::table('airports')->pluck('id')->toArray();

        $airlines = DB::table('airlines')->pluck('id')->toArray();

        if ($originAirports->isEmpty() || empty($airlines)) {
            $this->command->warn('لا يوجد مطارات أو شركات طيران، شغّل AirportSeeder و AirlineSeeder أولاً');
            return;
        }

        // توليد رحلات لـ 7 أيام قادمة (تاريخ اليوم + أسبوع لقدام)
        $startDate = Carbon::today();
        $days = 7;

        foreach ($originAirports as $city => $originId) {
            foreach ($allAirports as $destinationId) {
                // تجنب الرحلة من وإلى نفس المطار
                if ($originId === $destinationId) continue;

                for ($day = 0; $day < $days; $day++) {
                    $departureDate = $startDate->copy()->addDays($day);

                    // تحديد وقت الإقلاع بشكل منطقي (بين الـ 6 صباحاً والـ 8 مساءً)
                    $departureAt = $departureDate->copy()->setHour(rand(6, 20))->setMinute(rand(0, 5) * 12);

                    // مدة الرحلة منطقية (بين ساعة إلى 4 ساعات كحد أقصى)
                    $arrivalAt = $departureAt->copy()->addHours(rand(1, 4));

                    DB::table('flights')->insert([
                        'flight_number'          => strtoupper(substr($city, 0, 2)) . '-' . $destinationId . '-' . $departureDate->format('Ymd') . '-' . rand(100, 999),
                        'airline_id'             => $airlines[array_rand($airlines)],
                        'origin_airport_id'      => $originId,
                        'destination_airport_id' => $destinationId,
                        'departure_at'           => $departureAt,
                        'arrival_at'             => $arrivalAt,
                        'aircraft_type'          => 'Boeing 737',
                        'total_seats'            => 150,
                        'frequency'              => 'daily',
                        'status'                 => 'on_time',
                        'created_at'             => now(),
                        'updated_at'             => now(),
                    ]);
                }
            }
        }

        $this->command->info('تم توليد الرحلات بنجاح لأسبوع قادم.');
    }
}
