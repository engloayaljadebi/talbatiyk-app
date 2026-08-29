<?php

namespace App\Services\Order;

use App\Models\Business;
use App\Models\OrderRecipient;
use Illuminate\Support\Collection;

class SupplierOrderQueryService
{
    /**
     * Return only recipients owned by the requested supplier Business.
     *
     * Authorization is handled by BusinessPolicy before this query runs. The
     * supplier_id scope remains here as data-layer isolation and defense in depth.
     *
     * @return Collection<int, OrderRecipient>
     */
    public function receivedOrders(Business $business): Collection
    {
        return OrderRecipient::query()
            ->where('supplier_id', $business->id)
            ->with([
                'order:id,status,notes,created_at,updated_at',
                'items.orderItem:id,order_id,product_id,product_name,unit_price,quantity,image_url',
                'response.items',
            ])
            ->orderByDesc('created_at')
            ->get();
    }
}
