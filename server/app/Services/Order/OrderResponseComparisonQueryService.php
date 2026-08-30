<?php

namespace App\Services\Order;

use App\Models\Order;
use App\Models\User;

class OrderResponseComparisonQueryService
{
    public function __construct(
        private readonly OrderAggregateStatusResolver $aggregateStatusResolver,
    ) {}

    public function forUser(User $user, string $orderId): Order
    {
        $order = Order::query()
            ->whereKey($orderId)
            ->where('user_id', $user->id)
            ->with([
                'items',
                'items.recipientItem.recipient',
                'items.recipientItem.response',
                'items.selection',
            ])
            ->firstOrFail();

        $order->setAttribute(
            'aggregate_status',
            $this->aggregateStatusResolver
                ->resolveCurrent($order)
                ->value,
        );

        return $order;
    }
}
