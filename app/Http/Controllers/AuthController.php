<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Http\Requests\RegisterPassengerRequest;
use App\Http\Requests\RegisterManagerRequest;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\VerifyMfaRequest;
use App\Services\AuthService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Exception;

class AuthController extends Controller
{
  use ApiResponse;

    protected $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    public function registerPassenger(RegisterPassengerRequest $request)
    {
        $result = $this->authService->registerPassenger($request->validated());

        return $this->success([
            'token' => $result['token'],
            'role'  => $result['user']->role,
            'user'  => $this->authService->formatUser($result['user']),
        ], __('auth.account_created'), 201);
    }

    public function registerManager(RegisterManagerRequest $request)
    {
        $this->authService->registerManager($request->validated());
        return $this->success(null, __('auth.registration_pending'), 201);
    }

    public function login(LoginRequest $request)
    {
        try {
            $result = $this->authService->login($request->validated());

            if ($result['requires_mfa']) {
                return $this->success([
                    'requires_mfa' => true,
                    ...$result['mfa_data']
                ], __('auth.mfa_code_sent'));
            }

            return $this->success([
                'token' => $result['token'],
                'role'  => $result['user']->role,
                'user'  => $this->authService->formatUser($result['user']),
            ]);
        } catch (Exception $e) {
            return $this->error($e->getMessage(), $e->getCode() ?: 400);
        }
    }

    public function verifyMfa(VerifyMfaRequest $request)
    {
        try {
            $result = $this->authService->verifyMfa($request->validated());
            return $this->success([
                'token' => $result['token'],
                'role'  => 'admin',
                'user'  => $this->authService->formatUser($result['user']),
            ]);
        } catch (Exception $e) {
            return $this->error($e->getMessage());
        }
    }

    public function logout(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $user->currentAccessToken()->delete();

        return $this->success(null, __('auth.logged_out'));
    }

    public function me(Request $request)
    {
        return $this->success([
            'user' => $this->authService->formatUser($request->user()),
            'role' => $request->user()->role,
        ]);
    }
}
