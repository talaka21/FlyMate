<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class SearchFlightsRequest extends FormRequest
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
   public function rules(): array
{
    return [
        'date' => ['required', 'date', 'date_format:Y-m-d'],

        'origin' => 'sometimes|nullable|string',
        'destination' => 'sometimes|nullable|string',

        'passengers' => 'sometimes|integer|min:1',
        'class' => 'sometimes|in:economy,business,first_class',
    ];
}
}
