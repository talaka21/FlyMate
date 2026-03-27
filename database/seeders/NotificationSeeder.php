<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class NotificationSeeder extends Seeder
{
    public function run(): void
    {
        $users = DB::table('users')->pluck('id');

        $notifications = [
            // 
            ['title' => 'تم تأكيد حجزك',      'message' => 'رحلتك من عمّان إلى دبي تم تأكيدها بنجاح'],
            ['title' => 'حجز قيد الانتظار',    'message' => 'حجزك قيد المراجعة، سيتم إشعارك عند التأكيد'],
            ['title' => 'تم إلغاء الحجز',      'message' => 'تم إلغاء حجزك برحلة عمّان - بيروت'],

            // 💳 الدفع
            ['title' => 'الدفع تم بنجاح',      'message' => 'تم استلام دفعتك بقيمة 150$ بنجاح'],
            ['title' => 'فشل عملية الدفع',     'message' => 'لم تتم عملية الدفع، يرجى المحاولة مرة أخرى'],
            ['title' => 'استرداد المبلغ',       'message' => 'تم إرجاع مبلغ 150$ إلى حسابك بنجاح'],

            // 🛫 الرحلة
            ['title' => 'تغيير موعد الرحلة',   'message' => 'تم تغيير موعد رحلتك إلى الساعة 14:30'],
            ['title' => 'رحلتك غداً',           'message' => 'تذكير: رحلتك من عمّان إلى إسطنبول غداً الساعة 08:00'],
            ['title' => 'بوابة المغادرة',       'message' => 'بوابة مغادرتك هي B12، يرجى التوجه إليها'],
            ['title' => 'الرحلة تأخرت',         'message' => 'رحلتك تأخرت لمدة 45 دقيقة، الموعد الجديد 10:45'],
            ['title' => 'الطائرة في الموعد',    'message' => 'رحلتك ستقلع في موعدها، يرجى التوجه للبوابة'],

            // 🧳 تسجيل الوصول
            ['title' => 'تسجيل الوصول متاح',   'message' => 'يمكنك الآن تسجيل الوصول لرحلتك غداً'],
            ['title' => 'تم تسجيل وصولك',      'message' => 'تم تسجيل وصولك بنجاح، مقعدك رقم 14A'],

            // 👤 الحساب
            ['title' => 'مرحباً بك في FlyMate', 'message' => 'تم إنشاء حسابك بنجاح، استمتع برحلاتك!'],
            ['title' => 'تم تحديث بياناتك',    'message' => 'تم تحديث معلومات حسابك بنجاح'],
            ['title' => 'تسجيل دخول جديد',     'message' => 'تم تسجيل الدخول لحسابك من جهاز جديد'],
        ];

        foreach ($users as $userId) {
            // كل يوزر يحصل 5 إشعارات عشوائية
            $random = collect($notifications)->shuffle()->take(5);

            foreach ($random as $notification) {
                DB::table('notifications')->insert([
                    'user_id'    => $userId,
                    'title'      => $notification['title'],
                    'message'    => $notification['message'],
                    'is_read'    => fake()->boolean(30), // 30% مقروءة
                    'created_at' => Carbon::now()->subDays(rand(1, 30)),
                    'updated_at' => Carbon::now(),
                ]);
            }
        }
    }
}
