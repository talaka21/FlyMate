<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class CurrencyController extends Controller
{
    /**
     * محول العملات الشامل والمفتوح مع قيم افتراضية ذكية
     */
    public function convertCurrency(Request $request)
    {
        // 1. عملة الانطلاق (الأساس): إذا ما حددها المسافر، الافتراضي هو السوري SYP
        $baseCurrency = strtoupper($request->query('base_currency', 'SYP'));

        // 2. العملة المستهدفة (المراد التحويل إليها): إذا ما حددها، الافتراضي هو الدرهم AED
        $targetCurrency = strtoupper($request->query('target_currency', 'AED'));

        // 3. المبلغ المراد تحويله: الافتراضي 1 إذا لم يرسل قيمة
        $amount = floatval($request->query('amount', 1));

        // جلب المفتاح السري من ملف الـ .env
        $apiKey = env('EXCHANGE_RATE_API_KEY');

        // 4. ضرب الـ API الخارجي بديناميكية بناءً على عملة الأساس الممررة ($baseCurrency)
        $response = Http::get("https://v6.exchangerate-api.com/v6/{$apiKey}/latest/{$baseCurrency}");

        if ($response->failed()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to fetch live currency rates. Please check your Base Currency.'
            ], 500);
        }

        $rates = $response->json()['conversion_rates'];

        // التأكد من أن العملة المستهدفة مدعومة في مصفوفة الأسعار القادمة
        if (!isset($rates[$targetCurrency])) {
            return response()->json([
                'status' => 'Error',
                'message' => "The target currency [{$targetCurrency}] is not supported."
            ], 400);
        }

        // سعر الصرف: كم تساوى الوحدة الواحدة من عملة الأساس مقابل العملة المستهدفة
        $exchangeRate = $rates[$targetCurrency];

        // الحسبة الشاملة: ضرب المبلغ بسعر الصرف الديناميكي
        $convertedAmount = $amount * $exchangeRate;

        // حساب العكس (كم تساوي الوحدة من العملة المستهدفة مقابل عملة الأساس)
        $oneUnitToBase = 1 / $exchangeRate;

        return response()->json([
            'status' => 'Success',
            'message' => 'Currency conversion calculated successfully',
            'query' => [
                'amount' => $amount,
                'from' => $baseCurrency,
                'to' => $targetCurrency
            ],
            'data' => [
                'converted_result' => round($convertedAmount, 4), // النتيجة النهائية للمبلغ
                'rate_1_' . strtolower($baseCurrency) . '_equals' => round($exchangeRate, 6),
                'rate_1_' . strtolower($targetCurrency) . '_equals_' . strtolower($baseCurrency) => round($oneUnitToBase, 2),
            ]
        ]);
    }
}
