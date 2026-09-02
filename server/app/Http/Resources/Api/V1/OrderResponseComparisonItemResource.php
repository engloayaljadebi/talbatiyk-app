<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResponseComparisonItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $orderItem = $this->orderItem;
        $recipient = $this->recipient;
        $responseItem = $this->response;
        $selection = $orderItem->selection;

        $selectionForThisResponse =
            $selection !== null
            && $responseItem !== null
            && (string) $selection->order_recipient_item_response_id
                === (string) $responseItem->id
                ? $selection
                : null;

        return [
            /** @format uuid */
            'id' => $orderItem->id,

            'product_id' => $orderItem->product_id,
            'product_name' => $orderItem->product_name,

            'requested_quantity' => (int) $orderItem->quantity,

            'order_unit_price' => (string) $orderItem->unit_price,

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

            'selection' => $selectionForThisResponse === null
                ? null
                : new OrderResponseComparisonSelectionResource(
                    $selectionForThisResponse,
                ),
        ];
    }
}
