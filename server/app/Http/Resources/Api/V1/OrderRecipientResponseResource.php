<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderRecipientResponseResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            /** @format uuid */
            'id' => $this->id,

            /** @format uuid */
            'order_recipient_id' => $this->order_recipient_id,

            'items' => OrderRecipientItemResponseResource::collection(
                $this->items,
            ),

            /** @format date-time */
            'created_at' => $this->created_at?->toISOString(),

            /** @format date-time */
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
