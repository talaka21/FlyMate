<?php
namespace App\Traits;

use Illuminate\Http\JsonResponse;

trait ApiResponse
{
    /**
     * استجابة ناجحة موحدة
     */
    protected function success($data, string $message = null, int $code = 200): JsonResponse
    {
        return response()->json([
            'status'  => 'Success',
            'message' => $message,
            'data'    => $data
        ], $code);
    }

    /**
     * استجابة خطأ موحدة
     */
    protected function error(string $message = null, int $code = 400): JsonResponse
    {
        return response()->json([
            'status'  => 'Error',
            'message' => $message,
            'data'    => null
        ], $code);
    }
}
