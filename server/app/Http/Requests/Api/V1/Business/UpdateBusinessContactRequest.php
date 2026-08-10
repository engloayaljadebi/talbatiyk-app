<?php

/*
|--------------------------------------------------------------------------
| طلب تعديل وسيلة اتصال - UpdateBusinessContactRequest
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - دعم PATCH لوسيلة الاتصال.
| - تعديل القيمة أو الوصف فقط.
| - تنظيف النصوص قبل التحقق.
| - منع تغيير نوع الوسيلة بعد إنشائها.
| - منع تغيير المالك أو التوثيق أو is_primary مباشرة.
|
| ملاحظة:
| نوع الوسيلة ثابت بعد الإنشاء.
| إذا أريد تغيير النوع تنشأ وسيلة جديدة بدل تحويل القديمة.
|
*/

namespace App\Http\Requests\Api\V1\Business;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBusinessContactRequest extends FormRequest
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
            /*
             * يتم التحقق من صيغة value حسب النوع الحالي
             * داخل BusinessContactService بعد التحقق
             * من صلاحية المستخدم وملكية Contact.
             */
            'value' => [
                'sometimes',
                'required',
                'string',
                'max:500',
            ],

            'label' => [
                'sometimes',
                'nullable',
                'string',
                'max:100',
            ],

            /*
             * تغيير النوع قد يغيّر قواعد التكرار
             * والوسيلة الرئيسية، لذلك لا يسمح به.
             */
            'type' => [
                'prohibited',
            ],

            'is_primary' => [
                'prohibited',
            ],

            'verified_at' => [
                'prohibited',
            ],

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
            $this->has('value')
            && is_string($this->input('value'))
        ) {
            $normalized['value'] = trim(
                $this->input('value'),
            );
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
}
