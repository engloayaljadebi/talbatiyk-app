<?php

namespace App\Http\Resources\Api\V1;

use App\Support\PublicDiskUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderItemResource extends JsonResource
{
    /**
     * الشكل العام لعنصر الطلب في عقد الـ API.
     *
     * لا نعرض order_id أو timestamps لأنهما تفاصيل داخلية
     * وليسا مطلوبين من Flutter لتمثيل العنصر.
     */
    public function toArray(Request $request): array
    {
        return [
            /** @format uuid */
            'id' => $this->id,

            'item_type' => $this->item_type,

            // Null for manual items.
            /** @var string|null */
            'product_id' => $this->product_id,
            'product_name' => $this->product_name,

            // decimal cast في Eloquent يعيد string للحفاظ على الدقة.
            'unit_price' => (string) $this->unit_price,

            'quantity' => $this->quantity,

            /** @var string|null */
            'unit' => $this->unit,
            /** @var string|null */
            'note' => $this->note,

            /**
             * @var string|null
             *
             * @format uuid
             */
            'supplier_id' => $this->supplier_id,

            /** @var string|null */
            'supplier_name' => $this->supplier_name,
            'image_url' => PublicDiskUrl::resolve(
                $this->image_url,
            ),
        ];
    }
}
