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
use App\Rules\MaxBytes;
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
        if ($this->exists('account_type')) {
            $this->merge([
                'account_type' => strtolower(trim((string) $this->input('account_type'))),
            ]);
        }

        if ($this->exists('business_contact_type')) {
            $this->merge([
                'business_contact_type' => strtolower(trim((string) $this->input('business_contact_type'))),
            ]);
        }

        if ($this->exists('business_contact_value')) {
            $this->merge([
                'business_contact_value' => ContactValueNormalizer::contact(
                    (string) $this->input('business_contact_type'),
                    $this->input('business_contact_value'),
                ),
            ]);
        }

        foreach (['nationality_country_code', 'country_code'] as $field) {
            if ($this->exists($field)) {
                $this->merge([
                    $field => strtoupper(trim((string) $this->input($field))),
                ]);
            }
        }

        if ($this->exists('location_type')) {
            $this->merge([
                'location_type' => strtolower(trim((string) $this->input('location_type'))),
            ]);
        }

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
                ContactValueNormalizer::USERNAME_VALIDATION_RULE,
            ],

            'display_name' => [
                'required',
                'string',
                'min:2',
                'max:160',
            ],

            'password' => [
                'bail',
                'required',
                'confirmed',
                Password::min(8),
                'max:72',
                new MaxBytes(72),
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
                    ['regex:/^[0-9]{9}$/'],
                ),
            ],

            'account_type' => [
                'required', Rule::in(['shop', 'supplier']),
            ],
            'nationality_country_code' => [
                'nullable', 'string', 'size:2', 'regex:/^[A-Z]{2}$/',
            ],
            'birth_date' => [
                'nullable', 'date_format:Y-m-d', 'before_or_equal:today',
            ],
            'name' => [
                'required_with:account_type', 'string', 'min:2', 'max:200',
            ],
            'legal_name' => ['nullable', 'string', 'max:250'],
            'description' => ['nullable', 'string', 'max:5000'],
            'category_id' => [
                'required_with:account_type', 'uuid',
            ],
            'location_name' => [
                'required_with:account_type', 'string', 'min:2', 'max:160',
            ],
            'location_type' => [
                'nullable', Rule::in(['branch', 'office', 'warehouse', 'store']),
            ],
            'timezone' => ['nullable', 'string', 'timezone', 'max:64'],
            'country_code' => [
                'nullable', 'string', 'size:2', 'regex:/^[A-Z]{2}$/',
            ],
            'administrative_area' => [
                'required_with:account_type', 'string', 'min:2', 'max:160',
            ],
            'locality' => [
                'required_with:account_type', 'string', 'min:2', 'max:160',
            ],
            'district' => ['nullable', 'string', 'max:160'],
            'street_address' => ['nullable', 'string', 'max:300'],
            'address_notes' => ['nullable', 'string', 'max:2000'],
            'latitude' => [
                'nullable', 'numeric', 'between:-90,90',
                'required_with:longitude',
            ],
            'longitude' => [
                'nullable', 'numeric', 'between:-180,180',
                'required_with:latitude',
            ],
            'business_contact_type' => [
                'nullable',
                'required_with:business_contact_value',
                Rule::in(['phone', 'whatsapp', 'email', 'website']),
            ],
            'business_contact_value' => [
                'nullable',
                'required_with:business_contact_type',
                'string',
                'max:500',
                ...match ($this->input('business_contact_type')) {
                    'email' => ['email:rfc'],
                    'phone', 'whatsapp' => ['regex:/^\+[1-9]\d{7,14}$/'],
                    'website' => ['url:http,https'],
                    default => [],
                },
            ],
            'business_contact_label' => [
                'nullable', 'string', 'max:120',
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
