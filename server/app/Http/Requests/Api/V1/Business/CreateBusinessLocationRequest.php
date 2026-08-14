<?php

/*
|--------------------------------------------------------------------------
| طلب إنشاء موقع نشاط تجاري - CreateBusinessLocationRequest
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التحقق من بيانات الفرع أو المتجر أو المكتب أو المخزن.
| - التحقق من المنطقة الزمنية والعنوان والإحداثيات.
| - توحيد القيم النصية قبل الحفظ.
| - منع تحديد is_primary مباشرة من هذا Endpoint.
|
| ملاحظة:
| تحديد الموقع الرئيسي يتم عبر Endpoint مستقل.
|
*/

namespace App\Http\Requests\Api\V1\Business;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CreateBusinessLocationRequest extends FormRequest
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
            'name' => [
                'required',
                'string',
                'min:2',
                'max:160',
            ],

            'type' => [
                'required',
                Rule::in([
                    'branch',
                    'office',
                    'warehouse',
                    'store',
                ]),
            ],

            'timezone' => [
                'required',
                'string',
                'timezone',
                'max:64',
            ],

            'country_code' => [
                'required',
                'string',
                'size:2',
                'alpha',
            ],

            'administrative_area' => [
                'nullable',
                'string',
                'max:160',
            ],

            'locality' => [
                'nullable',
                'string',
                'max:160',
            ],

            'district' => [
                'nullable',
                'string',
                'max:160',
            ],

            'street_address' => [
                'nullable',
                'string',
                'max:300',
            ],

            'address_notes' => [
                'nullable',
                'string',
                'max:500',
            ],

            /*
             * إذا أرسل أحد الإحداثيين
             * فيجب إرسال الآخر معه.
             */
            'latitude' => [
                'nullable',
                'numeric',
                'between:-90,90',
                'required_with:longitude',
            ],

            'longitude' => [
                'nullable',
                'numeric',
                'between:-180,180',
                'required_with:latitude',
            ],

            'status' => [
                'sometimes',
                Rule::in([
                    'active',
                    'temporarily_closed',
                    'closed',
                ]),
            ],

            /*
             * الموقع الرئيسي يُدار بعملية مستقلة
             * لمنع وجود منطق متعارض.
             */
            /** @hidden */
            'is_primary' => [
                'prohibited',
            ],

            /** @hidden */
            'business_id' => [
                'prohibited',
            ],
        ];
    }

    protected function prepareForValidation(): void
    {
        $normalized = [];

        if ($this->has('name') && is_string($this->input('name'))) {
            $normalized['name'] = trim(
                $this->input('name'),
            );
        }

        if ($this->has('type') && is_string($this->input('type'))) {
            $normalized['type'] = strtolower(
                trim($this->input('type')),
            );
        }

        if ($this->has('timezone') && is_string($this->input('timezone'))) {
            $normalized['timezone'] = trim(
                $this->input('timezone'),
            );
        }

        if (
            $this->has('country_code')
            && is_string($this->input('country_code'))
        ) {
            $normalized['country_code'] = strtoupper(
                trim($this->input('country_code')),
            );
        }

        foreach ([
            'administrative_area',
            'locality',
            'district',
            'street_address',
            'address_notes',
        ] as $field) {
            if (
                $this->has($field)
                && is_string($this->input($field))
            ) {
                $value = trim($this->input($field));

                $normalized[$field] = $value === ''
                    ? null
                    : $value;
            }
        }

        if (
            $this->has('status')
            && is_string($this->input('status'))
        ) {
            $normalized['status'] = strtolower(
                trim($this->input('status')),
            );
        }

        if ($normalized !== []) {
            $this->merge($normalized);
        }
    }
}
