<?php

namespace Tests\Feature\Api\V1\Order;

use App\Models\Business;
use App\Models\User;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OrderApiTest extends TestCase
{
    use RefreshDatabase;

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

        // نستخدم UUID صالح شكليًا حتى يكون الخطأ المستهدف هو quantity.
        $payload = [
            'items' => [
                [
                    'product_id' => 'product-1',
                    'product_name' => 'Test product',
                    'unit_price' => 100,
                    'quantity' => 0,
                    'supplier_id' => '00000000-0000-4000-8000-000000000001',
                    'supplier_name' => 'Test supplier',
                    'image_url' => null,
                ],
            ],
        ];

        $this
            ->withToken($this->tokenFor($user))
            ->postJson('/api/v1/orders', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.quantity',
            ]);

        $this->assertDatabaseCount('orders', 0);
    }

    public function test_supplier_must_exist(): void
    {
        $user = User::factory()->create();

        // UUID صالح لكنه لا يشير إلى Business موجود في قاعدة البيانات.
        $payload = [
            'items' => [
                [
                    'product_id' => 'product-1',
                    'product_name' => 'Test product',
                    'unit_price' => 100,
                    'quantity' => 1,
                    'supplier_id' => '00000000-0000-4000-8000-000000000001',
                    'supplier_name' => 'Missing supplier',
                    'image_url' => null,
                ],
            ],
        ];

        $this
            ->withToken($this->tokenFor($user))
            ->postJson('/api/v1/orders', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.supplier_id',
            ]);

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_items', 0);
    }

    public function test_supplier_must_have_active_supplier_capability(): void
    {
        $user = User::factory()->create();

        // المورد موجود ولديه supplier capability،
        // لكنها معطلة حاليًا، لذلك يجب رفض الطلب.
        $supplier = $this->createSupplier(
            name: 'Disabled supplier',
            active: false,
        );

        $this
            ->withToken($this->tokenFor($user))
            ->postJson(
                '/api/v1/orders',
                $this->orderPayload($supplier),
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items',
            ]);

        // فشل Business validation يجب ألا يترك بيانات جزئية.
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

    public function test_order_and_order_items_are_persisted(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Persistence supplier',
        );

        $response = $this
            ->withToken($this->tokenFor($user))
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
            'product_id' => 'product-1',
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

        // Order واحد يحتوي Items تابعة لأكثر من Supplier.
        // هذه قاعدة أساسية في Multi-Supplier Orders.
        $payload = [
            'notes' => 'Multi supplier order',
            'items' => [
                [
                    'product_id' => 'product-1',
                    'product_name' => 'First product',
                    'unit_price' => 100,
                    'quantity' => 2,
                    'supplier_id' => $firstSupplier->id,
                    'supplier_name' => $firstSupplier->name,
                    'image_url' => null,
                ],
                [
                    'product_id' => 'product-2',
                    'product_name' => 'Second product',
                    'unit_price' => 250,
                    'quantity' => 3,
                    'supplier_id' => $secondSupplier->id,
                    'supplier_name' => $secondSupplier->name,
                    'image_url' => null,
                ],
            ],
        ];

        $response = $this
            ->withToken($this->tokenFor($user))
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
            'product_id' => 'product-1',
            'supplier_id' => $firstSupplier->id,
        ]);

        $this->assertDatabaseHas('order_items', [
            'order_id' => $orderId,
            'product_id' => 'product-2',
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
                'product-1',
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
     * Build a valid single-supplier request payload.
     *
     * أسماء المنتج والمورد والسعر تحفظ كـ Snapshot
     * حتى يحتفظ الطلب التاريخي ببيانات وقت الإنشاء.
     *
     * @return array<string, mixed>
     */
    private function orderPayload(Business $supplier): array
    {
        return [
            'notes' => 'Test order',
            'items' => [
                [
                    'product_id' => 'product-1',
                    'product_name' => 'Test product',
                    'unit_price' => 100,
                    'quantity' => 2,
                    'supplier_id' => $supplier->id,
                    'supplier_name' => $supplier->name,
                    'image_url' => null,
                ],
            ],
        ];
    }
}
