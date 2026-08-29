<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderRecipientResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            /** @format uuid */
            'id' => $this->id,

            /** @format uuid */
            'order_id' => $this->order_id,

            /** @format uuid */
            'supplier_id' => $this->supplier_id,
            'supplier_name' => $this->supplier_name,

            'order_status' => $this->order->status,
            'notes' => $this->order->notes,
            'items' => OrderRecipientItemResource::collection($this->items),

            /** @format date-time */
            'created_at' => $this->created_at?->toISOString(),

            /** @format date-time */
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
