<?php

namespace App\Notifications\Order;

use Illuminate\Notifications\Notification;

final class OrderFulfillmentStatusChangedNotification extends Notification
{
    public function __construct(
        public readonly string $orderId,
        public readonly string $orderRecipientId,
        public readonly string $supplierId,
        public readonly string $supplierName,
        public readonly string $fulfillmentStatus,
        public readonly int $fulfillmentVersion,
    ) {}

    /**
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function databaseType(object $notifiable): string
    {
        return 'order_fulfillment_status_changed';
    }

    /**
     * @return array{
     *     title: string,
     *     body: string,
     *     data: array{
     *         order_id: string,
     *         order_recipient_id: string,
     *         supplier_id: string,
     *         supplier_name: string,
     *         fulfillment_status: string,
     *         fulfillment_version: int,
     *         target_route: string
     *     }
     * }
     */
    public function toDatabase(object $notifiable): array
    {
        return [
            'title' => 'تم تحديث حالة طلبك',
            'body' => sprintf(
                '%s: %s',
                $this->supplierName,
                $this->statusLabel(),
            ),
            'data' => [
                'order_id' => $this->orderId,
                'order_recipient_id' => $this->orderRecipientId,
                'supplier_id' => $this->supplierId,
                'supplier_name' => $this->supplierName,
                'fulfillment_status' => $this->fulfillmentStatus,
                'fulfillment_version' => $this->fulfillmentVersion,
                'target_route' => '/orders/'.$this->orderId,
            ],
        ];
    }

    private function statusLabel(): string
    {
        return match ($this->fulfillmentStatus) {
            'preparing' => 'بدأ المورد تجهيز طلبك.',
            'ready_for_delivery' => 'طلبك جاهز للتسليم.',
            'out_for_delivery' => 'طلبك خرج للتسليم.',
            'delivered' => 'تم تسليم طلبك.',
            default => 'تم تحديث حالة تنفيذ طلبك.',
        };
    }
}
