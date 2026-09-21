<?php

namespace App\Notifications\Order;

use Illuminate\Notifications\Notification;

final class OrderResponseReceivedNotification extends Notification
{
    public function __construct(
        public readonly string $orderId,
        public readonly string $orderRecipientId,
        public readonly string $responseId,
        public readonly string $supplierId,
        public readonly string $supplierName,
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
        return 'order_response_received';
    }

    /**
     * @return array{
     *     title: string,
     *     body: string,
     *     data: array{
     *         order_id: string,
     *         order_recipient_id: string,
     *         response_id: string,
     *         supplier_id: string,
     *         supplier_name: string,
     *         target_route: string
     *     }
     * }
     */
    public function toDatabase(object $notifiable): array
    {
        return [
            'title' => 'وصل رد جديد على طلبك',
            'body' => sprintf(
                'أرسل %s ردًا جديدًا على طلبك.',
                $this->supplierName,
            ),
            'data' => [
                'order_id' => $this->orderId,
                'order_recipient_id' => $this->orderRecipientId,
                'response_id' => $this->responseId,
                'supplier_id' => $this->supplierId,
                'supplier_name' => $this->supplierName,
                'target_route' => '/orders/'.$this->orderId,
            ],
        ];
    }
}
