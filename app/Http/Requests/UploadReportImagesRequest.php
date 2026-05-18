<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UploadReportImagesRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'image'      => ['required', 'image', 'mimes:jpeg,png,webp', 'max:10240'], // حد أقصى 10 ميغا بايت للصورة
            'image_type' => ['required', 'in:baggage,tag'], // نوع الصورة المرفوعة من المسافر
        ];
    }

    public function messages()
    {
        return [
            'image.max'   => 'حجم الصورة كبير جداً، الحد الأقصى المسموح به هو 10 ميغابايت.',
            'image.mimes' => 'صيغة الصورة غير مدعومة، يرجى رفع صورة بصيغة jpeg, png, أو webp.',
        ];
    }
}
