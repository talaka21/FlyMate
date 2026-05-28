<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class RewardStoreSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
{
    // 1. 🔥 تعطيل فحص العلاقات مؤقتاً لتجنب الخطأ
    \Schema::disableForeignKeyConstraints();

    DB::table('rewards')->truncate();

    // 2. إعادة تفعيل فحص العلاقات فوراً بعد المسح
    \Schema::enableForeignKeyConstraints();

    $rewards = [
        [
            'type' => 'seat_change',
            'title' => 'Free Seat Selection',
            'points_cost' => 150,
            'value' => 0,
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ],
        [
            'type' => 'free_weight',
            'title' => 'Extra Baggage Allowance (+5 KG)',
            'points_cost' => 300,
            'value' => 5,
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ],
        [
            'type' => 'lounge_access',
            'title' => 'Airport VIP Lounge Access',
            'points_cost' => 500,
            'value' => 0,
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ],
        [
            'type' => 'ticket_discount',
            'title' => '10% Flight Discount Voucher',
            'points_cost' => 600,
            'value' => 10,
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ],
        [
            'type' => 'ticket_discount',
            'title' => 'Exclusive 20% Flight Discount Voucher',
            'points_cost' => 1200,
            'value' => 20,
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ],
    ];

    DB::table('rewards')->insert($rewards);
}
}
