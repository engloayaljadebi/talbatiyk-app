<?php

namespace App\Enums\Order;

enum OrderAggregateStatus: string
{
    case PendingResponses = 'pending_responses';
    case ResponsesReceived = 'responses_received';
    case SuppliersSelected = 'suppliers_selected';
    case InFulfillment = 'in_fulfillment';
    case PartiallyCompleted = 'partially_completed';
    case Completed = 'completed';
    case Cancelled = 'cancelled';
    case Expired = 'expired';
}
