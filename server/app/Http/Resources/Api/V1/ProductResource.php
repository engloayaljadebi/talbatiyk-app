<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /*
         * ProductResource must not trigger hidden lazy queries.
         *
         * Product Discovery and Product Publishing are responsible for
         * eager-loading supplier.locations.
         */
        $primarySupplierLocation =
            $this->supplier->relationLoaded('locations')
                ? $this->supplier->locations->firstWhere(
                    'is_primary',
                    true,
                )
                : null;

        return [
            /** @format uuid */
            'id' => $this->id,

            /** @format uuid */
            'supplier_id' => $this->supplier_id,

            'supplier_name' => $this->supplier->name,

            /** @var string|null */
            'supplier_governorate' => $primarySupplierLocation?->administrative_area,

            'name' => $this->name,

            /** @var string|null */
            'description' => $this->description,

            'category' => $this->category,
            'brand' => $this->brand,

            'price' => (float) $this->price,

            /** @var int */
            'quantity' => (int) $this->quantity,

            /** @var bool */
            'is_available' => (bool) $this->is_available,

            /** @var string|null */
            'image_url' => $this->image_url,

            /** @var string[] */
            'colors' => $this->colors ?? [],

            'discount' => (float) $this->discount,
            'rating' => (float) $this->rating,

            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
