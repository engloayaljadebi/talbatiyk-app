<?php

/*
|--------------------------------------------------------------------------
| التحقق من طلب تسجيل الدخول
|--------------------------------------------------------------------------
|
| يسمح بالدخول بواسطة:
| - username
| - email
| - phone
|
*/

namespace App\Http\Requests\Api\V1\Auth;

use App\Support\ContactValueNormalizer;
use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * تنظيف معرف الدخول قبل البحث.
     */
    protected function prepareForValidation(): void
    {
        $this->merge([
            'login' => ContactValueNormalizer::login(
                $this->input('login'),
            ),
            'device_name' => trim((string) $this->input('device_name')),
        ]);
    }

    public function rules(): array
    {
        return [
            'login' => [
                'required',
                'string',
                'max:320',
            ],

            'password' => [
                'required',
                'string',
            ],

            'device_name' => [
                'required',
                'string',
                'max:100',
            ],
        ];
    }
}
