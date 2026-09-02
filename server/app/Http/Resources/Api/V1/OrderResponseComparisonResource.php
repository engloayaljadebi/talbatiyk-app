<?php

namespace App\Http\Resources\Api\V1;

use App\Enums\Order\OrderAggregateStatus;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResponseComparisonResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $comparisonItems = $this->items
            ->flatMap(
                static function ($orderItem) {
                    return $orderItem->recipientItems
                        ->map(
                            static function ($recipientItem) use (
                                $orderItem,
                            ) {
                                $recipientItem->setRelation(
                                    'orderItem',
                                    $orderItem,
                                );

                                return $recipientItem;
                            },
                        );
                },
            )
            ->values();

        return [
            /** @format uuid */
            'id' => $this->id,

            'version' => (int) $this->version,
            'status' => $this->status,

            /** @var OrderAggregateStatus */
            'aggregate_status' => $this->aggregate_status,

            /** @var string|null */
            'notes' => $this->notes,

            'items' => OrderResponseComparisonItemResource::collection(
                $comparisonItems,
            ),

            /** @format date-time */
            'created_at' => $this->created_at?->toISOString(),

            /** @format date-time */
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
