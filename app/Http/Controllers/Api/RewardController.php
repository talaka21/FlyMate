<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Reward;
use Illuminate\Http\Request;

class RewardController extends Controller
{
    /**
     * 1. جلب كل المكافآت المتاحة في النظام ليعرضها عامر بالـ Flutter
     */
    public function index()
    {
        $rewards = Reward::where('is_active', true)->get();

        return response()->json([
            'status' => 'success',
            'rewards' => $rewards
        ]);
    }

    /**
     * 2. جلب رصيد نقاط المستخدم الحالي فقط
     */
    public function getUserPoints(Request $request)
    {
        // العميل بيبعت الـ Token تبعه وبنعرف رصيده دغري
        $user = $request->user();

        return response()->json([
            'status' => 'success',
            'loyalty_points' => $user->loyalty_points ?? 0
        ]);
    }
}
