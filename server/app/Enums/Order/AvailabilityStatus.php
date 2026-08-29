<?php

namespace App\Enums\Order;

enum AvailabilityStatus: string
{
    case Full = 'full';
    case Partial = 'partial';
    case Unavailable = 'unavailable';
}
