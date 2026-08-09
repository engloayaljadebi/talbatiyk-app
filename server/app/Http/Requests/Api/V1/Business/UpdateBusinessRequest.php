<?php

/*
|--------------------------------------------------------------------------
| التحقق من طلب تعديل النشاط التجاري - UpdateBusinessRequest
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التحقق من البيانات الأساسية المسموح بتعديلها.
| - دعم PATCH بحيث لا يلزم إرسال جميع الحقول.
| - تنظيف النصوص قبل تطبيق قواعد التحقق.
| - تحويل النصوص الاختيارية الفارغة إلى null.
| - منع تعديل الحقول التي لها Endpoints وقواعد مستقلة.
|
| الحقول المسموح بها:
| - name
| - legal_name
| - description
|
| الحقول الممنوعة من هذا الطلب:
| - status
| - capabilities
| - locations / location
| - contacts / contact
|
| ملاحظة:
| هذا الملف مسؤول عن Validation فقط.
| التحقق من owner / manager سيتم داخل BusinessAccessService.
| التحديث الفعلي سيتم داخل BusinessUpdateService.
|
*/

namespace App\Http\Requests\Api\V1\Business;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBusinessRequest extends FormRequest
{
    /**
     * يجب أن يكون هناك مستخدم مسجل الدخول.
     *
     * التحقق التفصيلي من صلاحية المستخدم داخل
     * النشاط مسؤولية BusinessAccessService.
     */
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    /**
     * قواعد تعديل البيانات الأساسية للنشاط.
     *
     * نستخدم sometimes لأن Endpoint التعديل
     * يعمل بأسلوب PATCH ولا يتطلب إرسال كل الحقول.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            /*
             * ----------------------------------------------------------------
             * البيانات الأساسية المسموح بتعديلها
             * ----------------------------------------------------------------
             */

            'name' => [
                'sometimes',
                'required',
                'string',
                'min:2',
                'max:200',
            ],

            'legal_name' => [
                'sometimes',
                'nullable',
                'string',
                'max:250',
            ],

            'description' => [
                'sometimes',
                'nullable',
                'string',
                'max:5000',
            ],

            /*
             * ----------------------------------------------------------------
             * حقول ممنوعة من Endpoint تعديل البيانات الأساسية
             * ----------------------------------------------------------------
             *
             * لكل مجموعة من هذه البيانات Endpoint مستقل لاحقًا.
             * استخدام prohibited يجعل الخطأ واضحًا بدل تجاهل
             * القيمة بصمت إذا حاول العميل إرسالها.
             */

            'status' => [
                'prohibited',
            ],

            'capabilities' => [
                'prohibited',
            ],

            'location' => [
                'prohibited',
            ],

            'locations' => [
                'prohibited',
            ],

            'contact' => [
                'prohibited',
            ],

            'contacts' => [
                'prohibited',
            ],
        ];
    }

    /**
     * تنظيف الحقول المرسلة فقط قبل Validation.
     *
     * مهم:
     * لا نقوم بإضافة حقل غير موجود في Request،
     * لأن PATCH يجب أن يعدل فقط ما أرسله العميل.
     */
    protected function prepareForValidation(): void
    {
        $normalized = [];

        if ($this->has('name')) {
            $normalized['name'] = trim(
                (string) $this->input('name'),
            );
        }

        if ($this->has('legal_name')) {
            $normalized['legal_name'] = $this->nullableTrimmed(
                $this->input('legal_name'),
            );
        }

        if ($this->has('description')) {
            $normalized['description'] = $this->nullableTrimmed(
                $this->input('description'),
            );
        }

        if ($normalized !== []) {
            $this->merge($normalized);
        }
    }

    /**
     * تنظيف النص الاختياري.
     *
     * أمثلة:
     *
     * "  شركة الجعدبي  "
     * تصبح:
     * "شركة الجعدبي"
     *
     * والسلسلة الفارغة:
     * ""
     *
     * تصبح:
     * null
     */
    private function nullableTrimmed(mixed $value): ?string
    {
        if (! is_string($value)) {
            return null;
        }

        $value = trim($value);

        return $value === ''
            ? null
            : $value;
    }
}
