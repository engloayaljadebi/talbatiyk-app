<?php

/*
|--------------------------------------------------------------------------
| Resource وسيلة اتصال النشاط
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تحديد الشكل الرسمي لوسيلة الاتصال في API.
| - عدم كشف أعمدة داخلية غير لازمة لتطبيق Flutter.
| - المحافظة على شكل ثابت للاستجابة.
|
*/

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BusinessContactResource extends JsonResource
{
    /**
     * تحويل وسيلة الاتصال إلى JSON.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type,
            'value' => $this->value,
            'label' => $this->label,
            'is_primary' => (bool) $this->is_primary,

            /*
             * لا نرسل verified_at فقط كقيمة منطقية،
             * بل نرسل الحالة والتاريخ للاستفادة منهما مستقبلًا.
             */
            'is_verified' => $this->verified_at !== null,

            'verified_at' => $this->verified_at?->toISOString(),
        ];
    }
}
