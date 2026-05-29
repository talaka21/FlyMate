
<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\AirlineController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\Api\PassengerController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\LostBaggageController;
use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\CurrencyController;
use App\Http\Controllers\OfferController;
use App\Http\Controllers\PrayerController;
use App\Http\Controllers\WeatherController;
use Illuminate\Support\Facades\Route;

// ─── Public Routes ───────────────────────────────────────
Route::post('/register/passenger', [AuthController::class, 'registerPassenger']);
Route::post('/register/manager',   [AuthController::class, 'registerManager']);
Route::post('/login',              [AuthController::class, 'login']);
Route::post('/login/mfa',          [AuthController::class, 'verifyMfa']);
Route::post('/forgot-password',    [ForgotPasswordController::class, 'sendResetLink']);
Route::post('/reset-password',     [ForgotPasswordController::class, 'resetPassword']);
Route::get('/flights/search',      [PassengerController::class, 'searchFlights']);
Route::get('/weather/{city}', [WeatherController::class, 'show']);

// ─── Airlines  ───
Route::get('/airlines',            [AirlineController::class, 'index']);
Route::get('/airlines/{airline}',  [AirlineController::class, 'show']);
// ─── Protected Routes ─────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // تحديث FCM Token (متاح لكل أنواع المستخدمين بمجرد تسجيل الدخول)
    Route::post('/update-fcm-token', function (\Illuminate\Http\Request $request) {
        $request->validate([
            'fcm_token' => 'required|string',
        ]);

        $request->user()->update([
            'fcm_token' => $request->fcm_token
        ]);

        return response()->json(['message' => 'FCM Token updated successfully']);
    });

    // ─── Admin ───
    Route::middleware('role:admin')->group(function () {
        Route::get('/admin/managers/pending',       [AdminController::class, 'pendingManagers']);
        Route::post('/admin/managers/{id}/approve', [AdminController::class, 'approveManager']);
        Route::post('/admin/passengers/{id}/ban',   [AdminController::class, 'banPassenger']);
        Route::post('/admin/passengers/{id}/unban', [AdminController::class, 'unbanPassenger']);
    });

    // ─── Manager + Admin ───
    Route::middleware('role:manager,admin')->group(function () {
        Route::get('/dashboard', fn() => response()->json(['message' => 'Welcome to Dashboard']));
    });

    // ─── Passenger ───
    Route::middleware('role:passenger')->group(function () {
        Route::get('/home', fn() => response()->json(['message' => 'Welcome Passenger']));

        // Profile
        Route::get('/profile',           [PassengerController::class, 'profile']);
        Route::put('/profile',           [PassengerController::class, 'updateProfile']);
        Route::put('/profile/password',  [PassengerController::class, 'changePassword']);
        Route::delete('/profile',        [PassengerController::class, 'deleteAccount']);

        // Bookings
        Route::get('/bookings',                      [BookingController::class, 'index']);
        Route::post('/bookings',                     [BookingController::class, 'store']);
        Route::get('/bookings/{id}',                 [BookingController::class, 'show']);
        Route::post('/bookings/{id}/cancel',         [BookingController::class, 'cancel']);
        Route::post('/bookings/{id}/reschedule',     [BookingController::class, 'reschedule']);
        Route::post('/bookings/{id}/upgrade',        [BookingController::class, 'upgrade']);
        Route::get('/bookings/{id}/boarding-pass',   [BookingController::class, 'generateBoardingPass']);

        // Payment
        Route::post('/bookings/{id}/pay', [PaymentController::class, 'pay']);

        // Notifications
        Route::get('/notifications',              [NotificationController::class, 'index']);
        Route::post('/notifications/{id}/read',   [NotificationController::class, 'markAsRead']);

        // Chat
        Route::post('/chat', [ChatController::class, 'send']);
    });

});
// تأكدي أن هذا السطر مكتوب في أسفل الملف وخارج مجمّع الحماية
Route::get('/test-fcm/{user_id}', [App\Http\Controllers\NotificationController::class, 'testFCM']);


Route::middleware('auth:sanctum')->group(function () {

    // مسارات الحقائب المفقودة الخاصة بالمسافر
    Route::post('/lost-baggage/reports', [LostBaggageController::class, 'store']);
    Route::get('/lost-baggage/reports', [LostBaggageController::class, 'index']);
    Route::get('/lost-baggage/reports/{id}', [LostBaggageController::class, 'show']);

    // مسار رفع الصور التابعة للبلاغ
    Route::post('/lost-baggage/reports/{id}/images', [LostBaggageController::class, 'uploadImage']);

    // مسار الموظف لتحديث الحالة (PATCH)
    Route::patch('/admin/lost-baggage/reports/{id}/status', [LostBaggageController::class, 'updateStatus']);
});

//Currency
Route::get('/convert-currency', [CurrencyController::class, 'convertCurrency']);

// الـ Route الخاص بمواقيت الصلاة والقبلة
Route::get('/prayer-times', [PrayerController::class, 'getPrayerTimes']);


Route::middleware('auth:sanctum')->group(function () {
    // رابط إنشاء عملية الدفع والحجز
    Route::post('/bookings/pay', [BookingController::class, 'createPaymentIntent']);
});

// هذا الرابط سترايب رح تضربه لما ينجح الدفع
Route::post('/stripe/webhook', [BookingController::class, 'handleStripeWebhook']);

use App\Http\Controllers\API\RewardController;

Route::middleware('auth:sanctum')->group(function () {

    // الأربطة الجديدة لنظام النقاط والمكافآت 🔥
    Route::get('/rewards', [RewardController::class, 'index']); // متجر المكافآت
    Route::get('/user/points', [RewardController::class, 'getUserPoints']); // رصيد النقاط الحالي

    // ... باقي أربطة الحجوزات والإلغاء تبعكِ ...
});
