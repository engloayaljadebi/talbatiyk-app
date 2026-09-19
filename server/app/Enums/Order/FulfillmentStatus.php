<?php

namespace App\Enums\Order;

enum FulfillmentStatus: string
{
    case Confirmed = 'confirmed';
    case Preparing = 'preparing';
    case ReadyForDelivery = 'ready_for_delivery';
    case OutForDelivery = 'out_for_delivery';
    case Delivered = 'delivered';
}
