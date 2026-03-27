<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\PayBookingRequest;
use App\Services\PaymentService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Exception;

class PaymentController extends Controller
{
    use ApiResponse;

    protected $paymentService;

    public function __construct(PaymentService $paymentService)
    {
        $this->paymentService = $paymentService;
    }

    /**
     * تنفيذ عملية الدفع
     */
    public function pay(PayBookingRequest $request, $id)
    {
        try {
            $booking = $request->user()->bookings()->findOrFail($id);

            $result = $this->paymentService->processPayment(
                $booking,
                $request->validated(),
                $request->user()
            );

            return $this->success($result, __('payments.success'));

        } catch (Exception $e) {
            return $this->error($e->getMessage());
        }
    }
}
