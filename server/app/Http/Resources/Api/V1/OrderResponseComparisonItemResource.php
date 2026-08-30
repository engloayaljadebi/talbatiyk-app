<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResponseComparisonItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $recipientItem = $this->recipientItem;
        $recipient = $recipientItem->recipient;
        $responseItem = $recipientItem->response;
        $selection = $this->selection;

        return [
            /** @format uuid */
            'id' => $this->id,

            'product_id' => $this->product_id,
            'product_name' => $this->product_name,

            'requested_quantity' => (int) $this->quantity,

            'order_unit_price' => (string) $this->unit_price,

            'supplier' => [
                /** @format uuid */
                'recipient_id' => $recipient->id,

                /** @format uuid */
                'supplier_id' => $recipient->supplier_id,

                'supplier_name' => $recipient->supplier_name,
            ],

            'response' => $responseItem === null
                ? null
                : new OrderRecipientItemResponseResource(
                    $responseItem,
                ),

            'selection' => $selection === null
                ? null
                : new OrderResponseComparisonSelectionResource(
                    $selection,
                ),
        ];
    }
}
