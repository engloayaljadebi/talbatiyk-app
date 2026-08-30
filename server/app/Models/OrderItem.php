<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

#[Fillable([
    'order_id',
    'product_id',
    'product_name',
    'unit_price',
    'quantity',
    'supplier_id',
    'supplier_name',
    'image_url',
])]
class OrderItem extends Model
{
    use HasUuids;

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function supplier(): BelongsTo
    {
        return $this->belongsTo(
            Business::class,
            'supplier_id',
        );
    }

    public function recipientItem(): HasOne
    {
        return $this->hasOne(OrderRecipientItem::class);
    }

    public function selection(): HasOne
    {
        return $this->hasOne(OrderItemSelection::class);
    }

    protected function casts(): array
    {
        return [
            'unit_price' => 'decimal:2',
            'quantity' => 'integer',
        ];
    }
}
