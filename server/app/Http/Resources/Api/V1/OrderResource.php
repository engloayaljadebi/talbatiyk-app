<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    /**
     * الشكل العام للطلب في عقد الـ API.
     */
    public function toArray(Request $request): array
    {
        return [
            /** @format uuid */
            'id' => $this->id,

            'status' => $this->status,
            'notes' => $this->notes,

            // OrderService يحمّل items قبل إنشاء الـ Resource،
            // لذلك العناصر جزء إلزامي من Create Order response.
            'items' => OrderItemResource::collection($this->items),

            /** @format date-time */
            'created_at' => $this->created_at?->toISOString(),

            /** @format date-time */
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
