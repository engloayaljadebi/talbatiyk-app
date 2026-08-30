<?php

namespace App\Services\Order;

use App\Enums\Order\FulfillmentStatus;
use App\Enums\Order\OrderAggregateStatus;
use App\Models\Order;
use App\Models\OrderRecipient;
use App\Models\OrderRecipientItem;
use LogicException;

final class OrderAggregateStatusResolver
{
    public function resolveCurrent(Order $order): OrderAggregateStatus
    {
        $order->loadMissing([
            'recipients.response',
            'recipients.items.response.selection',
        ]);

        return $this->resolve($order);
    }

    public function resolve(Order $order): OrderAggregateStatus
    {
        $this->assertAggregateLoaded($order);

        $recipients = $order->getRelation('recipients');

        if ($recipients->isEmpty()) {
            return OrderAggregateStatus::PendingResponses;
        }

        $allResponsesReceived = $recipients->every(
            static fn (OrderRecipient $recipient): bool =>
                $recipient->getRelation('response') !== null,
        );

        $selectedRecipients = $recipients
            ->filter(
                fn (OrderRecipient $recipient): bool =>
                    $this->hasPositiveSelection($recipient),
            )
            ->values();

        if ($selectedRecipients->isNotEmpty()) {
            $deliveredCount = $selectedRecipients
                ->filter(
                    static fn (OrderRecipient $recipient): bool =>
                        $recipient->fulfillment_status
                        === FulfillmentStatus::Delivered,
                )
                ->count();

            /*
             * Do not declare the whole Order completed while another supplier
             * response is still pending. Selection is allowed before every
             * Recipient has replied, so completion requires both:
             *
             * - every supplier response is final, and
             * - every currently selected Recipient is delivered.
             */
            if (
                $allResponsesReceived
                && $deliveredCount === $selectedRecipients->count()
            ) {
                return OrderAggregateStatus::Completed;
            }

            if ($deliveredCount > 0) {
                return OrderAggregateStatus::PartiallyCompleted;
            }

            $hasStartedFulfillment = $selectedRecipients->contains(
                static fn (OrderRecipient $recipient): bool =>
                    $recipient->fulfillment_status !== null,
            );

            if ($hasStartedFulfillment) {
                return OrderAggregateStatus::InFulfillment;
            }

            return OrderAggregateStatus::SuppliersSelected;
        }

        if ($allResponsesReceived) {
            return OrderAggregateStatus::ResponsesReceived;
        }

        return OrderAggregateStatus::PendingResponses;
    }

    private function hasPositiveSelection(OrderRecipient $recipient): bool
    {
        return $recipient
            ->getRelation('items')
            ->contains(
                static function (OrderRecipientItem $item): bool {
                    $response = $item->getRelation('response');

                    if ($response === null) {
                        return false;
                    }

                    $selection = $response->getRelation('selection');

                    return (int) ($selection?->selected_quantity ?? 0) > 0;
                },
            );
    }

    private function assertAggregateLoaded(Order $order): void
    {
        if (! $order->relationLoaded('recipients')) {
            throw new LogicException(
                'Order recipients must be loaded before resolving aggregate status.',
            );
        }

        foreach ($order->getRelation('recipients') as $recipient) {
            if (
                ! $recipient->relationLoaded('response')
                || ! $recipient->relationLoaded('items')
            ) {
                throw new LogicException(
                    'Order recipient response and items must be loaded before resolving aggregate status.',
                );
            }

            foreach ($recipient->getRelation('items') as $item) {
                if (! $item->relationLoaded('response')) {
                    throw new LogicException(
                        'Order recipient item response must be loaded before resolving aggregate status.',
                    );
                }

                $response = $item->getRelation('response');

                if (
                    $response !== null
                    && ! $response->relationLoaded('selection')
                ) {
                    throw new LogicException(
                        'Order recipient item selection must be loaded before resolving aggregate status.',
                    );
                }
            }
        }
    }
}
