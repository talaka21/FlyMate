<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Flight;

class SeatSeeder extends Seeder
{
    public function run(): void
    {
        $flights = Flight::all();

        if ($flights->isEmpty()) {
            $this->command->warn('No flights found!');
            return;
        }

        // ✅ التعديل هنا: تم تغيير المفتاح إلى 'first_class' ليطابق الـ enum في الميجريشن تماماً
        $classes = [
            'economy'     => 0.70, // 70% من المقاعد
            'business'    => 0.20, // 20%
            'first_class' => 0.10, // 10%
        ];

        $batchSize = 500;
        $batch = [];
        $count = 0;
        $now = now(); // تحسين الأداء

        foreach ($flights->take(50) as $flight) {
            $totalSeats = $flight->total_seats ?? 150;

            // الترقيم يبدأ من 1 لكل رحلة
            $seatNumber = 1;

            foreach ($classes as $class => $ratio) {
                $seatsForClass = (int) round($totalSeats * $ratio);

                // ميزة إضافية: إذا أردتِ ترقيم كل درجة بشكل منفصل (E1, B1, F1..)
                // يمكنكِ إلغاء التعليق عن السطر التالي ونقله هنا:
                // $seatNumber = 1;

                for ($i = 0; $i < $seatsForClass; $i++) {
                    $batch[] = [
                        'flight_id'    => $flight->id,
                        // سيأخذ الحرف الأول كابيتال (E أو B أو F) متبوعاً بالرقم
                        'seat_number'  => strtoupper($class[0]) . $seatNumber,
                        'class'        => $class, // سيتم إدخال 'economy' أو 'business' أو 'first_class'
                        'is_available' => true,
                        'created_at'   => $now,
                        'updated_at'   => $now,
                    ];
                    $seatNumber++;
                    $count++;

                    if (count($batch) >= $batchSize) {
                        DB::table('seats')->insert($batch);
                        $batch = [];
                    }
                }
            }
        }

        if (!empty($batch)) {
            DB::table('seats')->insert($batch);
        }

        $this->command->info("Created {$count} seats successfully!");
    }
}
