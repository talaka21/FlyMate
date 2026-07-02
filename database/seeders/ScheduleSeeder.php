<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ScheduleSeeder extends Seeder
{
    public function run(): void
    {
        // 1. جلب الـ IDs للرحلات والمطارات المتوفرة في قاعدة البيانات
        $flightIds = DB::table('flights')->pluck('id')->toArray();
        $airportIds = DB::table('airports')->pluck('id')->toArray();

        // شرط أمان: إذا كانت المطارات أو الرحلات فارغة سيعطي تنبيهاً
        if (empty($flightIds) || empty($airportIds) || count($airportIds) < 2) {
            $this->command->warn('تنبيه: يجب توليد المطارات والرحلات أولاً! تأكدي من تشغيل AirportSeeder و FlightSeeder قبل هذا الملف.');
            return;
        }

        $schedules = [
            [
                'flight_id'              => $flightIds[0],
                'origin_airport_id'      => $airportIds[0], // مطار المغادرة الأول
                'destination_airport_id' => $airportIds[1], // مطار الوصول الثاني
                'departure_time'         => '08:30:00',
                'arrival_time'           => '11:45:00',
                'days_of_week'           => json_encode([1, 3, 5]), // أيام: الإثنين، الأربعاء، الجمعة (JSON)
                'valid_from'             => Carbon::now()->startOfYear()->format('Y-m-d'),
                'valid_until'            => Carbon::now()->endOfYear()->format('Y-m-d'),
                'status'                 => 'active',
                'created_at'             => now(),
                'updated_at'             => now(),
            ],
            [
                'flight_id'              => $flightIds[1] ?? $flightIds[0], // إذا لم توجد رحلة ثانية يأخذ الأولى
                'origin_airport_id'      => $airportIds[1],
                'destination_airport_id' => $airportIds[0],
                'departure_time'         => '14:15:00',
                'arrival_time'           => '18:00:00',
                'days_of_week'           => json_encode([2, 4, 6]), // أيام: الثلاثاء، الخميس، السبت
                'valid_from'             => Carbon::now()->startOfYear()->format('Y-m-d'),
                'valid_until'            => Carbon::now()->endOfYear()->format('Y-m-d'),
                'status'                 => 'active',
                'created_at'             => now(),
                'updated_at'             => now(),
            ],
            [
                'flight_id'              => $flightIds[2] ?? $flightIds[0],
                'origin_airport_id'      => $airportIds[0],
                'destination_airport_id' => $airportIds[1],
                'departure_time'         => '22:00:00',
                'arrival_time'           => '01:30:00',
                'days_of_week'           => json_encode([7]), // يوم الأحد فقط
                'valid_from'             => Carbon::now()->startOfYear()->format('Y-m-d'),
                'valid_until'            => Carbon::now()->addMonths(6)->format('Y-m-d'), // صالح لمدة 6 أشهر
                'status'                 => 'postponed', // تم وضعها كـ مؤجلة للتنويع وتلوين الحالات في العرض
                'created_at'             => now(),
                'updated_at'             => now(),
            ],
        ];

        // إدخال البيانات المعدلة في الجدول
        DB::table('schedules')->insert($schedules);

        $this->command->info('تم توليد مواعيد الرحلات (Schedules) المتطابقة مع الجداول بنجاح!');
    }
}
