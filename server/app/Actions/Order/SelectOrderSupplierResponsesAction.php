<?php

namespace App\Actions\Order;

use App\Enums\Order\AvailabilityStatus;
use App\Models\Order;
use App\Models\OrderItemSelection;
use App\Models\OrderRecipient;
use App\Models\OrderRecipientItemResponse;
use App\Models\User;
use App\Services\Order\OrderResponseComparisonQueryService;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;

class SelectOrderSupplierResponsesAction
{
    public function __construct(
        private readonly OrderResponseComparisonQueryService $comparisonQuery,
    ) {}

    /**
     * @param array{
     *     expected_version: int,
     *     selections: array<int, array{
     *         order_recipient_item_response_id: string,
     *         selected_quantity: int
     *     }>
     * } $data
     */
    public function execute(
        User $user,
        string $orderId,
        array $data,
    ): Order {
        return DB::transaction(function () use (
            $user,
            $orderId,
            $data,
        ): Order {
            /*
             * Order is the cross-stage synchronization lock:
             * selection changes and supplier fulfillment both lock it first.
             */
            $order = Order::query()
                ->whereKey($orderId)
                ->where('user_id', $user->id)
                ->lockForUpdate()
                ->firstOrFail();

            $currentVersion = (int) $order->version;
            $expectedVersion = (int) $data['expected_version'];

            if ($currentVersion !== $expectedVersion) {
                throw new ConflictHttpException(
                    'The order version is stale. Refresh supplier responses and retry.',
                );
            }

            $orderItems = $order->items()
                ->lockForUpdate()
                ->get()
                ->keyBy('id');

            $responseIds = collect($data['selections'])
                ->pluck('order_recipient_item_response_id')
                ->values();

            $responseItems = OrderRecipientItemResponse::query()
                ->with([
                    'recipientItem.orderItem',
                    'response.recipient',
                ])
                ->whereIn('id', $responseIds->all())
                ->lockForUpdate()
                ->get()
                ->keyBy('id');

            if ($responseItems->count() !== $responseIds->count()) {
                throw ValidationException::withMessages([
                    'selections' => [
                        'One or more supplier response items do not exist.',
                    ],
                ]);
            }

            $selectedTotalsByOrderItem = [];
            $resolvedSelections = [];

            foreach ($data['selections'] as $index => $selection) {
                $responseId =
                    $selection['order_recipient_item_response_id'];

                $selectedQuantity =
                    (int) $selection['selected_quantity'];

                $responseItem = $responseItems->get($responseId);

                $recipientItem = $responseItem?->recipientItem;
                $orderItem = $recipientItem?->orderItem;
                $recipient = $responseItem?->response?->recipient;

                if (
                    $responseItem === null
                    || $orderItem === null
                    || $recipient === null
                    || $orderItem->order_id !== $order->id
                    || $recipient->order_id !== $order->id
                    || ! $orderItems->has($orderItem->id)
                ) {
                    throw ValidationException::withMessages([
                        "selections.$index.order_recipient_item_response_id" => [
                            'The supplier response item does not belong to this order.',
                        ],
                    ]);
                }

                if (
                    $responseItem->availability_status
                    === AvailabilityStatus::Unavailable
                ) {
                    throw ValidationException::withMessages([
                        "selections.$index.selected_quantity" => [
                            'An unavailable supplier response cannot be selected.',
                        ],
                    ]);
                }

                if (
                    $selectedQuantity
                    > (int) $responseItem->available_quantity
                ) {
                    throw ValidationException::withMessages([
                        "selections.$index.selected_quantity" => [
                            'The selected quantity exceeds the supplier available quantity.',
                        ],
                    ]);
                }

                $orderItemId = (string) $orderItem->id;

                $selectedTotalsByOrderItem[$orderItemId] =
                    ($selectedTotalsByOrderItem[$orderItemId] ?? 0)
                    + $selectedQuantity;

                if (
                    $selectedTotalsByOrderItem[$orderItemId]
                    > (int) $orderItem->quantity
                ) {
                    throw ValidationException::withMessages([
                        "selections.$index.selected_quantity" => [
                            'The total selected quantity exceeds the requested quantity.',
                        ],
                    ]);
                }

                $resolvedSelections[] = [
                    'order_item_id' => $orderItemId,
                    'order_recipient_id' => (string) $recipient->id,
                    'order_recipient_item_response_id' => (string) $responseItem->id,
                    'selected_quantity' => $selectedQuantity,
                ];
            }

            /*
             * Read the current snapshot before changing it. These rows are locked so
             * the diff and the writes below describe one atomic replacement.
             */
            $currentSelections = OrderItemSelection::query()
                ->with([
                    'responseItem.response.recipient',
                ])
                ->whereIn(
                    'order_item_id',
                    $orderItems->keys()->all(),
                )
                ->lockForUpdate()
                ->get();

            $currentSnapshots =
                $this->currentSnapshotsByRecipient($currentSelections);

            $desiredSnapshots =
                $this->desiredSnapshotsByRecipient($resolvedSelections);

            $recipientIds = collect([
                ...array_keys($currentSnapshots),
                ...array_keys($desiredSnapshots),
            ])
                ->unique()
                ->sort()
                ->values();

            $recipients = OrderRecipient::query()
                ->where('order_id', $order->id)
                ->whereIn('id', $recipientIds->all())
                ->orderBy('id')
                ->lockForUpdate()
                ->get()
                ->keyBy('id');

            if ($recipients->count() !== $recipientIds->count()) {
                throw new ConflictHttpException(
                    'The supplier selection state is no longer valid. Refresh and retry.',
                );
            }

            $affectedRecipientIds = $recipientIds
                ->filter(
                    static fn (string $recipientId): bool => ($currentSnapshots[$recipientId] ?? [])
                        !== ($desiredSnapshots[$recipientId] ?? []),
                )
                ->values();

            /*
             * Once physical fulfillment starts, the commercial quantity that the
             * supplier is executing must no longer be changed.
             *
             * Unchanged recipients are deliberately ignored so another supplier in
             * the same Order can still have its selection adjusted independently.
             */
            foreach ($affectedRecipientIds as $recipientId) {
                $recipient = $recipients->get($recipientId);

                if ($recipient->fulfillment_status !== null) {
                    throw new ConflictHttpException(
                        'Supplier selection cannot change after fulfillment has started.',
                    );
                }
            }

            /*
             * Synchronize only changed OrderItems. Do not delete/recreate an
             * unchanged selection belonging to a supplier already in fulfillment.
             */
            $currentByOrderItem =
                $currentSelections->keyBy('order_item_id');

            $desiredByOrderItem =
                collect($resolvedSelections)->keyBy('order_item_id');

            foreach ($currentByOrderItem as $orderItemId => $currentSelection) {
                $desired = $desiredByOrderItem->get($orderItemId);

                if ($desired === null) {
                    $currentSelection->delete();

                    continue;
                }

                if (
                    (string) $currentSelection
                        ->order_recipient_item_response_id
                        !== $desired['order_recipient_item_response_id']
                    || (int) $currentSelection->selected_quantity
                        !== $desired['selected_quantity']
                ) {
                    $currentSelection
                        ->order_recipient_item_response_id =
                            $desired[
                                'order_recipient_item_response_id'
                            ];

                    $currentSelection->selected_quantity =
                        $desired['selected_quantity'];

                    $currentSelection->save();
                }
            }

            foreach ($desiredByOrderItem as $orderItemId => $desired) {
                if ($currentByOrderItem->has($orderItemId)) {
                    continue;
                }

                OrderItemSelection::query()->create([
                    'order_item_id' => $desired['order_item_id'],
                    'order_recipient_item_response_id' => $desired[
                            'order_recipient_item_response_id'
                        ],
                    'selected_quantity' => $desired['selected_quantity'],
                ]);
            }

            /*
             * A supplier may have loaded the previous selected quantity already.
             * Bump only recipients whose commercial selection actually changed.
             */
            foreach ($affectedRecipientIds as $recipientId) {
                $recipient = $recipients->get($recipientId);

                $recipient->fulfillment_version =
                    (int) $recipient->fulfillment_version + 1;

                $recipient->save();
            }

            $order->version = $currentVersion + 1;
            $order->save();

            return $this->comparisonQuery->forUser(
                $user,
                (string) $order->id,
            );
        });
    }

    /**
     * @param  Collection<int, OrderItemSelection>  $selections
     * @return array<string, array<int, array<string, int|string>>>
     */
    private function currentSnapshotsByRecipient(
        Collection $selections,
    ): array {
        return $selections
            ->groupBy(function (OrderItemSelection $selection): string {
                $recipientId =
                    $selection
                        ->responseItem
                        ?->response
                        ?->recipient
                        ?->id;

                if (! is_string($recipientId) || $recipientId === '') {
                    throw new ConflictHttpException(
                        'The existing supplier selection state is invalid.',
                    );
                }

                return $recipientId;
            })
            ->map(
                static fn (Collection $items): array => $items
                    ->map(
                        static fn (
                            OrderItemSelection $selection,
                        ): array => [
                            'order_item_id' => (string) $selection->order_item_id,
                            'response_id' => (string) $selection
                                ->order_recipient_item_response_id,
                            'selected_quantity' => (int) $selection->selected_quantity,
                        ],
                    )
                    ->sortBy('order_item_id')
                    ->values()
                    ->all(),
            )
            ->all();
    }

    /**
     * @param array<int, array{
     *     order_item_id: string,
     *     order_recipient_id: string,
     *     order_recipient_item_response_id: string,
     *     selected_quantity: int
     * }> $selections
     * @return array<string, array<int, array<string, int|string>>>
     */
    private function desiredSnapshotsByRecipient(
        array $selections,
    ): array {
        return collect($selections)
            ->groupBy('order_recipient_id')
            ->map(
                static fn (Collection $items): array => $items
                    ->map(
                        static fn (array $selection): array => [
                            'order_item_id' => $selection['order_item_id'],
                            'response_id' => $selection[
                                    'order_recipient_item_response_id'
                                ],
                            'selected_quantity' => $selection['selected_quantity'],
                        ],
                    )
                    ->sortBy('order_item_id')
                    ->values()
                    ->all(),
            )
            ->all();
    }
}
