<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class StoreBaggageReportRequest extends FormRequest
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
            'flight_number'     => ['required', 'string', 'regex:/^[A-Z]{2}-\d{3,4}$/'], // e.g. FM-101
            'departure_city'    => ['required', 'string', 'max:255'],
            'arrival_city'      => ['required', 'string', 'max:255'],
            'arrival_date'      => ['required', 'date', 'before_or_equal:today'],
            'airport_code'      => ['required', 'string', 'size:3'], // IATA Code e.g. CAI
            'baggage_type'      => ['required', 'in:suitcase,backpack,hand_bag,other'],
            'baggage_size'      => ['required', 'in:small,medium,large'],
            'baggage_color'     => ['required', 'string', 'max:50'],
            'description'       => ['required', 'string', 'min:20'], // الحد الأدنى 20 حرف
            'distinctive_marks' => ['nullable', 'string', 'max:500'],
            'contact_phone'     => ['required', 'string', 'max:20'],
            'contact_email'     => ['required', 'email', 'max:255'],
            'delivery_address'  => ['nullable', 'string', 'max:500'],
        ];
    }
    public function messages()
    {
        return [
            'flight_number.regex' => 'صيغة رقم الرحلة غير صحيحة، يجب أن تكون مثل (FM-101).',
            'description.min'     => 'يجب أن يحتوي الوصف على 20 حرفاً على الأقل لتوضيح تفاصيل الحقيبة.',
            'airport_code.size'   => 'كود المطار يجب أن يتكون من 3 أحرف فقط (IATA).',
        ];
    }
}
