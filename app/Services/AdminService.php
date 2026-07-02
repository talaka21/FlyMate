<?php

namespace App\Services;

use App\Models\User;
use App\Models\Flight;
use App\Models\Booking;
use App\Models\Payment;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class AdminService
{
    public function getPendingManagers()
    {
        return User::where('role', User::ROLE_MANAGER)
            ->where('status', User::STATUS_PENDING)
            ->get();
    }

    public function updateUserStatus($id, $role, $status)
    {
        $user = User::where('id', $id)
            ->where('role', $role)
            ->firstOrFail();

        $user->update(['status' => $status]);

        return $user;
    }

    public function getDashboardStats()
    {
        return [
            // إجمالي الركاب
            'total_passengers' => User::where('role', User::ROLE_PASSENGER)->count(),

            // إجمالي الرحلات
            'total_flights' => Flight::count(),

            // إجمالي الحجوزات
            'total_bookings' => Booking::count(),

            // رحلات اليوم
            'todays_flights' => Flight::whereDate('departure_at', Carbon::today())->count(),

            // متوسط سعر الحجز
            'average_booking_price' => round(Booking::avg('total_price') ?? 0, 2),

            // إجمالي الإيرادات
            'total_revenue' => round(
                Payment::where('status', 'paid')->sum('amount') ?? 0, 2
            ),

            // المديرين المعلقين
            'pending_managers' => User::where('role', User::ROLE_MANAGER)
                ->where('status', User::STATUS_PENDING)
                ->count(),

            // الحجوزات الشهرية (آخر 12 شهر)
            'monthly_bookings' => Booking::select(
                DB::raw('MONTH(created_at) as month'),
                DB::raw('YEAR(created_at) as year'),
                DB::raw('COUNT(*) as total')
            )
            ->where('created_at', '>=', Carbon::now()->subMonths(12))
            ->groupBy('year', 'month')
            ->orderBy('year')
            ->orderBy('month')
            ->get()
            ->map(fn($row) => [
                'month' => Carbon::create($row->year, $row->month)->format('M Y'),
                'total' => $row->total,
            ]),
        ];
    }
}
