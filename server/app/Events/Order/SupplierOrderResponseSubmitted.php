<?php

namespace App\Events\Order;

final readonly class SupplierOrderResponseSubmitted
{
    public function __construct(
        public string $customerUserId,
        public string $orderId,
        public string $orderRecipientId,
        public string $responseId,
        public string $supplierId,
        public string $supplierName,
    ) {}
}
