<?php

namespace App\Actions\Order;

use App\Enums\Order\AvailabilityStatus;
use App\Models\Business;
use App\Models\OrderRecipient;
use App\Models\OrderRecipientResponse;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use JsonException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;

class SubmitSupplierOrderResponseAction
{
    /**
     * Persist one final response for one supplier Recipient.
     *
     * @param  array{items: array<int, array<string, mixed>>}  $data
     */
    public function execute(
        Business $business,
        string $recipientId,
        array $data,
        string $idempotencyKey,
    ): OrderRecipientResponse {
        $payloadHash = $this->payloadHash($data);

        return DB::transaction(function () use (
            $business,
            $recipientId,
            $data,
            $idempotencyKey,
            $payloadHash,
        ): OrderRecipientResponse {
            /*
             * supplier_id scoping is intentional defense in depth. Even after the
             * Business Policy succeeds, a Recipient belonging to another supplier
             * must behave as not found.
             *
             * The Recipient row lock serializes concurrent response attempts.
             */
            $recipient = OrderRecipient::query()
                ->whereKey($recipientId)
                ->where('supplier_id', $business->id)
                ->with('items.orderItem:id,quantity')
                ->lockForUpdate()
                ->firstOrFail();

            $existingResponse = OrderRecipientResponse::query()
                ->where('order_recipient_id', $recipient->id)
                ->with('items')
                ->first();

            if ($existingResponse !== null) {
                return $this->resolveExistingResponse(
                    $existingResponse,
                    $idempotencyKey,
                    $payloadHash,
                );
            }

            $submittedItems = collect($data['items'])
                ->mapWithKeys(
                    static fn (array $item, int $index): array => [
                        $item['order_recipient_item_id'] => [
                            'index' => $index,
                            'data' => $item,
                        ],
                    ],
                );

            $recipientItems = $recipient->items->keyBy('id');

            $this->ensureCompleteRecipientResponse(
                $recipientItems,
                $submittedItems,
            );

            $response = $recipient->response()->create([
                'idempotency_key' => $idempotencyKey,
                'idempotency_payload_hash' => $payloadHash,
            ]);

            foreach ($recipientItems as $recipientItem) {
                $submitted = $submittedItems->get($recipientItem->id);
                $index = $submitted['index'];
                $item = $submitted['data'];
                $requestedQuantity = (int) $recipientItem
                    ->orderItem
                    ->quantity;

                $status = $this->validateAvailability(
                    $item,
                    $requestedQuantity,
                    $index,
                );

                $response->items()->create([
                    'order_recipient_item_id' => $recipientItem->id,
                    'requested_quantity' => $requestedQuantity,
                    'available_quantity' => (int) $item['available_quantity'],
                    'availability_status' => $status->value,
                    'offered_unit_price' => $item['offered_unit_price'] ?? null,
                    'response_notes' => $item['response_notes'] ?? null,
                ]);
            }

            return $response->load('items');
        });
    }

    private function resolveExistingResponse(
        OrderRecipientResponse $response,
        string $idempotencyKey,
        string $payloadHash,
    ): OrderRecipientResponse {
        if ((string) $response->idempotency_key !== $idempotencyKey) {
            throw new ConflictHttpException(
                'This order recipient already has a final supplier response.',
            );
        }

        if (! hash_equals(
            (string) $response->idempotency_payload_hash,
            $payloadHash,
        )) {
            throw new ConflictHttpException(
                'The Idempotency-Key was already used for a different supplier response payload.',
            );
        }

        return $response->loadMissing('items');
    }

    /**
     * @param  Collection<string, mixed>  $recipientItems
     * @param  Collection<string, array{index: int, data: array<string, mixed>}>  $submittedItems
     */
    private function ensureCompleteRecipientResponse(
        Collection $recipientItems,
        Collection $submittedItems,
    ): void {
        $expectedIds = $recipientItems->keys()->sort()->values()->all();
        $submittedIds = $submittedItems->keys()->sort()->values()->all();

        if ($expectedIds !== $submittedIds) {
            throw ValidationException::withMessages([
                'items' => [
                    'The response must include exactly every item belonging to this order recipient.',
                ],
            ]);
        }
    }

    /**
     * @param  array<string, mixed>  $item
     */
    private function validateAvailability(
        array $item,
        int $requestedQuantity,
        int $index,
    ): AvailabilityStatus {
        $status = AvailabilityStatus::tryFrom(
            (string) $item['availability_status'],
        );

        if ($status === null) {
            throw ValidationException::withMessages([
                "items.$index.availability_status" => [
                    'The selected availability status is invalid.',
                ],
            ]);
        }

        $availableQuantity = (int) $item['available_quantity'];

        if (
            $status === AvailabilityStatus::Full
            && $availableQuantity !== $requestedQuantity
        ) {
            throw ValidationException::withMessages([
                "items.$index.available_quantity" => [
                    'Full availability requires the full requested quantity.',
                ],
            ]);
        }

        if (
            $status === AvailabilityStatus::Partial
            && ($availableQuantity <= 0
                || $availableQuantity >= $requestedQuantity
            )
        ) {
            throw ValidationException::withMessages([
                "items.$index.available_quantity" => [
                    'Partial availability must be greater than zero and less than the requested quantity.',
                ],
            ]);
        }

        if (
            $status === AvailabilityStatus::Unavailable
            && $availableQuantity !== 0
        ) {
            throw ValidationException::withMessages([
                "items.$index.available_quantity" => [
                    'Unavailable items must have zero available quantity.',
                ],
            ]);
        }

        return $status;
    }

    /**
     * @param  array{items: array<int, array<string, mixed>>}  $data
     */
    private function payloadHash(array $data): string
    {
        $canonical = $data;

        $canonical['items'] = collect($canonical['items'])
            ->sortBy('order_recipient_item_id')
            ->values()
            ->map(static function (array $item): array {
                ksort($item);

                return $item;
            })
            ->all();

        ksort($canonical);

        try {
            $json = json_encode(
                $canonical,
                JSON_THROW_ON_ERROR
                    | JSON_PRESERVE_ZERO_FRACTION
                    | JSON_UNESCAPED_SLASHES
                    | JSON_UNESCAPED_UNICODE,
            );
        } catch (JsonException $exception) {
            throw ValidationException::withMessages([
                'items' => [
                    'The supplier response payload could not be normalized.',
                ],
            ]);
        }

        return hash('sha256', $json);
    }
}
