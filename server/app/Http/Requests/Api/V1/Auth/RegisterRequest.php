<?php

/*
|--------------------------------------------------------------------------
| التحقق من طلب إنشاء الحساب
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التحقق من بيانات المستخدم.
| - التحقق من نوع وسيلة الاتصال.
| - فرض صيغة E.164 للهاتف.
| - منع اسم مستخدم أو وسيلة اتصال مستخدمة مسبقًا.
| - توحيد القيم قبل وصولها إلى AuthService.
|
*/

namespace App\Http\Requests\Api\V1\Auth;

use App\Models\User;
use App\Models\UserContact;
use App\Support\ContactValueNormalizer;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\Validator;

class RegisterRequest extends FormRequest
{
    /**
     * التسجيل متاح بدون مصادقة.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * توحيد البيانات قبل التحقق.
     */
    protected function prepareForValidation(): void
    {
        $contactType = strtolower(trim((string) $this->input('contact_type')));

        $this->merge([
            'username' => ContactValueNormalizer::username(
                $this->input('username'),
            ),
            'contact_type' => $contactType,
            'contact_value' => ContactValueNormalizer::contact(
                $contactType,
                $this->input('contact_value'),
            ),
            'device_name' => trim((string) $this->input('device_name')),
        ]);
    }

    /**
     * قواعد التحقق.
     */
    public function rules(): array
    {
        return [
            'username' => [
                'required',
                'string',
                'min:3',
                'max:50',
                'regex:/^[\pL\pN._-]+$/u',
            ],

            'display_name' => [
                'required',
                'string',
                'min:2',
                'max:160',
            ],

            'password' => [
                'required',
                'confirmed',
                Password::min(8),
            ],

            'contact_type' => [
                'required',
                Rule::in(['phone', 'email']),
            ],

            'contact_value' => [
                'required',
                'string',
                'max:320',

                Rule::when(
                    $this->input('contact_type') === 'email',
                    ['email:rfc'],
                    ['regex:/^\+[1-9]\d{7,14}$/'],
                ),
            ],

            'device_name' => [
                'required',
                'string',
                'max:100',
            ],
        ];
    }

    /**
     * فحوصات PostgreSQL المنطقية التي تحتاج مقارنة
     * غير حساسة لحالة الأحرف.
     */
    public function after(): array
    {
        return [
            function (Validator $validator): void {
                if ($validator->errors()->isNotEmpty()) {
                    return;
                }

                $usernameExists = User::query()
                    ->whereRaw(
                        'LOWER(username) = ?',
                        [$this->string('username')->lower()->toString()],
                    )
                    ->exists();

                if ($usernameExists) {
                    $validator->errors()->add(
                        'username',
                        'اسم المستخدم مستخدم مسبقًا.',
                    );
                }

                $type = $this->string('contact_type')->toString();
                $value = $this->string('contact_value')->toString();

                $contactQuery = UserContact::query()
                    ->where('type', $type);

                if ($type === 'email') {
                    $contactQuery->whereRaw(
                        'LOWER(value) = ?',
                        [strtolower($value)],
                    );
                } else {
                    $contactQuery->where('value', $value);
                }

                if ($contactQuery->exists()) {
                    $validator->errors()->add(
                        'contact_value',
                        'وسيلة الاتصال مستخدمة في حساب آخر.',
                    );
                }
            },
        ];
    }
}
