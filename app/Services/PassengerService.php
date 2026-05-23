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

public function searchFlights(array $data)
{
    $query = Flight::with(['airline', 'originAirport', 'destinationAirport', 'prices', 'seats'])
        ->whereHas('originAirport', function ($q) use ($data) {
            $q->where('iata_code', $data['origin']);
        })
        ->whereHas('destinationAirport', function ($q) use ($data) {
            $q->where('iata_code', $data['destination']);
        })
        ->whereDate('departure_at', $data['departure_date'])
        ->whereIn('status', ['on_time', 'delayed']);

    // فلترة بالـ class إذا أرسلها المستخدم
    if (!empty($data['class'])) {
        $query->whereHas('prices', function ($q) use ($data) {
            $q->where('class', $data['class']);
        });
    }

    $flights = $query->get();

    if ($flights->isEmpty()) {
        return collect([]);
    }

    return FlightResource::collection($flights);
}

}
