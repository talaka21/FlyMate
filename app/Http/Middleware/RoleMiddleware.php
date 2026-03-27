<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, ...$roles): mixed
    {
        $user = Auth::user();

        // مش مسجل دخول
        if (!$user) {
            return response()->json([
                'status'  => 'Error',
                'message' => __('auth.unauthorized'),
                'data'    => null,
            ], 401);
        }

        // مش عنده الصلاحية
        if (!in_array($user->role, $roles)) {
            return response()->json([
                'status'  => 'Error',
                'message' => __('auth.access_denied'),
                'data'    => null,
            ], 403);
        }

        // المانجير لسا pending
        if ($user->isManager() && $user->isPending()) {
            return response()->json([
                'status'  => 'Error',
                'message' => __('auth.account_pending'),
                'data'    => null,
            ], 403);
        }

        // الحساب محظور
        if ($user->status === 'banned') {
            return response()->json([
                'status'  => 'Error',
                'message' => __('auth.account_banned'),
                'data'    => null,
            ], 403);
        }

        return $next($request);
    }
}
