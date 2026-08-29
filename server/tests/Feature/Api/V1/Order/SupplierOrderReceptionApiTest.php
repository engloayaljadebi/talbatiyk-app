<?php

namespace Tests\Feature\Api\V1\Order;

use App\Models\Business;
use App\Models\OrderItem;
use App\Models\OrderRecipient;
use App\Models\Product;
use App\Models\User;
use App\Services\Order\OrderService;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SupplierOrderReceptionApiTest extends TestCase
{
    use RefreshDatabase;

    private const FIRST_PRODUCT_ID = '00000000-0000-4000-8000-000000000401';

    private const SECOND_PRODUCT_ID = '00000000-0000-4000-8000-000000000402';

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_order_creation_builds_one_recipient_per_supplier(): void
    {
        $buyer = User::factory()->create();
        $firstSupplier = $this->createSupplier('First recipient supplier');
        $secondSupplier = $this->createSupplier('Second recipient supplier');

        $firstProduct = $this->createProduct(
            $firstSupplier,
            self::FIRST_PRODUCT_ID,
            'First recipient product',
        );

        $secondProduct = $this->createProduct(
            $secondSupplier,
            self::SECOND_PRODUCT_ID,
            'Second recipient product',
        );

        $order = $this->createOrder(
            $buyer,
            $firstProduct,
            $secondProduct,
        );

        $this->assertDatabaseCount('order_recipients', 2);
        $this->assertDatabaseCount('order_recipient_items', 2);

        $firstRecipient = OrderRecipient::query()
            ->where('order_id', $order->id)
            ->where('supplier_id', $firstSupplier->id)
            ->firstOrFail();

        $secondRecipient = OrderRecipient::query()
            ->where('order_id', $order->id)
            ->where('supplier_id', $secondSupplier->id)
            ->firstOrFail();

        $firstOrderItem = OrderItem::query()
            ->where('order_id', $order->id)
            ->where('product_id', $firstProduct->id)
            ->firstOrFail();

        $secondOrderItem = OrderItem::query()
            ->where('order_id', $order->id)
            ->where('product_id', $secondProduct->id)
            ->firstOrFail();

        $this->assertDatabaseHas('order_recipient_items', [
            'order_recipient_id' => $firstRecipient->id,
            'order_item_id' => $firstOrderItem->id,
        ]);

        $this->assertDatabaseHas('order_recipient_items', [
            'order_recipient_id' => $secondRecipient->id,
            'order_item_id' => $secondOrderItem->id,
        ]);

        $this->assertDatabaseMissing('order_recipient_items', [
            'order_recipient_id' => $firstRecipient->id,
            'order_item_id' => $secondOrderItem->id,
        ]);
    }

    public function test_active_member_lists_only_recipient_for_requested_supplier(): void
    {
        $buyer = User::factory()->create();
        $member = User::factory()->create();

        $firstSupplier = $this->createSupplier(
            'Visible supplier',
            member: $member,
        );

        $secondSupplier = $this->createSupplier(
            'Hidden supplier',
            member: $member,
        );

        $firstProduct = $this->createProduct(
            $firstSupplier,
            self::FIRST_PRODUCT_ID,
            'Visible product',
        );

        $secondProduct = $this->createProduct(
            $secondSupplier,
            self::SECOND_PRODUCT_ID,
            'Hidden product',
        );

        $this->createOrder(
            $buyer,
            $firstProduct,
            $secondProduct,
        );

        Sanctum::actingAs($member);

        $response = $this->getJson(
            "/api/v1/businesses/{$firstSupplier->id}/received-orders",
        );

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.supplier_id', $firstSupplier->id)
            ->assertJsonCount(1, 'data.0.items')
            ->assertJsonPath(
                'data.0.items.0.product_id',
                $firstProduct->id,
            )
            ->assertJsonPath(
                'data.0.items.0.requested_quantity',
                2,
            )
            ->assertJsonMissing([
                'product_id' => $secondProduct->id,
            ])
            ->assertJsonMissing([
                'supplier_id' => $secondSupplier->id,
            ]);
    }

    public function test_user_without_membership_cannot_read_supplier_orders(): void
    {
        $user = User::factory()->create();
        $supplier = $this->createSupplier('Private supplier');

        Sanctum::actingAs($user);

        $this
            ->getJson(
                "/api/v1/businesses/{$supplier->id}/received-orders",
            )
            ->assertNotFound();
    }

    public function test_suspended_membership_cannot_read_supplier_orders(): void
    {
        $user = User::factory()->create();
        $supplier = $this->createSupplier(
            'Suspended membership supplier',
            member: $user,
            membershipStatus: 'suspended',
        );

        Sanctum::actingAs($user);

        $this
            ->getJson(
                "/api/v1/businesses/{$supplier->id}/received-orders",
            )
            ->assertNotFound();
    }

    public function test_historical_received_order_remains_visible_after_supplier_capability_is_disabled(): void
    {
        $buyer = User::factory()->create();
        $member = User::factory()->create();

        $supplier = $this->createSupplier(
            'Historical supplier',
            member: $member,
        );

        $product = $this->createProduct(
            $supplier,
            self::FIRST_PRODUCT_ID,
            'Historical product',
        );

        $this->createOrder($buyer, $product);

        $supplier->capabilities()->updateExistingPivot('supplier', [
            'disabled_at' => now(),
        ]);

        Sanctum::actingAs($member);

        $this
            ->getJson(
                "/api/v1/businesses/{$supplier->id}/received-orders",
            )
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.supplier_id', $supplier->id)
            ->assertJsonPath(
                'data.0.items.0.product_id',
                $product->id,
            );
    }

    private function createSupplier(
        string $name,
        ?User $member = null,
        string $membershipStatus = 'active',
    ): Business {
        $supplier = Business::query()->create([
            'name' => $name,
            'status' => 'active',
        ]);

        $supplier->capabilities()->attach('supplier', [
            'enabled_at' => now()->subMinute(),
            'disabled_at' => null,
        ]);

        if ($member !== null) {
            $supplier->memberships()->create([
                'user_id' => $member->id,
                'status' => $membershipStatus,
                'joined_at' => now()->subDay(),
                'left_at' => $membershipStatus === 'left'
                    ? now()
                    : null,
            ]);
        }

        return $supplier;
    }

    private function createProduct(
        Business $supplier,
        string $id,
        string $name,
    ): Product {
        $product = new Product;

        $product->id = $id;
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

    private function createOrder(
        User $buyer,
        Product $firstProduct,
        ?Product $secondProduct = null,
    ) {
        $products = array_values(array_filter([
            $firstProduct,
            $secondProduct,
        ]));

        return app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Supplier reception test order',
                'items' => array_map(
                    static fn (Product $product): array => [
                        'product_id' => $product->id,
                        'quantity' => 2,
                        'expected_unit_price' => (float) $product->price,
                        'expected_supplier_id' => $product->supplier_id,
                    ],
                    $products,
                ),
            ],
            (string) Str::uuid(),
        );
    }
}
