<?php

namespace App\Listeners\Order;

use App\Events\Order\SupplierOrderFulfillmentUpdated;
use App\Models\User;
use App\Notifications\Order\OrderFulfillmentStatusChangedNotification;
use Illuminate\Contracts\Queue\ShouldQueueAfterCommit;
use Illuminate\Support\Facades\DB;

final class SendOrderFulfillmentStatusChangedNotification implements ShouldQueueAfterCommit
{
    public function handle(
        SupplierOrderFulfillmentUpdated $event,
    ): void {
        DB::transaction(function () use ($event): void {
            /*
             * Serialize lifecycle delivery per customer so concurrent
             * queue retries cannot both pass the idempotency check.
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
                    'order_fulfillment_status_changed',
                )
                ->where(
                    'data->data->order_recipient_id',
                    $event->orderRecipientId,
                )
                ->where(
                    'data->data->fulfillment_version',
                    $event->fulfillmentVersion,
                )
                ->exists();

            if ($alreadyDelivered) {
                return;
            }

            $customer->notify(
                new OrderFulfillmentStatusChangedNotification(
                    orderId: $event->orderId,
                    orderRecipientId: $event->orderRecipientId,
                    supplierId: $event->supplierId,
                    supplierName: $event->supplierName,
                    fulfillmentStatus: $event->fulfillmentStatus,
                    fulfillmentVersion: $event->fulfillmentVersion,
                ),
            );
        });
    }
}
