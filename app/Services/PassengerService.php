<?php

namespace App\Services;

use App\Models\Flight;
use App\Http\Resources\FlightResource;
use App\Models\Booking;
use Illuminate\Support\Facades\Hash;
use Exception;

class PassengerService
{
    /**
     * تحديث بيانات الملف الشخصي
     */
    public function updateProfile($user, array $data)
    {
        $user->update($data);
        return $user;
    }

    /**
     * تغيير كلمة المرور مع التحقق من القديمة
     */
    public function changePassword($user, array $data)
    {
        if (!Hash::check($data['current_password'], $user->password)) {
            throw new Exception(__('passenger.wrong_password'));
        }

        $user->update([
            'password' => Hash::make($data['new_password'])
        ]);

        return true;
    }

    /**
     * حذف الحساب (تغيير الحالة لـ banned)
     */
    public function deleteAccount($user, array $data)
    {
        if (!Hash::check($data['password'], $user->password)) {
            throw new Exception(__('passenger.wrong_password'));
        }

        $user->update(['status' => 'banned']);
        $user->tokens()->delete();

        return true;
    }

    /**
     * البحث عن الرحلات بناءً على المعايير
     */
 public function searchFlights(array $data)
{
    $allowedCities = ['Damascus', 'Latakia', 'Deir ez-Zor', 'Aleppo'];

    $query = Flight::with(['airline', 'originAirport', 'destinationAirport', 'prices', 'seats'])
        // 1. الفلترة بالتاريخ (أساسية بناءً على طلب شريكك)
        ->whereDate('departure_at', $data['date'])

        // 2. فلترة المصدر (فقط إذا تم إرسال origin في الطلب)
        ->when(isset($data['origin']), function ($q) use ($data) {
            $q->whereHas('originAirport', fn($sub) => $sub->where('city', $data['origin']));
        })

        // 3. فلترة الوجهة (فقط إذا تم إرسال destination في الطلب)
        ->when(isset($data['destination']), function ($q) use ($data) {
            $q->whereHas('destinationAirport', fn($sub) => $sub->where('city', $data['destination']));
        })

        // 4. حماية إضافية: التأكد أن الرحلة ضمن المدن المسموحة (اختياري حسب منطق عملك)
        ->whereHas('originAirport', fn($q) => $q->whereIn('city', $allowedCities))

        ->whereIn('status', ['on_time', 'delayed']);

    $flights = $query->get();

    if ($flights->isEmpty()) {
        throw new \Exception(__('flights.not_found'));
    }

    return FlightResource::collection($flights);
}

    public function generateBoardingData($bookingId)
{
    // جلب الحجز مع بيانات الرحلة والمقعد والمطار
    $booking = Booking::with(['flight.originAirport', 'flight.destinationAirport', 'seat', 'user'])
                      ->findOrFail($bookingId);

    // الرابط الذي سيفتحه موظف المطار للتأكد من صحة التذكرة
    $verificationUrl = "https://flymate.com/verify/" . $booking->boarding_code;

    return [
        'booking' => $booking,
        'qr_url'  => $verificationUrl
    ];
}
}
