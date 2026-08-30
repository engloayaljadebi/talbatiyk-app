<?php

namespace Tests\Unit\Services\Order;

use App\Enums\Order\FulfillmentStatus;
use App\Enums\Order\OrderAggregateStatus;
use App\Models\Order;
use App\Models\OrderItemSelection;
use App\Models\OrderRecipient;
use App\Models\OrderRecipientItem;
use App\Models\OrderRecipientItemResponse;
use App\Models\OrderRecipientResponse;
use App\Services\Order\OrderAggregateStatusResolver;
use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Tests\TestCase;

class OrderAggregateStatusResolverTest extends TestCase
{
    public function test_pending_responses_when_a_supplier_has_not_replied(): void
    {
        $status = $this->resolver()->resolve(
            $this->order([
                $this->recipient(responded: true),
                $this->recipient(responded: false),
            ]),
        );

        $this->assertSame(
            OrderAggregateStatus::PendingResponses,
            $status,
        );
    }

    public function test_responses_received_when_every_supplier_has_replied_without_selection(): void
    {
        $status = $this->resolver()->resolve(
            $this->order([
                $this->recipient(responded: true),
                $this->recipient(responded: true),
            ]),
        );

        $this->assertSame(
            OrderAggregateStatus::ResponsesReceived,
            $status,
        );
    }

    public function test_selection_has_priority_over_another_pending_response(): void
    {
        $status = $this->resolver()->resolve(
            $this->order([
                $this->recipient(
                    responded: true,
                    selected: true,
                ),
                $this->recipient(responded: false),
            ]),
        );

        $this->assertSame(
            OrderAggregateStatus::SuppliersSelected,
            $status,
        );
    }

    public function test_started_selected_recipient_means_in_fulfillment(): void
    {
        $status = $this->resolver()->resolve(
            $this->order([
                $this->recipient(
                    responded: true,
                    selected: true,
                    fulfillmentStatus: FulfillmentStatus::Preparing,
                ),
                $this->recipient(responded: false),
            ]),
        );

        $this->assertSame(
            OrderAggregateStatus::InFulfillment,
            $status,
        );
    }

    public function test_one_delivered_selected_recipient_means_partially_completed(): void
    {
        $status = $this->resolver()->resolve(
            $this->order([
                $this->recipient(
                    responded: true,
                    selected: true,
                    fulfillmentStatus: FulfillmentStatus::Delivered,
                ),
                $this->recipient(
                    responded: true,
                    selected: true,
                    fulfillmentStatus: FulfillmentStatus::Preparing,
                ),
            ]),
        );

        $this->assertSame(
            OrderAggregateStatus::PartiallyCompleted,
            $status,
        );
    }

    public function test_all_selected_delivered_is_not_completed_while_another_response_is_pending(): void
    {
        $status = $this->resolver()->resolve(
            $this->order([
                $this->recipient(
                    responded: true,
                    selected: true,
                    fulfillmentStatus: FulfillmentStatus::Delivered,
                ),
                $this->recipient(responded: false),
            ]),
        );

        $this->assertSame(
            OrderAggregateStatus::PartiallyCompleted,
            $status,
        );
    }

    public function test_completed_when_all_responses_are_final_and_all_selected_recipients_are_delivered(): void
    {
        $status = $this->resolver()->resolve(
            $this->order([
                $this->recipient(
                    responded: true,
                    selected: true,
                    fulfillmentStatus: FulfillmentStatus::Delivered,
                ),
                $this->recipient(
                    responded: true,
                    selected: false,
                ),
            ]),
        );

        $this->assertSame(
            OrderAggregateStatus::Completed,
            $status,
        );
    }

    private function resolver(): OrderAggregateStatusResolver
    {
        return app(OrderAggregateStatusResolver::class);
    }

    /**
     * @param array<int, OrderRecipient> $recipients
     */
    private function order(array $recipients): Order
    {
        $order = new Order;

        $order->setRelation(
            'recipients',
            new EloquentCollection($recipients),
        );

        return $order;
    }

    private function recipient(
        bool $responded,
        bool $selected = false,
        ?FulfillmentStatus $fulfillmentStatus = null,
    ): OrderRecipient {
        $recipient = new OrderRecipient;

        $recipient->setAttribute(
            'fulfillment_status',
            $fulfillmentStatus?->value,
        );

        $hasResponse = $responded || $selected;

        $recipient->setRelation(
            'response',
            $hasResponse ? new OrderRecipientResponse : null,
        );

        $item = new OrderRecipientItem;

        if ($hasResponse) {
            $responseItem = new OrderRecipientItemResponse;

            $selection = null;

            if ($selected) {
                $selection = new OrderItemSelection;
                $selection->selected_quantity = 1;
            }

            $responseItem->setRelation('selection', $selection);
            $item->setRelation('response', $responseItem);
        } else {
            $item->setRelation('response', null);
        }

        $recipient->setRelation(
            'items',
            new EloquentCollection([$item]),
        );

        return $recipient;
    }
}