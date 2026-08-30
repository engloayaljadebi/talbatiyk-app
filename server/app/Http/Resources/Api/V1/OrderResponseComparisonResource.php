<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResponseComparisonResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            /** @format uuid */
            'id' => $this->id,

            'version' => (int) $this->version,
            'status' => $this->status,
            /** @var string|null */
            'notes' => $this->notes,

            'items' => OrderResponseComparisonItemResource::collection(
                $this->items,
            ),

            /** @format date-time */
            'created_at' => $this->created_at?->toISOString(),

            /** @format date-time */
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
