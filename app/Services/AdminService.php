<?php

namespace App\Services;

use App\Models\User;

class AdminService
{
    /**
     * جلب قائمة المديرين الذين ينتظرون الموافقة
     */
    public function getPendingManagers()
    {
        return User::where('role', User::ROLE_MANAGER)
            ->where('status', User::STATUS_PENDING)
            ->get();
    }

    /**
     * تحديث حالة المستخدم بناءً على الدور
     */
    public function updateUserStatus($id, $role, $status)
    {
        $user = User::where('id', $id)
            ->where('role', $role)
            ->firstOrFail();

        $user->update(['status' => $status]);

        return $user;
    }
}
