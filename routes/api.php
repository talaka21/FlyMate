
<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\NotificationController;
use Illuminate\Support\Facades\Route;

// ─── Public Routes ───
Route::post('/register/passenger', [AuthController::class, 'registerPassenger']);
Route::post('/register/manager',   [AuthController::class, 'registerManager']);
Route::post('/login',              [AuthController::class, 'login']);
Route::post('/login/mfa',          [AuthController::class, 'verifyMfa']);
Route::get('/flights/search', [App\Http\Controllers\Api\PassengerController::class, 'searchFlights']);
// ─── Protected Routes ───

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // Admin
    Route::middleware('role:admin')->group(function () {
        Route::get('/admin/managers/pending',        [AdminController::class, 'pendingManagers']);
        Route::post('/admin/managers/{id}/approve',  [AdminController::class, 'approveManager']);
        Route::post('/admin/passengers/{id}/ban',    [AdminController::class, 'banPassenger']);
        Route::post('/admin/passengers/{id}/unban',  [AdminController::class, 'unbanPassenger']);
    });

    // Manager + Admin
    Route::middleware('role:manager,admin')->group(function () {
        Route::get('/dashboard', function () {
            return response()->json(['message' => 'Welcome to Dashboard']);
        });
    });

    // Passenger
    Route::middleware('role:passenger')->group(function () {
        Route::get('/home', function () {
            return response()->json(['message' => 'Welcome Passenger']);
        });
    });
});

Route::post('/forgot-password', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'sendResetLink']);
Route::post('/reset-password', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'resetPassword']);


// Passenger Routes
Route::middleware('auth:sanctum')->group(function () {

    // Profile & Account
    Route::get('/profile', [App\Http\Controllers\Api\PassengerController::class, 'profile']);
    Route::put('/profile', [App\Http\Controllers\Api\PassengerController::class, 'updateProfile']);
    Route::put('/profile/password', [App\Http\Controllers\Api\PassengerController::class, 'changePassword']);
    Route::delete('/profile', [App\Http\Controllers\Api\PassengerController::class, 'deleteAccount']);

    // Search Flights


    // Book Flight
    Route::post('/bookings', [App\Http\Controllers\Api\BookingController::class, 'store']);
    Route::get('/bookings', [App\Http\Controllers\Api\BookingController::class, 'index']);
    Route::get('/bookings/{id}', [App\Http\Controllers\Api\BookingController::class, 'show']);

    // Payment
    Route::post('/bookings/{id}/pay', [App\Http\Controllers\Api\PaymentController::class, 'pay']);

    // Manage Bookings
    Route::post('/bookings/{id}/cancel', [App\Http\Controllers\Api\BookingController::class, 'cancel']);
    Route::post('/bookings/{id}/reschedule', [App\Http\Controllers\Api\BookingController::class, 'reschedule']);
    Route::post('/bookings/{id}/upgrade', [App\Http\Controllers\Api\BookingController::class, 'upgrade']);

Route::get('/bookings/{id}/boarding-pass', [App\Http\Controllers\Api\PassengerController::class, 'showBoardingPass']);
    });
// Route::get('/test-notification', function () {
//     $user = \App\Models\User::first();
//     $user->notify(new \App\Notifications\ResetPasswordNotification('test-token-123'));

//     return response()->json(['message' => 'Notification sent!']);
// });

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
Route::get('bookings/{id}/boarding-pass', [BookingController::class, 'generateBoardingPass']);
    });
