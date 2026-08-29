<?php

namespace App\Http\Resources\Api\V1;

use App\Enums\Order\AvailabilityStatus;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderRecipientItemResponseResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            /** @format uuid */
            'id' => $this->id,

            /** @format uuid */
            'order_recipient_item_id' => $this->order_recipient_item_id,

            /** @var int */
            'requested_quantity' => $this->requested_quantity,

            /** @var int */
            'available_quantity' => $this->available_quantity,

            /** @var AvailabilityStatus */
            'availability_status' => $this->availability_status->value,

            /** @var string|null */
            'offered_unit_price' => $this->offered_unit_price,

            /** @var string|null */
            'response_notes' => $this->response_notes,

            /** @format date-time */
            'created_at' => $this->created_at?->toISOString(),

            /** @format date-time */
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
