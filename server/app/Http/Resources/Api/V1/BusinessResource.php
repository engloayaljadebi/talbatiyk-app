<?php

/*
|--------------------------------------------------------------------------
| Resource النشاط التجاري
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تحديد الشكل الرسمي للنشاط داخل API.
| - تضمين الموقع الرئيسي ووسيلة الاتصال الرئيسية.
| - إظهار قدرات النشاط مثل supplier و shop.
| - إظهار عضوية المستخدم المالك عند تحميلها.
| - إبقاء الشكل مناسبًا للعقد OpenAPI وFlutter.
|
*/

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BusinessResource extends JsonResource
{
    /**
     * تحويل النشاط التجاري إلى JSON.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /*
         * أثناء Onboarding يوجد موقع رئيسي واحد.
         */
        $primaryLocation = $this->whenLoaded(
            'locations',
            fn () => $this->locations->firstWhere('is_primary', true),
        );

        /*
         * أثناء Onboarding يوجد اتصال رئيسي واحد.
         */
        $primaryContact = $this->whenLoaded(
            'contacts',
            fn () => $this->contacts->firstWhere('is_primary', true),
        );

        return [
            'id' => $this->id,
            'name' => $this->name,
            'legal_name' => $this->legal_name,
            'description' => $this->description,
            'status' => $this->status,

            /*
             * قدرات النشاط:
             *
             * supplier
             * shop
             */
            'capabilities' => $this->whenLoaded(
                'capabilities',
                fn () => $this->capabilities
                    ->filter(
                        fn ($capability): bool => $capability->pivot->disabled_at === null,
                    )
                    ->pluck('code')
                    ->values()
                    ->all(),
            ),

            /*
             * الموقع الرئيسي فقط في هذه الاستجابة.
             *
             * قائمة جميع الفروع سيكون لها Endpoint مستقل لاحقًا.
             */
            'primary_location' => $primaryLocation
                ? new BusinessLocationResource($primaryLocation)
                : null,

            /*
             * وسيلة الاتصال الرئيسية.
             */
            'primary_contact' => $primaryContact
                ? new BusinessContactResource($primaryContact)
                : null,

            /*
             * عضوية المستخدم الذي أنشأ النشاط.
             *
             * لا نعيد بيانات المستخدم مرة أخرى لأنها موجودة
             * أصلًا في Auth /me.
             */
            'membership' => $this->whenLoaded(
                'memberships',
                function (): ?array {
                    $membership = $this->memberships->first();

                    if ($membership === null) {
                        return null;
                    }

                    return [
                        'id' => $membership->id,
                        'status' => $membership->status,

                        'roles' => $membership->relationLoaded('roles')
                            ? $membership->roles
                                ->pluck('code')
                                ->values()
                                ->all()
                            : [],

                        'joined_at' => $membership->joined_at?->toISOString(),
                    ];
                },
            ),

            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
