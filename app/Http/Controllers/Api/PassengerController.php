<?php

namespace App\Http\Controllers\Api;

use App\Http\Resources\BookingResource;
use App\Http\Controllers\Controller;
use App\Http\Requests\UpdateProfileRequest;
use App\Http\Requests\ChangePasswordRequest;
use App\Http\Requests\DeleteAccountRequest;
use App\Http\Requests\SearchFlightsRequest;
use App\Services\PassengerService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Exception;

class PassengerController extends Controller
{
    use ApiResponse;

    protected $passengerService;

    public function __construct(PassengerService $passengerService)
    {
        $this->passengerService = $passengerService;
    }

    public function profile(Request $request)
    {
        return $this->success($request->user());
    }

    public function updateProfile(UpdateProfileRequest $request)
    {
        $user = $this->passengerService->updateProfile($request->user(), $request->validated());
        return $this->success($user, __('passenger.profile_updated'));
    }

    public function changePassword(ChangePasswordRequest $request)
    {
        try {
            $this->passengerService->changePassword($request->user(), $request->validated());
            return $this->success(null, __('passenger.password_changed'));
        } catch (Exception $e) {
            return $this->error($e->getMessage());
        }
    }

    public function deleteAccount(DeleteAccountRequest $request)
    {
        try {
            $this->passengerService->deleteAccount($request->user(), $request->validated());
            return $this->success(null, __('passenger.account_deleted'));
        } catch (Exception $e) {
            return $this->error($e->getMessage());
        }
    }

    public function searchFlights(SearchFlightsRequest $request)
    {
        try {
            $flights = $this->passengerService->searchFlights($request->validated());
            return $this->success($flights, __('flights.found'));
        } catch (Exception $e) {
            return $this->error(__('flights.not_found'), 404);
        }
    }

    public function showBoardingPass($id)
{
    try {
        $data = $this->passengerService->generateBoardingData($id);
        return $this->success(new BookingResource($data['booking']));
    } catch (Exception $e) {
        return $this->error("Ticket not found", 404);
    }
}
}
