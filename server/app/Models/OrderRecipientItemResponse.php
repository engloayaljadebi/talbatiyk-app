<?php

namespace App\Models;

use App\Enums\Order\AvailabilityStatus;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'order_recipient_response_id',
    'order_recipient_item_id',
    'requested_quantity',
    'available_quantity',
    'availability_status',
    'offered_unit_price',
    'response_notes',
])]
class OrderRecipientItemResponse extends Model
{
    use HasUuids;

    public function response(): BelongsTo
    {
        return $this->belongsTo(
            OrderRecipientResponse::class,
            'order_recipient_response_id',
        );
    }

    public function recipientItem(): BelongsTo
    {
        return $this->belongsTo(
            OrderRecipientItem::class,
            'order_recipient_item_id',
        );
    }

    protected function casts(): array
    {
        return [
            'requested_quantity' => 'integer',
            'available_quantity' => 'integer',
            'availability_status' => AvailabilityStatus::class,
            'offered_unit_price' => 'decimal:2',
        ];
    }
}
