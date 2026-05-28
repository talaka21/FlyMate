<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class PrayerController extends Controller
{
    /**
     * جلب مواقيت الصلاة واتجاه القبلة بناءً على مدينة وجهة السفر
     */
    public function getPrayerTimes(Request $request)
    {
        // استقبال اسم المدينة (مثلاً: Dubai، Jeddah، Istanbul)
        // وافتراضياً حطينا دبي إذا ما انبعت شي
        $city = $request->query('city', 'Dubai');

        // 1. ضرب API مواقيت الصلاة (بدون متاح سري الجاهز فورا)
        $prayerResponse = Http::get("https://api.aladhan.com/v1/timingsByCity", [
            'city'    => $city,
            'country' => '', // بنتركه فاضي والـ API بيفهم المدينة تلقائياً
            'method'  => 4   // طريقة الحساب (4 تعتمد رابطة العالم الإسلامي - ممتازة للخليج وتركيا)
        ]);

        if ($prayerResponse->failed()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to fetch prayer times.'
            ], 500);
        }

        $prayerData = $prayerResponse->json()['data'];

        // 2. ضرب API اتجاه القبلة لنفس المدينة (لتكتمل الميزة)
        $latitude  = $prayerData['meta']['latitude'];
        $longitude = $prayerData['meta']['longitude'];

        $qiblaResponse = Http::get("https://api.aladhan.com/v1/qibla/{$latitude}/{$longitude}");
        $qiblaDirection = $qiblaResponse->successful() ? $qiblaResponse->json()['data']['direction'] : null;

        // 3. ترتيب الجواب النهائي لـ بوست مان وفلوتر
        return response()->json([
            'status' => 'Success',
            'message' => "Prayer times and Qibla for {$city} retrieved successfully",
            'data' => [
                'city' => $city,
                'date' => $prayerData['date']['gregorian']['date'],
                'timezone' => $prayerData['meta']['timezone'],
                'timings' => [
                    'Fajr'    => $prayerData['timings']['Fajr'],
                    'Dhuhr'   => $prayerData['timings']['Dhuhr'],
                    'Asr'     => $prayerData['timings']['Asr'],
                    'Maghrib' => $prayerData['timings']['Maghrib'],
                    'Isha'    => $prayerData['timings']['Isha'],
                ],
                'qibla_direction_degrees' => round($qiblaDirection, 2) // زاوية القبلة بالنسبة للشمال
            ]
        ]);
    }
}
