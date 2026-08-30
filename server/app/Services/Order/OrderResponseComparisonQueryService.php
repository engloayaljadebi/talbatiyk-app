<?php

namespace App\Services\Order;

use App\Models\Order;
use App\Models\User;

class OrderResponseComparisonQueryService
{
    public function forUser(User $user, string $orderId): Order
    {
        return Order::query()
            ->whereKey($orderId)
            ->where('user_id', $user->id)
            ->with([
                'items',
                'items.recipientItem.recipient',
                'items.recipientItem.response',
                'items.selection',
            ])
            ->firstOrFail();
    }
}
