<?php

namespace App\Services\Order;

use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

final class OrderQueryService
{
    public function __construct(
        private readonly OrderAggregateStatusResolver $aggregateStatusResolver,
    ) {}

    /**
     * Return the authenticated customer's orders with the current
     * server-authoritative aggregate lifecycle attached.
     *
     * @return Collection<int, Order>
     */
    public function forUser(User $user): Collection
    {
        $orders = Order::query()
            ->where('user_id', $user->id)
            ->with([
                'items',
                'recipients.response',
                'recipients.items.response.selection',
            ])
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->get();

        foreach ($orders as $order) {
            $order->setAttribute(
                'aggregate_status',
                $this->aggregateStatusResolver->resolve($order),
            );
        }

        return $orders;
    }
}
