<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class SearchFlightsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }


    public function rules(): array
{
    return [
        'departure_date' => ['required', 'date', 'date_format:Y-m-d'],
        'origin'         => ['sometimes', 'string'],
        'destination'    => ['sometimes', 'string'],
        'class'          => ['sometimes', 'in:economy,business,first_class'],
        'passengers'     => ['sometimes', 'integer', 'min:1'],
    ];
}
}
