<?php

namespace App\Services\Order;

use App\Models\Business;
use App\Models\Order;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;

class OrderService
{
    /**
     * Create a new order for the authenticated user.
     *
     * @param array{
     *     notes?: string|null,
     *     items: array<int, array{
     *         product_id: string,
     *         product_name: string,
     *         unit_price: numeric-string|int|float,
     *         quantity: int,
     *         supplier_id: string,
     *         supplier_name: string,
     *         image_url?: string|null
     *     }>
     * } $data
     */
    public function create(
        User $user,
        array $data,
        string $idempotencyKey,
    ): Order {
        $payloadHash = $this->payloadHash($data);

        // Important for delayed retries:
        // if this logical operation already succeeded, return its original order
        // before re-validating supplier state that may have changed meanwhile.
        $existingOrder = $user->orders()
            ->where('idempotency_key', $idempotencyKey)
            ->first();

        if ($existingOrder !== null) {
            return $this->resolveIdempotentOrder(
                $existingOrder,
                $payloadHash,
            );
        }

        $this->validateSuppliers($data['items']);

        return DB::transaction(function () use (
            $user,
            $data,
            $idempotencyKey,
            $payloadHash,
        ): Order {
            /*
         * firstOrCreate plus the database unique constraint also protects
         * concurrent retries using the same logical operation key.
         */
            $order = $user->orders()->firstOrCreate(
                [
                    'idempotency_key' => $idempotencyKey,
                ],
                [
                    'idempotency_payload_hash' => $payloadHash,
                    'status' => 'pending',
                    'notes' => $data['notes'] ?? null,
                ],
            );

            if (!$order->wasRecentlyCreated) {
                return $this->resolveIdempotentOrder(
                    $order,
                    $payloadHash,
                );
            }

            foreach ($data['items'] as $item) {
                $order->items()->create([
                    'product_id' => $item['product_id'],
                    'product_name' => $item['product_name'],
                    'unit_price' => $item['unit_price'],
                    'quantity' => $item['quantity'],
                    'supplier_id' => $item['supplier_id'],
                    'supplier_name' => $item['supplier_name'],
                    'image_url' => $item['image_url'] ?? null,
                ]);
            }

            return $order->load('items');
        });
    }
    private function resolveIdempotentOrder(
        Order $order,
        string $payloadHash,
    ): Order {
        $storedHash = $order->idempotency_payload_hash;

        if (
            !is_string($storedHash)
            || !hash_equals($storedHash, $payloadHash)
        ) {
            throw new ConflictHttpException(
                'The Idempotency-Key was already used for a different order payload.',
            );
        }

        return $order->loadMissing('items');
    }

    /**
     * Produce a deterministic hash for the logical create-order payload.
     *
     * @param array<string, mixed> $data
     */
    private function payloadHash(array $data): string
    {
        return hash(
            'sha256',
            json_encode(
                $this->normalizeForHash($data),
                JSON_THROW_ON_ERROR | JSON_PRESERVE_ZERO_FRACTION,
            ),
        );
    }

    private function normalizeForHash(mixed $value): mixed
    {
        if (!is_array($value)) {
            return $value;
        }

        if (array_is_list($value)) {
            return array_map(
                fn (mixed $item): mixed => $this->normalizeForHash($item),
                $value,
            );
        }

        ksort($value);

        foreach ($value as $key => $item) {
            $value[$key] = $this->normalizeForHash($item);
        }

        return $value;
    }
    /**
     * Ensure every supplier exists and currently has
     * the active "supplier" capability.
     *
     * @param  array<int, array<string, mixed>>  $items
     */
    private function validateSuppliers(array $items): void
    {
        $supplierIds = collect($items)
            ->pluck('supplier_id')
            ->unique()
            ->values();

        $validSupplierIds = Business::query()
            ->whereIn('id', $supplierIds)
            ->whereHas('capabilities', function ($query): void {
                $query
                    ->where('business_capabilities.code', 'supplier')
                    ->whereNull('business_capability_assignments.disabled_at');
            })
            ->pluck('id');

        $invalidSupplierIds = $supplierIds->diff($validSupplierIds);

        if ($invalidSupplierIds->isNotEmpty()) {
            throw ValidationException::withMessages([
                'items' => [
                    'One or more suppliers are invalid or do not have an active supplier capability.',
                ],
            ]);
        }
    }
}
