<?php

/*
|--------------------------------------------------------------------------
| Resource موقع النشاط التجاري
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إخراج بيانات الفرع أو الموقع بشكل ثابت.
| - فصل العنوان عن بيانات النشاط الأساسية.
| - إرسال الإحداثيات عند توفرها.
| - تجهيز الاستجابة للاستخدام المباشر في Flutter.
|
*/

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BusinessLocationResource extends JsonResource
{
    /**
     * تحويل الموقع إلى JSON.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'type' => $this->type,
            'timezone' => $this->timezone,

            'address' => [
                'country_code' => $this->country_code,
                'administrative_area' => $this->administrative_area,
                'locality' => $this->locality,
                'district' => $this->district,
                'street_address' => $this->street_address,
                'notes' => $this->address_notes,
            ],

            /*
             * نضع الإحداثيات في كائن مستقل،
             * وهذا يسهل لاحقًا ربطها بالخريطة في Flutter.
             */
            'coordinates' => [
                'latitude' => $this->latitude !== null
                    ? (float) $this->latitude
                    : null,

                'longitude' => $this->longitude !== null
                    ? (float) $this->longitude
                    : null,
            ],

            'is_primary' => (bool) $this->is_primary,
            'status' => $this->status,

            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
