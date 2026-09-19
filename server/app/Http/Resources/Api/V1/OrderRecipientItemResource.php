<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderRecipientItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $orderItem = $this->orderItem;

        $selectedQuantity =
            $this->response?->selection?->selected_quantity;

        return [
            /** @format uuid */
            'id' => $this->id,

            'product_id' => $orderItem->product_id,
            'product_name' => $orderItem->product_name,
            'unit_price' => $orderItem->unit_price,
            'requested_quantity' => $orderItem->quantity,

            /** @var int|null */
            'selected_quantity' => $selectedQuantity,

            'image_url' => $orderItem->image_url,
        ];
    }
}
