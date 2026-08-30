<?php

namespace App\Actions\Order;

use App\Enums\Order\AvailabilityStatus;
use App\Models\Order;
use App\Models\OrderItemSelection;
use App\Models\OrderRecipientItemResponse;
use App\Models\User;
use App\Services\Order\OrderResponseComparisonQueryService;
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
                    'order_recipient_item_response_id' => (string) $responseItem->id,
                    'selected_quantity' => $selectedQuantity,
                ];
            }

            OrderItemSelection::query()
                ->whereIn(
                    'order_item_id',
                    $orderItems->keys()->all(),
                )
                ->delete();

            foreach ($resolvedSelections as $selection) {
                OrderItemSelection::query()->create($selection);
            }

            $order->version = $currentVersion + 1;
            $order->save();

            return $this->comparisonQuery->forUser(
                $user,
                (string) $order->id,
            );
        });
    }
}
