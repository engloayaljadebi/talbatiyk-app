<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable([
    'order_recipient_id',
    'idempotency_key',
    'idempotency_payload_hash',
])]
class OrderRecipientResponse extends Model
{
    use HasUuids;

    public function recipient(): BelongsTo
    {
        return $this->belongsTo(OrderRecipient::class, 'order_recipient_id');
    }

    public function items(): HasMany
    {
        return $this->hasMany(
            OrderRecipientItemResponse::class,
            'order_recipient_response_id',
        );
    }
}
