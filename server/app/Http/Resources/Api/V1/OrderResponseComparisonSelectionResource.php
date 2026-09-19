<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResponseComparisonSelectionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            /** @format uuid */
            'id' => $this->id,

            /** @format uuid */
            'order_recipient_item_response_id' => $this->order_recipient_item_response_id,

            /** @var int */
            'selected_quantity' => (int) $this->selected_quantity,
        ];
    }
}
