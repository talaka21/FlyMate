<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class FlightPriceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // جلب جميع الـ IDs للرحلات الموجودة في قاعدة البيانات
        $flightIds = DB::table('flights')->pluck('id');

        if ($flightIds->isEmpty()) {
            $this->command->warn('لا يوجد رحلات في قاعدة البيانات لتوليد أسعار لها. شغّل FlightSeeder أولاً!');
            return;
        }

        $pricesData = [];

        foreach ($flightIds as $flightId) {

            // 1. درجة الـ Economy (بحدود الـ 600)
            $pricesData[] = [
                'flight_id'   => $flightId,
                'class'       => 'economy',
                'base_price'  => rand(580, 620), // السعر الأساسي حول الـ 600
                'min_price'   => 500,            // الحد الأدنى عند العروض
                'max_price'   => 750,            // الحد الأقصى في المواسم
                'created_at'  => now(),
                'updated_at'  => now(),
            ];

            // 2. درجة الـ Business (ضعف سعر الـ Economy تقريباً - منطقي عالمياً)
            $pricesData[] = [
                'flight_id'   => $flightId,
                'class'       => 'business',
                'base_price'  => rand(1100, 1300),
                'min_price'   => 950,
                'max_price'   => 1600,
                'created_at'  => now(),
                'updated_at'  => now(),
            ];

            // 3. الدرجة الأولى First Class (تكون أعلى ومكلفة)
            $pricesData[] = [
                'flight_id'   => $flightId,
                'class'       => 'first_class',
                'base_price'  => rand(2000, 2400),
                'min_price'   => 1800,
                'max_price'   => 3000,
                'created_at'  => now(),
                'updated_at'  => now(),
            ];
        }

        // استخدام الـ Chunk لإدخال البيانات على دفعات لتفادي مشاكل الأداء بسبب حجم البيانات الكبير
        $chunks = array_chunk($pricesData, 500);
        foreach ($chunks as $chunk) {
            DB::table('flight_prices')->insert($chunk);
        }

        $this->command->info('تم توليد الأسعار المنطقية لجميع الدرجات بنجاح.');
    }
}
