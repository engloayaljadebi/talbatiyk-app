<?php

namespace App\Services\Order;

use App\Models\Business;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;

/*
|--------------------------------------------------------------------------
| Order Service
|--------------------------------------------------------------------------
|
| Creates an Order aggregate while preserving idempotency and resolving
| all commercial Product/Supplier data from the server.
|
| Client values are intent/concurrency expectations only.
|
*/
class OrderService
{
    public function __construct(
        private readonly OrderAggregateStatusResolver $aggregateStatusResolver,
    ) {}

    /**
     * Create a new order for the authenticated user.
     *
     * @param array{
     *     notes?: string|null,
     *     items: array<int, array{
     *         product_id: string,
     *         quantity: int,
     *         expected_unit_price: numeric-string|int|float,
     *         expected_supplier_id: string
     *     }>
     * } $data
     */
    public function create(
        User $user,
        array $data,
        string $idempotencyKey,
    ): Order {
        $payloadHash = $this->payloadHash($data);

        /*
         * A successful logical operation must be replayable even if Product
         * price, stock or supplier state changed after the original success.
         */
        $existingOrder = $user->orders()
            ->where('idempotency_key', $idempotencyKey)
            ->first();

        if ($existingOrder !== null) {
            return $this->withAggregateStatus(
                $this->resolveIdempotentOrder(
                    $existingOrder,
                    $payloadHash,
                ),
            );
        }

        $order = DB::transaction(function () use (
            $user,
            $data,
            $idempotencyKey,
            $payloadHash,
        ): Order {
            /*
             * firstOrCreate is intentionally before commercial validation.
             * If a concurrent retry already created this logical Order,
             * return that aggregate instead of re-validating later state.
             *
             * Any validation exception below rolls this new row back.
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

            if (! $order->wasRecentlyCreated) {
                return $this->resolveIdempotentOrder(
                    $order,
                    $payloadHash,
                );
            }

            $authoritativeItems = $this->resolveAuthoritativeItems(
                $data['items'],
            );

            $createdItems = collect();

            foreach ($authoritativeItems as $item) {
                $createdItems->push(
                    $order->items()->create($item),
                );
            }

            foreach ($createdItems->groupBy('supplier_id') as $supplierId => $supplierItems) {
                $firstItem = $supplierItems->first();

                $recipient = $order->recipients()->create([
                    'supplier_id' => (string) $supplierId,
                    'supplier_name' => $firstItem->supplier_name,
                ]);

                foreach ($supplierItems as $orderItem) {
                    $recipient->items()->create([
                        'order_item_id' => $orderItem->id,
                    ]);
                }
            }

            return $order->load('items');
        });

        return $this->withAggregateStatus($order);
    }

    private function withAggregateStatus(Order $order): Order
    {
        $order->setAttribute(
            'aggregate_status',
            $this->aggregateStatusResolver
                ->resolveCurrent($order)
                ->value,
        );

        return $order;
    }

    private function resolveIdempotentOrder(
        Order $order,
        string $payloadHash,
    ): Order {
        $storedHash = $order->idempotency_payload_hash;

        if (
            ! is_string($storedHash)
            || ! hash_equals($storedHash, $payloadHash)
        ) {
            throw new ConflictHttpException(
                'The Idempotency-Key was already used for a different order payload.',
            );
        }

        return $order->loadMissing('items');
    }

    /**
     * Resolve the current Product/Supplier state and build the immutable
     * historical snapshot stored in OrderItem.
     *
     * Products are locked while this aggregate is created so their
     * commercial state cannot change between validation and snapshot write.
     *
     * @param  array<int, array<string, mixed>>  $items
     * @return array<int, array<string, mixed>>
     */
    private function resolveAuthoritativeItems(array $items): array
    {
        $productIds = collect($items)
            ->pluck('product_id')
            ->unique()
            ->sort()
            ->values();

        $products = Product::query()
            ->with('supplier:id,name')
            ->whereIn('id', $productIds)
            ->lockForUpdate()
            ->get()
            ->keyBy('id');

        $supplierIds = $products
            ->pluck('supplier_id')
            ->unique()
            ->values();

        /*
         * Supplier eligibility is enforced server-side, not inferred from
         * supplier_id supplied by Flutter.
         */
        $validSupplierIds = Business::query()
            ->whereIn('id', $supplierIds)
            ->where('status', 'active')
            ->whereHas('capabilities', function ($query): void {
                $query
                    ->where('business_capabilities.code', 'supplier')
                    ->whereNull('business_capabilities.retired_at')
                    ->whereNull(
                        'business_capability_assignments.disabled_at',
                    );
            })
            ->lockForUpdate()
            ->pluck('id')
            ->flip();

        $resolved = [];

        foreach ($items as $index => $item) {
            /** @var Product|null $product */
            $product = $products->get($item['product_id']);

            if ($product === null) {
                throw ValidationException::withMessages([
                    "items.$index.product_id" => [
                        'The selected product does not exist.',
                    ],
                ]);
            }

            if (
                ! $product->is_available
                || ! $validSupplierIds->has($product->supplier_id)
                || $product->supplier === null
            ) {
                throw ValidationException::withMessages([
                    "items.$index.product_id" => [
                        'The selected product is not currently available.',
                    ],
                ]);
            }

            if ($product->quantity < $item['quantity']) {
                throw ValidationException::withMessages([
                    "items.$index.quantity" => [
                        'The requested quantity exceeds current stock.',
                    ],
                ]);
            }

            /*
             * A supplier change changes the commercial meaning of the item.
             * Never silently substitute another supplier.
             */
            if (
                $product->supplier_id
                !== $item['expected_supplier_id']
            ) {
                throw new ConflictHttpException(
                    'The product supplier has changed. Refresh product data and retry.',
                );
            }

            /*
             * Product.price is the current pricing authority in this stage.
             * Compare in minor units to avoid direct floating-point equality.
             */
            if (
                $this->moneyInMinorUnits($product->price)
                !== $this->moneyInMinorUnits(
                    $item['expected_unit_price'],
                )
            ) {
                throw new ConflictHttpException(
                    'The product price has changed. Refresh product data and retry.',
                );
            }

            $resolved[] = [
                'product_id' => $product->id,
                'product_name' => $product->name,
                'unit_price' => $product->price,
                'quantity' => $item['quantity'],
                'supplier_id' => $product->supplier_id,
                'supplier_name' => $product->supplier->name,
                'image_url' => $product->image_url,
            ];
        }

        return $resolved;
    }

    /**
     * Convert a two-decimal commercial price to integer minor units.
     */
    private function moneyInMinorUnits(mixed $value): int
    {
        return (int) round(((float) $value) * 100);
    }

    /**
     * Produce a deterministic hash for one logical create-order payload.
     *
     * @param  array<string, mixed>  $data
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
        if (! is_array($value)) {
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
}
