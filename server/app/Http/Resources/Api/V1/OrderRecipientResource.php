<?php

namespace App\Http\Resources\Api\V1;

use App\Enums\Order\FulfillmentStatus;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderRecipientResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $hasSelection = $this->items->contains(
            static fn ($item): bool => (int) ($item->response?->selection?->selected_quantity ?? 0) > 0,
        );

        $fulfillmentStatus = $this->fulfillment_status;

        if ($fulfillmentStatus === null && $hasSelection) {
            $fulfillmentStatus = FulfillmentStatus::Confirmed;
        }

        return [
            /** @format uuid */
            'id' => $this->id,

            /** @format uuid */
            'order_id' => $this->order_id,

            /** @format uuid */
            'supplier_id' => $this->supplier_id,
            'supplier_name' => $this->supplier_name,

            /** @var FulfillmentStatus|null */
            'fulfillment_status' => $fulfillmentStatus?->value,

            /** @var int */
            'fulfillment_version' => (int) $this->fulfillment_version,

            'order_status' => $this->order->status,
            'notes' => $this->order->notes,
            'items' => OrderRecipientItemResource::collection($this->items),
            'response' => new OrderRecipientResponseResource(
                $this->whenLoaded('response'),
            ),

            /** @format date-time */
            'created_at' => $this->created_at?->toISOString(),

            /** @format date-time */
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
