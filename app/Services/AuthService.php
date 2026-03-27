<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;
use Exception;

class AuthService
{
    public function registerPassenger(array $data)
    {
        $user = User::create([
            ...$data,
            'password' => Hash::make($data['password']),
            'role'     => 'passenger',
            'status'   => 'active',
        ]);

        $token = $user->createToken('passenger-token')->plainTextToken;

        return ['user' => $user, 'token' => $token];
    }

    public function registerManager(array $data)
    {
        return User::create([
            ...$data,
            'password' => Hash::make($data['password']),
            'role'     => 'manager',
            'status'   => 'pending',
        ]);
    }

    public function login(array $credentials)
    {
        if (!Auth::attempt($credentials)) {
            throw new Exception(__('auth.invalid_credentials'), 401);
        }

        $user = Auth::user();

        if ($user->isManager() && $user->isPending()) {
            throw new Exception(__('auth.account_pending'), 403);
        }

        if ($user->status === 'banned') {
            throw new Exception(__('auth.account_banned'), 403);
        }

        if ($user->isAdmin()) {
            return ['requires_mfa' => true, 'user' => $user, 'mfa_data' => $this->sendMfaCode($user)];
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return ['requires_mfa' => false, 'user' => $user, 'token' => $token];
    }

    private function sendMfaCode(User $user)
    {
        $code = rand(100000, 999999);

        $user->update([
            'mfa_code'       => Hash::make($code),
            'mfa_expires_at' => Carbon::now()->addMinutes(10),
        ]);

        return [
            'email'    => $user->email,
            'mfa_code' => $code, // ⚠️ إزالة في الإنتاج
        ];
    }

    public function verifyMfa(array $data)
    {
        $user = User::where('email', $data['email'])->first();

        if (!$user || !$user->isAdmin()) {
            throw new Exception(__('auth.unauthorized'));
        }

        if (Carbon::now()->isAfter($user->mfa_expires_at)) {
            throw new Exception(__('auth.token_expired'));
        }

        if (!Hash::check($data['code'], $user->mfa_code)) {
            throw new Exception(__('auth.invalid_mfa'));
        }

        $user->update([
            'mfa_code'       => null,
            'mfa_expires_at' => null,
        ]);

        $token = $user->createToken('admin-token')->plainTextToken;

        return ['user' => $user, 'token' => $token];
    }

    public function formatUser(User $user): array
    {
        return [
            'id'          => $user->id,
            'name'        => $user->name,
            'email'       => $user->email,
            'role'        => $user->role,
            'status'      => $user->status,
            'employee_id' => $user->employee_id,
        ];
    }
}
