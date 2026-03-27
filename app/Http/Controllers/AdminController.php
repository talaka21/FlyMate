<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\AdminService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class AdminController extends Controller
{


    protected $adminService;

    public function __construct(AdminService $adminService)
    {
        $this->adminService = $adminService;
    }

    // ✅ Approve Manager
    public function approveManager($id)
    {
        $this->adminService->updateUserStatus($id, User::ROLE_MANAGER, User::STATUS_ACTIVE);
        return $this->success(null, __('admin.manager_approved'));
    }

    // ✅ Ban Passenger
    public function banPassenger($id)
    {
        $this->adminService->updateUserStatus($id, User::ROLE_PASSENGER, User::STATUS_BANNED);
        return $this->success(null, __('admin.passenger_banned'));
    }

    // ✅ Unban Passenger
    public function unbanPassenger($id)
    {
        $this->adminService->updateUserStatus($id, User::ROLE_PASSENGER, User::STATUS_ACTIVE);
        return $this->success(null, __('admin.passenger_unbanned'));
    }

    // ✅ Get Pending Managers
    public function pendingManagers()
    {
        $managers = $this->adminService->getPendingManagers();
        return $this->success($managers);
    }
}
