<?php

namespace Tests\Feature\Api\V1\Order;

use App\Models\Business;
use App\Models\OrderItem;
use App\Models\OrderRecipient;
use App\Models\Product;
use App\Models\User;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class OrderRecipientRoutingApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_supplier_ids_are_required(): void
    {
        $user = User::factory()->create();

        $sourceSupplier = $this->createSupplier(
            'Required supplier source',
        );

        $product = $this->createProduct(
            $sourceSupplier,
            'Required supplier product',
        );

        $payload = $this->payload(
            [$sourceSupplier->id],
            [$product],
        );

        unset($payload['supplier_ids']);

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                (string) Str::uuid(),
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'supplier_ids',
            ]);

        $this->assertDatabaseCount('orders', 0);
    }

    public function test_supplier_ids_cannot_be_empty(): void
    {
        $user = User::factory()->create();

        $sourceSupplier = $this->createSupplier(
            'Empty supplier source',
        );

        $product = $this->createProduct(
            $sourceSupplier,
            'Empty supplier product',
        );

        $payload = $this->payload(
            [],
            [$product],
        );

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                (string) Str::uuid(),
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'supplier_ids',
            ]);

        $this->assertDatabaseCount('orders', 0);
    }

    public function test_each_supplier_id_must_be_uuid(): void
    {
        $user = User::factory()->create();

        $sourceSupplier = $this->createSupplier(
            'UUID supplier source',
        );

        $product = $this->createProduct(
            $sourceSupplier,
            'UUID supplier product',
        );

        $payload = $this->payload(
            ['not-a-uuid'],
            [$product],
        );

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                (string) Str::uuid(),
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'supplier_ids.0',
            ]);

        $this->assertDatabaseCount('orders', 0);
    }

    public function test_supplier_ids_must_be_distinct(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            'Distinct supplier',
        );

        $product = $this->createProduct(
            $supplier,
            'Distinct supplier product',
        );

        $payload = $this->payload(
            [$supplier->id, $supplier->id],
            [$product],
        );

        $response = $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                (string) Str::uuid(),
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertUnprocessable();

        $errors = $response->json('errors');

        $this->assertIsArray($errors);

        $this->assertTrue(
            array_key_exists('supplier_ids.0', $errors)
            || array_key_exists('supplier_ids.1', $errors),
            'Expected duplicate supplier_ids validation error.',
        );

        $this->assertDatabaseCount('orders', 0);
    }

    public function test_selected_recipient_requires_active_supplier_capability(): void
    {
        $user = User::factory()->create();

        $sourceSupplier = $this->createSupplier(
            'Eligible product source',
        );

        $selectedBusiness = $this->createBusiness(
            'Business without supplier capability',
        );

        $product = $this->createProduct(
            $sourceSupplier,
            'Source product',
        );

        $payload = $this->payload(
            [$selectedBusiness->id],
            [$product],
        );

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                (string) Str::uuid(),
            )
            ->postJson('/api/v1/orders', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'supplier_ids',
            ]);

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_recipients', 0);
    }

    public function test_single_selected_supplier_receives_entire_cross_source_basket(): void
    {
        $user = User::factory()->create();

        $sourceSupplierA = $this->createSupplier(
            'Catalog source A',
        );

        $sourceSupplierB = $this->createSupplier(
            'Catalog source B',
        );

        $selectedRecipient = $this->createSupplier(
            'Selected RFQ recipient',
        );

        $productA = $this->createProduct(
            $sourceSupplierA,
            'Cross-source product A',
        );

        $productB = $this->createProduct(
            $sourceSupplierB,
            'Cross-source product B',
        );

        $response = $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                (string) Str::uuid(),
            )
            ->postJson(
                '/api/v1/orders',
                $this->payload(
                    [$selectedRecipient->id],
                    [$productA, $productB],
                ),
            )
            ->assertCreated();

        $orderId = (string) $response->json('data.id');

        $this->assertDatabaseCount('order_recipients', 1);

        $this->assertDatabaseHas('order_recipients', [
            'order_id' => $orderId,
            'supplier_id' => $selectedRecipient->id,
        ]);

        $this->assertDatabaseMissing('order_recipients', [
            'order_id' => $orderId,
            'supplier_id' => $sourceSupplierA->id,
        ]);

        $this->assertDatabaseMissing('order_recipients', [
            'order_id' => $orderId,
            'supplier_id' => $sourceSupplierB->id,
        ]);

        $orderItemA = OrderItem::query()
            ->where('order_id', $orderId)
            ->where('product_id', $productA->id)
            ->firstOrFail();

        $orderItemB = OrderItem::query()
            ->where('order_id', $orderId)
            ->where('product_id', $productB->id)
            ->firstOrFail();

        $this->assertSame(
            (string) $sourceSupplierA->id,
            (string) $orderItemA->supplier_id,
        );

        $this->assertSame(
            (string) $sourceSupplierB->id,
            (string) $orderItemB->supplier_id,
        );

        $recipient = OrderRecipient::query()
            ->where('order_id', $orderId)
            ->where(
                'supplier_id',
                $selectedRecipient->id,
            )
            ->firstOrFail();

        $this->assertDatabaseCount(
            'order_recipient_items',
            2,
        );

        $this->assertDatabaseHas(
            'order_recipient_items',
            [
                'order_recipient_id' => $recipient->id,
                'order_item_id' => $orderItemA->id,
            ],
        );

        $this->assertDatabaseHas(
            'order_recipient_items',
            [
                'order_recipient_id' => $recipient->id,
                'order_item_id' => $orderItemB->id,
            ],
        );
    }

    public function test_reordered_supplier_set_replays_same_idempotent_order(): void
    {
        $user = User::factory()->create();

        $supplierA = $this->createSupplier(
            'Canonical supplier A',
        );

        $supplierB = $this->createSupplier(
            'Canonical supplier B',
        );

        $product = $this->createProduct(
            $supplierA,
            'Canonical product',
        );

        $idempotencyKey = (string) Str::uuid();

        $firstPayload = $this->payload(
            [$supplierA->id, $supplierB->id],
            [$product],
        );

        $first = $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                $idempotencyKey,
            )
            ->postJson('/api/v1/orders', $firstPayload)
            ->assertCreated();

        $secondPayload = $firstPayload;

        $secondPayload['supplier_ids'] = [
            $supplierB->id,
            $supplierA->id,
        ];

        $second = $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                $idempotencyKey,
            )
            ->postJson('/api/v1/orders', $secondPayload)
            ->assertCreated();

        $this->assertSame(
            $first->json('data.id'),
            $second->json('data.id'),
        );

        $this->assertDatabaseCount('orders', 1);
        $this->assertDatabaseCount('order_recipients', 2);
        $this->assertDatabaseCount('order_recipient_items', 2);
    }

    public function test_changed_supplier_set_conflicts_for_same_idempotency_key(): void
    {
        $user = User::factory()->create();

        $supplierA = $this->createSupplier(
            'Conflict supplier A',
        );

        $supplierB = $this->createSupplier(
            'Conflict supplier B',
        );

        $supplierC = $this->createSupplier(
            'Conflict supplier C',
        );

        $product = $this->createProduct(
            $supplierA,
            'Conflict product',
        );

        $idempotencyKey = (string) Str::uuid();

        $firstPayload = $this->payload(
            [$supplierA->id, $supplierB->id],
            [$product],
        );

        $first = $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                $idempotencyKey,
            )
            ->postJson('/api/v1/orders', $firstPayload)
            ->assertCreated();

        $differentPayload = $firstPayload;

        $differentPayload['supplier_ids'] = [
            $supplierA->id,
            $supplierC->id,
        ];

        $this
            ->withToken($this->tokenFor($user))
            ->withHeader(
                'Idempotency-Key',
                $idempotencyKey,
            )
            ->postJson(
                '/api/v1/orders',
                $differentPayload,
            )
            ->assertConflict();

        $orderId = (string) $first->json('data.id');

        $this->assertDatabaseCount('orders', 1);
        $this->assertDatabaseCount('order_recipients', 2);

        $this->assertDatabaseHas('order_recipients', [
            'order_id' => $orderId,
            'supplier_id' => $supplierA->id,
        ]);

        $this->assertDatabaseHas('order_recipients', [
            'order_id' => $orderId,
            'supplier_id' => $supplierB->id,
        ]);

        $this->assertDatabaseMissing('order_recipients', [
            'order_id' => $orderId,
            'supplier_id' => $supplierC->id,
        ]);
    }

    private function tokenFor(User $user): string
    {
        return $user
            ->createToken('routing-test-device')
            ->plainTextToken;
    }

    private function createBusiness(string $name): Business
    {
        return Business::query()->create([
            'name' => $name,
            'status' => 'active',
        ]);
    }

    private function createSupplier(string $name): Business
    {
        $supplier = $this->createBusiness($name);

        $supplier->capabilities()->attach(
            'supplier',
            [
                'enabled_at' => now()->subMinute(),
                'disabled_at' => null,
            ],
        );

        return $supplier;
    }

    private function createProduct(
        Business $supplier,
        string $name,
    ): Product {
        $product = new Product;

        $product->id = (string) Str::uuid();
        $product->supplier_id = $supplier->id;
        $product->name = $name;
        $product->description = null;
        $product->category = '';
        $product->brand = '';
        $product->price = 100;
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
     * @param  array<int, string>  $supplierIds
     * @param  array<int, Product>  $products
     * @return array<string, mixed>
     */
    private function payload(
        array $supplierIds,
        array $products,
    ): array {
        return [
            'notes' => 'Recipient routing acceptance order',
            'supplier_ids' => $supplierIds,
            'items' => array_map(
                static fn (Product $product): array => [
                    'product_id' => $product->id,
                    'quantity' => 1,
                    'expected_unit_price' => (float) $product->price,
                    'expected_supplier_id' => $product->supplier_id,
                ],
                $products,
            ),
        ];
    }
}
