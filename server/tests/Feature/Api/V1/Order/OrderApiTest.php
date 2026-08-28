<?php

namespace Tests\Feature\Api\V1\Order;

use App\Models\Business;
use App\Models\Product;
use App\Models\User;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class OrderApiTest extends TestCase
{
    use RefreshDatabase;

    private const IDEMPOTENCY_KEY = '550e8400-e29b-41d4-a716-446655440000';

    private const PRODUCT_ID = '00000000-0000-4000-8000-000000000101';
    private const SECOND_PRODUCT_ID = '00000000-0000-4000-8000-000000000102';

    public function test_unauthenticated_user_cannot_create_order(): void
    {
        $this
            ->postJson('/api/v1/orders', [])
            ->assertUnauthorized();

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }

    public function test_inactive_user_cannot_create_order(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $token = $this->tokenFor($user);

        $user->update([
            'status' => 'suspended',
        ]);

        $this
            ->withToken($token)
            ->postJson('/api/v1/orders', [])
            ->assertForbidden()
            ->assertJsonPath(
                'code',
                'ACCOUNT_INACTIVE',
            );

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }

    public function test_items_are_required(): void
    {
        $user = User::factory()->create();

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson('/api/v1/orders', [
                'notes' => 'Test order',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items',
            ]);

        $this->assertDatabaseCount('orders', 0);
    }

    public function test_item_quantity_must_be_greater_than_zero(): void
    {
        $user = User::factory()->create();
        $supplier = $this->createSupplier('Quantity supplier');

        $payload = $this->orderPayload($supplier);
        $payload['items'][0]['quantity'] = 0;

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.quantity',
            ]);

        $this->assertDatabaseCount('orders', 0);
    }
    public function test_expected_supplier_id_must_be_valid_uuid(): void
    {
        $user = User::factory()->create();
        $supplier = $this->createSupplier('Expected supplier');

        $payload = $this->orderPayload($supplier);
        $payload['items'][0]['expected_supplier_id'] = 'not-a-uuid';

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.expected_supplier_id',
            ]);

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }
    public function test_supplier_must_have_active_supplier_capability(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Disabled supplier',
            active: false,
        );

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload($supplier),
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.product_id',
            ]);

        // Commercial validation must not leave a partial aggregate.
        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }
    public function test_authenticated_active_user_can_create_order(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Active supplier',
        );

        $response = $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload($supplier),
            );

        $response
            ->assertCreated()
            ->assertJsonPath('data.status', 'pending')
            ->assertJsonPath('data.notes', 'Test order')
            ->assertJsonPath(
                'data.items.0.supplier_id',
                $supplier->id,
            );
    }

    public function test_idempotency_key_is_required(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Idempotency supplier',
        );

        $this
            ->withToken($this->tokenFor($user))
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload($supplier),
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'Idempotency-Key',
            ]);

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }

    public function test_idempotency_key_must_be_valid_uuid(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Invalid key supplier',
        );

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                'not-a-valid-uuid',
            )
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload($supplier),
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'Idempotency-Key',
            ]);

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }

    public function test_same_idempotency_key_and_payload_returns_same_order(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Replay supplier',
        );

        $payload = $this->orderPayload($supplier);

        $firstResponse = $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertCreated();

        $secondResponse = $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertCreated();

        $firstOrderId = $firstResponse->json('data.id');
        $secondOrderId = $secondResponse->json('data.id');

        $this->assertSame(
            $firstOrderId,
            $secondOrderId,
        );

        $this->assertDatabaseHas('orders', [
            'id' => $firstOrderId,
            'user_id' => $user->id,
            'idempotency_key' => self::IDEMPOTENCY_KEY,
        ]);

        // Replay must not create a duplicate aggregate.
        $this->assertDatabaseCount('orders', 1);
        $this->assertDatabaseCount('order_items', 1);
    }

    public function test_same_idempotency_key_with_different_payload_is_conflict(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Conflict supplier',
        );

        $payload = $this->orderPayload($supplier);

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertCreated();

        $differentPayload = $payload;
        $differentPayload['notes'] = 'Different logical order';

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                '/api/v1/orders',
                $differentPayload,
            )
            ->assertStatus(409);

        // Conflict must not mutate the original aggregate.
        $this->assertDatabaseCount('orders', 1);
        $this->assertDatabaseCount('order_items', 1);

        $this->assertDatabaseHas('orders', [
            'user_id' => $user->id,
            'idempotency_key' => self::IDEMPOTENCY_KEY,
            'notes' => 'Test order',
        ]);
    }

    public function test_same_idempotency_key_is_scoped_per_user(): void
    {
        $firstUser = User::factory()->create();
        $secondUser = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Shared key supplier',
        );

        $payload = $this->orderPayload($supplier);

        $firstResponse = $this
            ->withToken($this->tokenFor($firstUser))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertCreated();

        /*
         * Feature tests reuse the application instance.
         * Reset the resolved guard before authenticating another user.
         */
        Auth::forgetGuards();

        $secondResponse = $this
            ->withToken($this->tokenFor($secondUser))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertCreated();

        $this->assertNotSame(
            $firstResponse->json('data.id'),
            $secondResponse->json('data.id'),
        );

        $this->assertDatabaseHas('orders', [
            'user_id' => $firstUser->id,
            'idempotency_key' => self::IDEMPOTENCY_KEY,
        ]);

        $this->assertDatabaseHas('orders', [
            'user_id' => $secondUser->id,
            'idempotency_key' => self::IDEMPOTENCY_KEY,
        ]);

        $this->assertDatabaseCount('orders', 2);
        $this->assertDatabaseCount('order_items', 2);
    }
    public function test_order_and_order_items_are_persisted(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Persistence supplier',
        );

        $response = $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload($supplier),
            )
            ->assertCreated();

        $orderId = $response->json('data.id');

        // نجاح HTTP وحده غير كافٍ؛ نثبت أن الـ Aggregate
        // تم حفظه فعليًا في orders و order_items.
        $this->assertDatabaseHas('orders', [
            'id' => $orderId,
            'user_id' => $user->id,
            'status' => 'pending',
            'notes' => 'Test order',
        ]);

        $this->assertDatabaseHas('order_items', [
            'order_id' => $orderId,
            'product_id' => self::PRODUCT_ID,
            'product_name' => 'Test product',
            'quantity' => 2,
            'supplier_id' => $supplier->id,
            'supplier_name' => $supplier->name,
        ]);

        $this->assertDatabaseCount('orders', 1);
        $this->assertDatabaseCount('order_items', 1);
    }

    public function test_multi_supplier_order_can_be_created(): void
    {
        $user = User::factory()->create();

        $firstSupplier = $this->createSupplier(
            name: 'First supplier',
        );

        $secondSupplier = $this->createSupplier(
            name: 'Second supplier',
        );

        $firstProduct = $this->createProduct(
            supplier: $firstSupplier,
            id: self::PRODUCT_ID,
            name: 'First product',
            price: 100,
        );

        $secondProduct = $this->createProduct(
            supplier: $secondSupplier,
            id: self::SECOND_PRODUCT_ID,
            name: 'Second product',
            price: 250,
        );

        // One Order may contain authoritative Products from many Suppliers.
        $payload = [
            'notes' => 'Multi supplier order',
            'items' => [
                [
                    'product_id' => $firstProduct->id,
                    'quantity' => 2,
                    'expected_unit_price' => 100,
                    'expected_supplier_id' => $firstSupplier->id,
                ],
                [
                    'product_id' => $secondProduct->id,
                    'quantity' => 3,
                    'expected_unit_price' => 250,
                    'expected_supplier_id' => $secondSupplier->id,
                ],
            ],
        ];

        $response = $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson('/api/v1/orders', $payload);

        $response
            ->assertCreated()
            ->assertJsonPath(
                'data.items.0.supplier_id',
                $firstSupplier->id,
            )
            ->assertJsonPath(
                'data.items.1.supplier_id',
                $secondSupplier->id,
            );

        $orderId = $response->json('data.id');

        $this->assertDatabaseCount('orders', 1);
        $this->assertDatabaseCount('order_items', 2);

        $this->assertDatabaseHas('order_items', [
            'order_id' => $orderId,
            'product_id' => $firstProduct->id,
            'supplier_id' => $firstSupplier->id,
        ]);

        $this->assertDatabaseHas('order_items', [
            'order_id' => $orderId,
            'product_id' => $secondProduct->id,
            'supplier_id' => $secondSupplier->id,
        ]);
    }
    public function test_response_contains_correct_order_structure(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Response supplier',
        );

        $response = $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload($supplier),
            );

        $response
            ->assertCreated()
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'status',
                    'notes',
                    'items' => [
                        '*' => [
                            'id',
                            'product_id',
                            'product_name',
                            'unit_price',
                            'quantity',
                            'supplier_id',
                            'supplier_name',
                            'image_url',
                        ],
                    ],
                    'created_at',
                    'updated_at',
                ],
            ])
            ->assertJsonPath('data.status', 'pending')
            ->assertJsonPath('data.notes', 'Test order')
            ->assertJsonPath(
                'data.items.0.product_id',
                self::PRODUCT_ID,
            )
            ->assertJsonPath(
                'data.items.0.product_name',
                'Test product',
            )
            ->assertJsonPath(
                'data.items.0.quantity',
                2,
            )
            ->assertJsonPath(
                'data.items.0.supplier_id',
                $supplier->id,
            )
            ->assertJsonPath(
                'data.items.0.supplier_name',
                $supplier->name,
            )
            // عقد OrderItem لا يكشف تفاصيل الربط الداخلي أو timestamps.
            ->assertJsonMissingPath('data.items.0.order_id')
            ->assertJsonMissingPath('data.items.0.created_at')
            ->assertJsonMissingPath('data.items.0.updated_at')
            ->assertJsonPath('data.items.0.unit_price', '100.00');
    }

    /**
     * Create a Sanctum token using the same authentication
     * flow used by the real API middleware.
     */
    private function tokenFor(User $user): string
    {
        return $user
            ->createToken('test-device')
            ->plainTextToken;
    }

    /**
     * Create a Business with supplier capability.
     *
     * disabled_at = null means the capability is active.
     * A timestamp means the supplier capability is disabled.
     */
    private function createSupplier(
        string $name,
        bool $active = true,
    ): Business {
        // Seeder هو المصدر المرجعي لتعريف supplier و shop.
        $this->seed(BusinessCapabilitySeeder::class);

        $supplier = Business::query()->create([
            'name' => $name,
            'status' => 'active',
        ]);

        $enabledAt = now()->subMinute();

        $supplier->capabilities()->attach('supplier', [
            'enabled_at' => $enabledAt,
            'disabled_at' => $active
                ? null
                : now(),
        ]);

        return $supplier;
    }

    /**
     * Create a server-authoritative Product fixture.
     */
    private function createProduct(
        Business $supplier,
        string $id = self::PRODUCT_ID,
        string $name = 'Test product',
        float $price = 100,
    ): Product {
        $product = new Product();

        $product->id = $id;
        $product->supplier_id = $supplier->id;
        $product->name = $name;
        $product->description = null;
        $product->category = '';
        $product->brand = '';
        $product->price = $price;
        $product->quantity = 100;
        $product->is_available = true;
        $product->image_url = null;
        $product->colors = [];
        $product->discount = 0;
        $product->rating = 0;

        $product->save();

        return $product;
    }

    /**
     * Build valid create-order intent plus commercial expectations.
     *
     * Laravel resolves the historical name/price/supplier snapshot from
     * Product instead of trusting duplicated client snapshot fields.
     *
     * @return array<string, mixed>
     */
    private function orderPayload(Business $supplier): array
    {
        $product = $this->createProduct($supplier);

        return [
            'notes' => 'Test order',
            'items' => [
                [
                    'product_id' => $product->id,
                    'quantity' => 2,
                    'expected_unit_price' => (float) $product->price,
                    'expected_supplier_id' => $supplier->id,
                ],
            ],
        ];
    }}
