<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\Request;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FirebaseNotification;

class NotificationController extends Controller
{
    // 1. جلب التنبيهات الخاصة بالمستخدم (كما هي)
    public function index(Request $request)
    {
        $notifications = Notification::where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json($notifications);
    }

    // 2. تحويل التنبيه إلى مقروء (كما هي)
    public function markAsRead($id)
    {
        Notification::where('id', $id)
            ->where('user_id', auth()->id())
            ->update(['is_read' => true]);

        return response()->json(['message' => 'Marked as read']);
    }

    /**
     * دالة جديدة ومهمة: تستدعينها من أي مكان بالسيرفر لإرسال إشعار
     * تقوم بالحفظ في الـ History وبث الإشعار عبر FCM بنفس اللحظة
     */
    public function sendPushNotification($userId, $title, $body)
    {
        // أولاً: جلب المستخدم للتأكد من وجوده والوصول للـ fcm_token الخاص به
        $user = User::find($userId);
        if (!$user) {
            return false;
        }

        // ثانياً: حفظ التنبيه في قاعدة البيانات (نظام الـ History الخاص بكِ)
        // تأكدي أن أسماء الأعمدة في جدولك تطابق (title و body) أو عدليها هنا لتطابق جدولك
        Notification::create([
            'user_id' => $user->id,
            'title'   => $title,
            'message' => $body,
            'is_read' => false
        ]);

        // ثالثاً: إرسال الإشعار الفوري للجوال عبر FCM إذا كان الـ token موجوداً
        if ($user->fcm_token) {
            try {
                // استدعاء خدمة الفايربيز من الحزمة
                $messaging = app('firebase.messaging');

                $message = CloudMessage::withTarget('token', $user->fcm_token)
                    ->withNotification(FirebaseNotification::create($title, $body))
                    ->withData([
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK', // سيسعد بها مطور الفلاتر جداً ليفتح التطبيق عند النقر
                        'sound' => 'default'
                    ]);

                $messaging->send($message);
                return true;
            } catch (\Exception $e) {
                // تسجيل الخطأ بالـ Log في حال كان الـ token منتهي الصلاحية أو هناك مشكلة بالاتصال
                logger('FCM Error for User ' . $userId . ': ' . $e->getMessage());
            }
        }

        return false;
    }
    // أضيفي هذه الدالة هنا ليقرأها الـ Route الخاص بالتيست
   public function testFCM($userId)
    {
        try {
            $user = User::find($userId);

            if (!$user) {
                return response()->json(['status' => 'error', 'message' => 'المستخدم غير موجود'], 404);
            }

            if (!$user->fcm_token) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'هذا المستخدم لا يملك FCM Token حالياً، يجب تحديثه من الفلاتر أولاً!'
                ], 400);
            }

            // استدعاء دالة الإرسال والبث الحقيقي
            $result = $this->sendPushNotification($user->id, 'تنبيه من FlyMate', 'تم تحديث حالة رحلتك بنجاح!');

            if ($result) {
                return response()->json(['status' => 'success', 'message' => 'تم بث الإشعار وحفظه بالـ History!']);
            }

            return response()->json(['status' => 'error', 'message' => 'فشل إرسال الإشعار لسيرفر جوجل'], 500);

        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'error_message' => $e->getMessage()], 500);
        }
    }
}
