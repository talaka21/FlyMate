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
        // 1. الفلترة بالتاريخ (أساسية طالما طلبها أمير)
        ->when(!empty($data['departure_date']), function ($q) use ($data) {
            $q->whereDate('departure_at', $data['departure_date']);
        })
        // 2. الفلترة بمطار الإقلاع (تشتغل فقط إذا تم إرسالها)
        ->when(!empty($data['origin']), function ($q) use ($data) {
            $q->whereHas('originAirport', function ($subQ) use ($data) {
                $subQ->where('iata_code', $data['origin']);
            });
        })
        // 3. الفلترة بمطار الوصول (تشتغل فقط إذا تم إرسالها)
        ->when(!empty($data['destination']), function ($q) use ($data) {
            $q->whereHas('destinationAirport', function ($subQ) use ($data) {
                $subQ->where('iata_code', $data['destination']);
            });
        })
        // 4. الفلترة بالدرجة/الكلاس (تشتغل فقط إذا تم إرسالها)
        ->when(!empty($data['class']), function ($q) use ($data) {
            $q->whereHas('prices', function ($subQ) use ($data) {
                $subQ->where('class', $data['class']);
            });
        })
        // الحالات الثابتة للرحلة المتاحة
        ->whereIn('status', ['on_time', 'delayed']);

    $flights = $query->get();

    if ($flights->isEmpty()) {
        return collect([]);
    }

    return FlightResource::collection($flights);
}

}
