<?php

namespace App\Models;

use App\Enums\Order\FulfillmentStatus;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'order_recipient_id',
    'actor_user_id',
    'from_status',
    'to_status',
])]
class OrderRecipientFulfillmentHistory extends Model
{
    use HasUuids;

    public function recipient(): BelongsTo
    {
        return $this->belongsTo(
            OrderRecipient::class,
            'order_recipient_id',
        );
    }

    public function actor(): BelongsTo
    {
        return $this->belongsTo(
            User::class,
            'actor_user_id',
        );
    }

    protected function casts(): array
    {
        return [
            'from_status' => FulfillmentStatus::class,
            'to_status' => FulfillmentStatus::class,
        ];
    }
}
