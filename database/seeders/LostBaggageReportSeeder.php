<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\User;

class LostBaggageReportSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. التأكد من وجود مستخدمين (ركاب وموظفين) لربط البلاغات بهم
        if (User::count() === 0) {
            // إذا كانت قاعدة البيانات فارغة تماماً، ننشئ مستخدم تجريبي
            User::create([
                'name' => 'Super Admin',
                'email' => 'admin@flymate.com',
                'password' => bcrypt('password'),
                'role' => 'admin',
                'status' => 'active',
            ]);
        }

        // 2. توليد 10 بلاغات أمتعة مفقودة منوعة
        for ($i = 0; $i < 10; $i++) {
            // جلب ركاب وموظفين عشوائيين للعلاقات
            $passenger = User::inRandomOrder()->first();
            $manager = User::whereIn('role', ['admin', 'manager'])->inRandomOrder()->first();

            DB::table('lost_baggage_reports')->insert([
                'reference_number'  => 'FML-' . fake()->unique()->numberBetween(100000, 999999),
                'user_id'           => $passenger->id,
                'flight_number'     => 'FM-' . fake()->numberBetween(100, 999),
                'departure_city'    => fake()->city(),
                'arrival_city'      => fake()->city(),
                'arrival_date'      => fake()->date('Y-m-d'),
                'airport_code'      => fake()->randomElement(['CAI', 'DXB', 'JFK', 'LHR', 'CDG']),
                'baggage_type'      => fake()->randomElement(['suitcase', 'backpack', 'hand_bag', 'other']),
                'baggage_size'      => fake()->randomElement(['small', 'medium', 'large']),
                'baggage_color'     => fake()->safeColorName(),
                'description'       => 'The bag contains personal clothes, travel documents, and some gifts. It has a lock on the side.',
                'distinctive_marks' => fake()->randomElement(['Red ribbon tied to the handle', 'Sticker of a flight logo', null]),
                'contact_phone'     => fake()->phoneNumber(),
                'contact_email'     => $passenger->email,
                'delivery_address'  => fake()->address(),
                'status'            => fake()->randomElement(['pending_review', 'sent_to_airport', 'searching', 'found', 'in_delivery', 'delivered', 'closed']),
                'admin_notes'       => fake()->randomElement(['Being checked in terminal 2', 'Awaiting traveler response', null]),
                'assigned_to'       => fake()->randomElement([$manager?->id, null]),
                'created_at'        => now(),
                'updated_at'        => now(),
            ]);
        }
    }
}
