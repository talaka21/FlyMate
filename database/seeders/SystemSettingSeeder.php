<?php

namespace Database\Seeders;

use App\Models\SystemSetting;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SystemSettingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $settings = [
        ['key' => 'system_name',     'value' => 'FlyMate'],
        ['key' => 'contact_email',   'value' => 'support@flymate.com'],
        ['key' => 'default_currency','value' => 'SYP'],
        ['key' => 'contact_phone',   'value' => '+962791234567'],
    ];

    foreach ($settings as $setting) {
        SystemSetting::create($setting);
    }
    }
}
