<?php

namespace App\Listeners\Order;

use App\Events\Order\SupplierOrderResponseSubmitted;
use App\Models\User;
use App\Notifications\Order\OrderResponseReceivedNotification;
use Illuminate\Contracts\Queue\ShouldQueueAfterCommit;
use Illuminate\Support\Facades\DB;

final class SendOrderResponseReceivedNotification implements ShouldQueueAfterCommit
{
    public function handle(
        SupplierOrderResponseSubmitted $event,
    ): void {
        DB::transaction(function () use ($event): void {
            /*
             * The customer row is the serialization lock for lifecycle
             * notification delivery. Concurrent retries for the same
             * customer cannot both pass the check-and-insert section.
             */
            $customer = User::query()
                ->whereKey($event->customerUserId)
                ->lockForUpdate()
                ->first();

            if ($customer === null) {
                return;
            }

            $alreadyDelivered = $customer
                ->notifications()
                ->where(
                    'type',
                    'order_response_received',
                )
                ->where(
                    'data->data->response_id',
                    $event->responseId,
                )
                ->exists();

            if ($alreadyDelivered) {
                return;
            }

            $customer->notify(
                new OrderResponseReceivedNotification(
                    orderId: $event->orderId,
                    orderRecipientId: $event->orderRecipientId,
                    responseId: $event->responseId,
                    supplierId: $event->supplierId,
                    supplierName: $event->supplierName,
                ),
            );
        });
    }
}
