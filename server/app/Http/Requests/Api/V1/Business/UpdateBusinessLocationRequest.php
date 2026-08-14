<?php

/*
|--------------------------------------------------------------------------
| طلب تعديل موقع نشاط تجاري - UpdateBusinessLocationRequest
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - دعم PATCH لموقع النشاط.
| - تعديل الحقول المرسلة فقط.
| - التحقق من النوع والحالة والإحداثيات.
| - تنظيف النصوص قبل Validation.
| - منع تغيير business_id و is_primary مباشرة.
|
*/

namespace App\Http\Requests\Api\V1\Business;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateBusinessLocationRequest extends FormRequest
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
                'sometimes',
                'required',
                'string',
                'min:2',
                'max:160',
            ],

            'type' => [
                'sometimes',
                'required',
                Rule::in([
                    'branch',
                    'office',
                    'warehouse',
                    'store',
                ]),
            ],

            'timezone' => [
                'sometimes',
                'required',
                'string',
                'timezone',
                'max:64',
            ],

            'country_code' => [
                'sometimes',
                'required',
                'string',
                'size:2',
                'alpha',
            ],

            'administrative_area' => [
                'sometimes',
                'nullable',
                'string',
                'max:160',
            ],

            'locality' => [
                'sometimes',
                'nullable',
                'string',
                'max:160',
            ],

            'district' => [
                'sometimes',
                'nullable',
                'string',
                'max:160',
            ],

            'street_address' => [
                'sometimes',
                'nullable',
                'string',
                'max:300',
            ],

            'address_notes' => [
                'sometimes',
                'nullable',
                'string',
                'max:500',
            ],

            'latitude' => [
                'sometimes',
                'nullable',
                'numeric',
                'between:-90,90',
                'required_with:longitude',
            ],

            'longitude' => [
                'sometimes',
                'nullable',
                'numeric',
                'between:-180,180',
                'required_with:latitude',
            ],

            'status' => [
                'sometimes',
                'required',
                Rule::in([
                    'active',
                    'temporarily_closed',
                    'closed',
                ]),
            ],

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
