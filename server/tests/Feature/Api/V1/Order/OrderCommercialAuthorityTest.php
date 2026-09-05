<?php

namespace Tests\Feature\Api\V1\Order;

use App\Models\Business;
use App\Models\Product;
use App\Models\User;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/*
|--------------------------------------------------------------------------
| Order Commercial Authority Tests
|--------------------------------------------------------------------------
|
| Verifies that create-order receives client intent/expectations only,
| while Laravel resolves and persists the authoritative Product snapshot.
|
*/
class OrderCommercialAuthorityTest extends TestCase
{
    use RefreshDatabase;

    private const IDEMPOTENCY_KEY = '550e8400-e29b-41d4-a716-446655440001';

    public function test_create_order_uses_server_authoritative_product_snapshot(): void
    {
        $user = User::factory()->create();
        $supplier = $this->createSupplier('Authoritative supplier');

        $product = $this->createProduct($supplier, [
            'name' => 'Server product name',
            'price' => 125.50,
            'quantity' => 10,
            'image_url' => 'https://example.test/server-product.jpg',
        ]);

        $response = $this
            ->withToken($this->tokenFor($user))
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload($product),
            );

        $response
            ->assertCreated()
            ->assertJsonPath('data.items.0.product_id', $product->id)
            ->assertJsonPath(
                'data.items.0.product_name',
                'Server product name',
            )
            ->assertJsonPath('data.items.0.unit_price', '125.50')
            ->assertJsonPath(
                'data.items.0.supplier_id',
                $supplier->id,
            )
            ->assertJsonPath(
                'data.items.0.supplier_name',
                'Authoritative supplier',
            )
            ->assertJsonPath(
                'data.items.0.image_url',
                'https://example.test/server-product.jpg',
            );

        // Historical OrderItem data must come from current server state,
        // not from a commercial snapshot supplied by Flutter.
        $this->assertDatabaseHas('order_items', [
            'product_id' => $product->id,
            'product_name' => 'Server product name',
            'unit_price' => '125.50',
            'quantity' => 2,
            'supplier_id' => $supplier->id,
            'supplier_name' => 'Authoritative supplier',
            'image_url' => 'https://example.test/server-product.jpg',
        ]);
    }

    public function test_product_must_exist_when_creating_order(): void
    {
        $user = User::factory()->create();
        $supplier = $this->createSupplier('Existing supplier');

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson('/api/v1/orders', [
                'supplier_ids' => [$supplier->id],
                'items' => [
                    [
                        'product_id' => '00000000-0000-4000-8000-000000000099',
                        'quantity' => 1,
                        'expected_unit_price' => 100,
                        'expected_supplier_id' => $supplier->id,
                    ],
                ],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.product_id',
            ]);

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }

    public function test_unavailable_product_cannot_be_ordered(): void
    {
        $user = User::factory()->create();
        $supplier = $this->createSupplier('Unavailable supplier');

        $product = $this->createProduct($supplier, [
            'is_available' => false,
        ]);

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload($product),
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.product_id',
            ]);

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }

    public function test_requested_quantity_cannot_exceed_current_stock(): void
    {
        $user = User::factory()->create();
        $supplier = $this->createSupplier('Stock supplier');

        $product = $this->createProduct($supplier, [
            'quantity' => 2,
        ]);

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload(
                    $product,
                    ['quantity' => 3],
                ),
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.quantity',
            ]);

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }

    public function test_changed_product_price_returns_conflict(): void
    {
        $user = User::factory()->create();
        $supplier = $this->createSupplier('Price supplier');

        $product = $this->createProduct($supplier, [
            'price' => 125.50,
        ]);

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload(
                    $product,
                    ['expected_unit_price' => 100],
                ),
            )
            ->assertConflict();

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }

    public function test_changed_product_supplier_returns_conflict(): void
    {
        $user = User::factory()->create();

        $expectedSupplier = $this->createSupplier(
            'Previously viewed supplier',
        );

        $currentSupplier = $this->createSupplier(
            'Current supplier',
        );

        $product = $this->createProduct($currentSupplier);

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload(
                    $product,
                    ['expected_supplier_id' => $expectedSupplier->id],
                ),
            )
            ->assertConflict();

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }

    private function tokenFor(User $user): string
    {
        return $user
            ->createToken('test-device')
            ->plainTextToken;
    }

    private function createSupplier(string $name): Business
    {
        $this->seed(BusinessCapabilitySeeder::class);

        $supplier = Business::query()->create([
            'name' => $name,
            'status' => 'active',
        ]);

        $supplier->capabilities()->attach('supplier', [
            'enabled_at' => now()->subMinute(),
            'disabled_at' => null,
        ]);

        return $supplier;
    }

    public function test_expected_price_above_product_storage_capacity_is_rejected(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            'Price capacity supplier',
        );

        $product = $this->createProduct($supplier);

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload(
                    $product,
                    [
                        'expected_unit_price' =>
                            '10000000000.00',
                    ],
                ),
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.expected_unit_price',
            ]);

        $this->assertDatabaseCount('orders', 0);
    }

    /**
     * Create the current server-side commercial state used by OrderService.
     *
     * @param  array<string, mixed>  $overrides
     */
    private function createProduct(
        Business $supplier,
        array $overrides = [],
    ): Product {
        return Product::query()->create(array_replace([
            'supplier_id' => $supplier->id,
            'name' => 'Commercial product',
            'description' => null,
            'category' => '',
            'brand' => '',
            'price' => 100,
            'quantity' => 10,
            'is_available' => true,
            'image_url' => null,
            'colors' => [],
            'discount' => 0,
            'rating' => 0,
        ], $overrides));
    }

    /**
     * Flutter sends intent plus the commercial values it observed.
     * Laravel must resolve the actual snapshot from Product/Supplier.
     *
     * @param  array<string, mixed>  $overrides
     * @return array<string, mixed>
     */
    private function orderPayload(
        Product $product,
        array $overrides = [],
    ): array {
        return [
            'notes' => 'Commercial authority order',
            'supplier_ids' => [$product->supplier_id],
            'items' => [
                array_replace([
                    'product_id' => $product->id,
                    'quantity' => 2,
                    'expected_unit_price' => (float) $product->price,
                    'expected_supplier_id' => $product->supplier_id,
                ], $overrides),
            ],
        ];
    }

    public function test_idempotent_replay_survives_product_soft_delete(): void
    {
        $user = User::factory()->create();
        $supplier = $this->createSupplier('Replay supplier');

        $product = $this->createProduct(
            $supplier,
            [
                'name' => 'Replay product',
                'price' => 125.50,
                'quantity' => 10,
            ],
        );

        $payload = $this->orderPayload($product);
        $token = $this->tokenFor($user);

        $firstResponse = $this
            ->withToken($token)
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertCreated();

        $orderId = $firstResponse->json('data.id');

        /*
         * A successful logical operation must remain replayable even when
         * the authoritative Product disappears after the first response.
         */
        $product->delete();

        $this
            ->withToken($token)
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertCreated()
            ->assertJsonPath('data.id', $orderId);

        $this->assertDatabaseCount('orders', 1);
        $this->assertDatabaseCount('order_items', 1);
    }
}
