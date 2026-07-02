<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\AuditLog;
use App\Models\User;
use Carbon\Carbon;

class AuditLogSeeder extends Seeder
{
    public function run(): void
    {
        // جلب أول مستخدم أدمن، أو فرض القيمة 1 كافتراضي لربط العمليات به
        $adminId = User::where('role', 'admin')->first()?->id ?? 1;

        // مصفوفة عمليات وهمية منظمة ومتوافقة مع بنية جدولك (JSON والأقسام)
        $logs = [
            [
                'action'     => 'Login',
                'model'      => 'App\Models\User',
                'model_id'   => $adminId,
                'old_values' => null,
                'new_values' => ['ip_address' => '127.0.0.1', 'browser' => 'Chrome'],
                'days_ago'   => 4,
            ],
            [
                'action'     => 'Update Flight',
                'model'      => 'App\Models\Flight',
                'model_id'   => 10, // رقم رحلة افتراضي
                'old_values' => ['status' => 'scheduled'],
                'new_values' => ['status' => 'delayed', 'notes' => 'Delayed due to weather'],
                'days_ago'   => 3,
            ],
            [
                'action'     => 'Cancel Booking',
                'model'      => 'App\Models\Booking',
                'model_id'   => 25, // رقم حجز افتراضي
                'old_values' => ['status' => 'confirmed'],
                'new_values' => ['status' => 'cancelled'],
                'days_ago'   => 2,
            ],
            [
                'action'     => 'Create Flight',
                'model'      => 'App\Models\Flight',
                'model_id'   => 15,
                'old_values' => null,
                'new_values' => ['flight_number' => 'FM-402', 'origin' => 'Damascus', 'destination' => 'Dubai'],
                'days_ago'   => 1,
            ],
            [
                'action'     => 'Update Status Toggle',
                'model'      => 'App\Models\Airline',
                'model_id'   => 2,
                'old_values' => ['status' => 'active'],
                'new_values' => ['status' => 'inactive'],
                'days_ago'   => 0, // اليوم
            ],
        ];

        // إدخال البيانات في قاعدة البيانات
        foreach ($logs as $log) {
            AuditLog::create([
                'user_id'    => $adminId,
                'action'     => $log['action'],
                'model'      => $log['model'],
                'model_id'   => $log['model_id'],
                'old_values' => $log['old_values'], // سيتم تحويلها لـ JSON تلقائياً
                'new_values' => $log['new_values'],
                'created_at' => Carbon::now()->subDays($log['days_ago'])->subHours(rand(1, 10)),
                'updated_at' => Carbon::now()->subDays($log['days_ago']),
            ]);
        }
    }
}
