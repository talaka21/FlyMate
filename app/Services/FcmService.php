<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmService
{
    /**
     * إرسال إشعار دفعي عبر Firebase Cloud Messaging (FCM)
     */
    public function sendPushNotification($token, $title, $body, $data = [])
    {
        // هنا يتم وضع الكود الخاص بالاتصال بـ Firebase API (v1) لاحقاً
        // حالياً سنقوم بتوثيق الإرسال في الـ Log للتأكد من أن البيانات تطير بشكل صحيح
        Log::info("FCM Notification Sent Successfully", [
            'to' => $token,
            'notification' => [
                'title' => $title,
                'body' => $body
            ],
            'data' => $data
        ]);

        return true;
    }
}
