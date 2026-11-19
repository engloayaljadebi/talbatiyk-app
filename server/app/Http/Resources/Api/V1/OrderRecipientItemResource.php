<?php

namespace App\Http\Resources\Api\V1;

use App\Support\PublicDiskUrl;
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

            'item_type' => $orderItem->item_type,

            // Null for manual items.
            /** @var string|null */
            'product_id' => $orderItem->product_id,
            'product_name' => $orderItem->product_name,
            'unit_price' => $orderItem->unit_price,
            'requested_quantity' => $orderItem->quantity,
            /** @var string|null */
            'unit' => $orderItem->unit,
            /** @var string|null */
            'note' => $orderItem->note,

            /** @var int|null */
            'selected_quantity' => $selectedQuantity,

            'image_url' => PublicDiskUrl::resolve(
                $orderItem->image_url,
            ),
        ];
    }
}
