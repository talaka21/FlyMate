<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBaggageStatusRequest extends FormRequest
{
    public function authorize()
    {
        // هنا يمكن التحقق لاحقاً إذا كان المستخدم موظفاً (Admin/Staff)
        return true;
    }

    public function rules()
    {
        return [
            'status'  => ['required', 'in:pending_review,sent_to_airport,searching,found,in_delivery,delivered,closed'],
            'comment' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
