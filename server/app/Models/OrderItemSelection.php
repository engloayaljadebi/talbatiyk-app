<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'order_item_id',
    'order_recipient_item_response_id',
    'selected_quantity',
])]
class OrderItemSelection extends Model
{
    use HasUuids;

    public function orderItem(): BelongsTo
    {
        return $this->belongsTo(OrderItem::class);
    }

    public function responseItem(): BelongsTo
    {
        return $this->belongsTo(
            OrderRecipientItemResponse::class,
            'order_recipient_item_response_id',
        );
    }

    protected function casts(): array
    {
        return [
            'selected_quantity' => 'integer',
        ];
    }
}
