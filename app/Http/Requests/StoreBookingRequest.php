<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class StoreBookingRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'flight_id'       => 'required|exists:flights,id',
            'booking_type_id' => 'required|exists:booking_types,id',
            'seat_class'      => 'required|in:economy,business,first_class',
            'seats'           => 'required|array|min:1',
            'seats.*'         => 'required|exists:seats,id',
            'passengers'      => 'sometimes|integer|min:1|max:10',
            'adult_count'     => 'required|integer|min:1',
            'child_count'     => 'sometimes|integer|min:0',
            'infant_count'    => 'sometimes|integer|min:0',
        ];
    }
}
