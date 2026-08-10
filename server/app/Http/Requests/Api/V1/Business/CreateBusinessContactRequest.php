<?php

/*
|--------------------------------------------------------------------------
| طلب إنشاء وسيلة اتصال - CreateBusinessContactRequest
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التحقق من نوع وسيلة الاتصال وقيمتها.
| - دعم الهاتف وواتساب والبريد والموقع الإلكتروني.
| - توحيد البريد والنصوص قبل الحفظ.
| - منع تحديد مالك الوسيلة من Body.
| - منع تعديل التوثيق أو is_primary مباشرة.
|
| ملاحظة:
| مالك الوسيلة يحدد من URL:
| - النشاط نفسه.
| - أو أحد مواقع النشاط.
|
*/

namespace App\Http\Requests\Api\V1\Business;

use App\Support\ContactValueNormalizer;
use Closure;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CreateBusinessContactRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'type' => [
                'required',
                'string',
                Rule::in([
                    'phone',
                    'whatsapp',
                    'email',
                    'website',
                ]),
            ],

            'value' => [
                'required',
                'string',
                'max:500',
                function (
                    string $attribute,
                    mixed $value,
                    Closure $fail,
                ): void {
                    if (! is_string($value)) {
                        return;
                    }

                    $type = $this->input('type');

                    if (! is_string($type)) {
                        return;
                    }

                    $this->validateContactValue(
                        strtolower(trim($type)),
                        $value,
                        $fail,
                    );
                },
            ],

            'label' => [
                'nullable',
                'string',
                'max:100',
            ],

            /*
             * يتم تعيين الوسيلة الرئيسية
             * عبر Endpoint مستقل.
             */
            'is_primary' => [
                'prohibited',
            ],

            /*
             * التوثيق لا يمكن منحه من العميل.
             */
            'verified_at' => [
                'prohibited',
            ],

            /*
             * ملكية الوسيلة تحدد من URL فقط.
             */
            'business_id' => [
                'prohibited',
            ],

            'business_location_id' => [
                'prohibited',
            ],

            'location_id' => [
                'prohibited',
            ],
        ];
    }

    protected function prepareForValidation(): void
    {
        $normalized = [];

        if (
            $this->has('type')
            && is_string($this->input('type'))
        ) {
            $normalized['type'] = strtolower(
                trim($this->input('type')),
            );
        }

        if (
            $this->has('value')
            && is_string($this->input('value'))
        ) {
            $type = $normalized['type']
                ?? $this->input('type');

            if (is_string($type)) {
                $normalized['value'] = ContactValueNormalizer::contact(
                    $type,
                    $this->input('value'),
                );
            } else {
                $normalized['value'] = trim(
                    $this->input('value'),
                );
            }
        }

        if (
            $this->has('label')
            && is_string($this->input('label'))
        ) {
            $label = trim(
                $this->input('label'),
            );

            $normalized['label'] = $label === ''
                ? null
                : $label;
        }

        if ($normalized !== []) {
            $this->merge($normalized);
        }
    }

    /**
     * التحقق من صيغة القيمة حسب نوع الوسيلة.
     */
    private function validateContactValue(
        string $type,
        string $value,
        Closure $fail,
    ): void {
        if (
            in_array($type, ['phone', 'whatsapp'], true)
            && preg_match('/^\+[1-9]\d{7,14}$/', $value) !== 1
        ) {
            $fail(
                'يجب أن يكون رقم الهاتف بصيغة دولية E.164 مثل +967777123456.',
            );

            return;
        }

        if (
            $type === 'email'
            && filter_var($value, FILTER_VALIDATE_EMAIL) === false
        ) {
            $fail(
                'يجب إدخال بريد إلكتروني صحيح.',
            );

            return;
        }

        if (
            $type === 'website'
            && filter_var($value, FILTER_VALIDATE_URL) === false
        ) {
            $fail(
                'يجب إدخال رابط موقع إلكتروني صحيح.',
            );
        }
    }
}
