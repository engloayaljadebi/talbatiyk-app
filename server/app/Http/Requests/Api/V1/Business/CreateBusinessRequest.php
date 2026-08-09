<?php

/*
|--------------------------------------------------------------------------
| التحقق من طلب إنشاء نشاط تجاري
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التحقق من الهوية الأساسية للنشاط.
| - التحقق من القدرات التجارية مثل supplier و shop.
| - التحقق من بيانات الموقع الرئيسي.
| - التحقق من وسيلة الاتصال الرئيسية.
| - توحيد البريد والهاتف والدولة قبل الحفظ.
| - منع وصول قيم غير متوافقة مع قيود PostgreSQL.
|
| ملاحظة:
| هذا الملف لا ينشئ أي سجلات.
| الإنشاء الفعلي سيتم داخل BusinessOnboardingService
| في Transaction واحدة.
|
*/

namespace App\Http\Requests\Api\V1\Business;

use App\Support\ContactValueNormalizer;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CreateBusinessRequest extends FormRequest
{
    /**
     * يجب أن يكون المستخدم مسجل الدخول.
     *
     * الحماية الفعلية للمسار ستكون عبر auth:sanctum.
     */
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    /**
     * قواعد التحقق من بيانات إنشاء النشاط.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        $contactType = $this->string('contact.type')->toString();

        $contactValueRules = [
            'required',
            'string',
            'max:500',
        ];

        /*
         * نضيف قاعدة مناسبة حسب نوع وسيلة الاتصال.
         */
        if ($contactType === 'email') {
            $contactValueRules[] = 'email:rfc';
        }

        if (in_array($contactType, ['phone', 'whatsapp'], true)) {
            /*
             * صيغة E.164:
             * +967777123456
             */
            $contactValueRules[] = 'regex:/^\+[1-9]\d{7,14}$/';
        }

        if ($contactType === 'website') {
            $contactValueRules[] = 'url:http,https';
        }

        return [
            /*
             * ----------------------------------------------------------------
             * بيانات النشاط الأساسية
             * ----------------------------------------------------------------
             */
            'name' => [
                'required',
                'string',
                'min:2',
                'max:200',
            ],

            'legal_name' => [
                'nullable',
                'string',
                'max:250',
            ],

            'description' => [
                'nullable',
                'string',
                'max:5000',
            ],

            /*
             * ----------------------------------------------------------------
             * قدرات النشاط
             * ----------------------------------------------------------------
             *
             * مثال:
             *
             * capabilities:
             * - supplier
             * - shop
             *
             * لا نقبل قدرة متوقفة retired_at.
             */
            'capabilities' => [
                'required',
                'array',
                'min:1',
                'max:2',
            ],

            'capabilities.*' => [
                'required',
                'string',
                'distinct',
                Rule::exists('business_capabilities', 'code')
                    ->whereNull('retired_at'),
            ],

            /*
             * ----------------------------------------------------------------
             * الموقع الرئيسي
             * ----------------------------------------------------------------
             */
            'location' => [
                'required',
                'array',
            ],

            'location.name' => [
                'required',
                'string',
                'min:2',
                'max:160',
            ],

            'location.type' => [
                'required',
                Rule::in([
                    'branch',
                    'office',
                    'warehouse',
                    'store',
                ]),
            ],

            /*
             * Laravel يتحقق أن القيمة اسم Timezone صالح.
             *
             * مثال:
             * Asia/Aden
             */
            'location.timezone' => [
                'required',
                'string',
                'timezone',
                'max:64',
            ],

            /*
             * ISO 3166-1 alpha-2
             *
             * اليمن:
             * YE
             */
            'location.country_code' => [
                'required',
                'string',
                'size:2',
                'alpha',
            ],

            'location.administrative_area' => [
                'nullable',
                'string',
                'max:160',
            ],

            'location.locality' => [
                'nullable',
                'string',
                'max:160',
            ],

            'location.district' => [
                'nullable',
                'string',
                'max:160',
            ],

            'location.street_address' => [
                'nullable',
                'string',
                'max:300',
            ],

            'location.address_notes' => [
                'nullable',
                'string',
                'max:500',
            ],

            /*
             * إذا تم إرسال أحد الإحداثيين يجب إرسال الآخر أيضًا.
             *
             * PostgreSQL لديه كذلك CHECK constraints،
             * لكننا نرفض الخطأ مبكرًا من طبقة API.
             */
            'location.latitude' => [
                'nullable',
                'numeric',
                'between:-90,90',
                'required_with:location.longitude',
            ],

            'location.longitude' => [
                'nullable',
                'numeric',
                'between:-180,180',
                'required_with:location.latitude',
            ],

            /*
             * ----------------------------------------------------------------
             * وسيلة الاتصال الرئيسية للنشاط
             * ----------------------------------------------------------------
             *
             * هذه الوسيلة ستكون مرتبطة بـ business_id،
             * وليست مرتبطة بالفرع الرئيسي.
             */
            'contact' => [
                'required',
                'array',
            ],

            'contact.type' => [
                'required',
                Rule::in([
                    'phone',
                    'whatsapp',
                    'email',
                    'website',
                ]),
            ],

            'contact.value' => $contactValueRules,

            'contact.label' => [
                'nullable',
                'string',
                'max:100',
            ],
        ];
    }

    /**
     * توحيد البيانات قبل تطبيق قواعد التحقق.
     */
    protected function prepareForValidation(): void
    {
        $contactType = strtolower(
            trim((string) $this->input('contact.type')),
        );

        $contactValue = ContactValueNormalizer::contact(
            $contactType,
            $this->input('contact.value'),
        );

        /*
         * website لا يحتاج lowercase بشكل عام،
         * لذلك نترك ContactValueNormalizer كما هو.
         */

        $capabilities = collect(
            $this->input('capabilities', []),
        )
            ->filter(fn ($value): bool => is_string($value))
            ->map(
                fn (string $value): string => strtolower(trim($value)),
            )
            ->values()
            ->all();

        $this->merge([
            'name' => trim((string) $this->input('name')),

            'legal_name' => $this->nullableTrimmed(
                $this->input('legal_name'),
            ),

            'description' => $this->nullableTrimmed(
                $this->input('description'),
            ),

            'capabilities' => $capabilities,

            'location' => [
                ...((array) $this->input('location', [])),

                'name' => trim(
                    (string) $this->input('location.name'),
                ),

                'type' => strtolower(
                    trim((string) $this->input('location.type')),
                ),

                'timezone' => trim(
                    (string) $this->input('location.timezone'),
                ),

                'country_code' => strtoupper(
                    trim(
                        (string) $this->input(
                            'location.country_code',
                        ),
                    ),
                ),

                'administrative_area' => $this->nullableTrimmed(
                    $this->input('location.administrative_area'),
                ),

                'locality' => $this->nullableTrimmed(
                    $this->input('location.locality'),
                ),

                'district' => $this->nullableTrimmed(
                    $this->input('location.district'),
                ),

                'street_address' => $this->nullableTrimmed(
                    $this->input('location.street_address'),
                ),

                'address_notes' => $this->nullableTrimmed(
                    $this->input('location.address_notes'),
                ),
            ],

            'contact' => [
                ...((array) $this->input('contact', [])),

                'type' => $contactType,

                'value' => $contactValue,

                'label' => $this->nullableTrimmed(
                    $this->input('contact.label'),
                ),
            ],
        ]);
    }

    /**
     * تنظيف قيمة نصية اختيارية.
     *
     * السلسلة الفارغة تتحول إلى null حتى لا نخزن
     * بيانات فارغة بلا معنى داخل PostgreSQL.
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
