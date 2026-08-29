<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'order_recipient_id',
    'order_item_id',
])]
class OrderRecipientItem extends Model
{
    use HasUuids;

    public function recipient(): BelongsTo
    {
        return $this->belongsTo(
            OrderRecipient::class,
            'order_recipient_id',
        );
    }

    public function orderItem(): BelongsTo
    {
        return $this->belongsTo(OrderItem::class);
    }
}
