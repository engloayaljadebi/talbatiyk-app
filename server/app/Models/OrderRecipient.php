<?php

namespace App\Models;

use App\Enums\Order\FulfillmentStatus;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

#[Fillable([
    'order_id',
    'supplier_id',
    'supplier_name',
    'fulfillment_status',
    'fulfillment_version',
])]
class OrderRecipient extends Model
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

    public function items(): HasMany
    {
        return $this->hasMany(OrderRecipientItem::class);
    }

    /**
     * A supplier submits one final response for its Recipient in this stage.
     */
    public function response(): HasOne
    {
        return $this->hasOne(
            OrderRecipientResponse::class,
            'order_recipient_id',
        );
    }

    public function fulfillmentHistory(): HasMany
    {
        return $this->hasMany(
            OrderRecipientFulfillmentHistory::class,
            'order_recipient_id',
        );
    }

    protected function casts(): array
    {
        return [
            'fulfillment_status' => FulfillmentStatus::class,
            'fulfillment_version' => 'integer',
        ];
    }
}
