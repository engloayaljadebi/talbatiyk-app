<?php

namespace App\Events\Order;

final readonly class SupplierOrderFulfillmentUpdated
{
    public function __construct(
        public string $customerUserId,
        public string $orderId,
        public string $orderRecipientId,
        public string $supplierId,
        public string $supplierName,
        public string $fulfillmentStatus,
        public int $fulfillmentVersion,
    ) {}
}
