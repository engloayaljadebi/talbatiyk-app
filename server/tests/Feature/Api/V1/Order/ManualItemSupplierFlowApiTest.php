<?php

namespace Tests\Feature\Api\V1\Order;

use App\Models\Business;
use App\Models\Order;
use App\Models\OrderRecipient;
use App\Models\Product;
use App\Models\User;
use App\Services\Order\OrderService;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\Support\BuildsBusinessMarkets;
use Tests\TestCase;

class ManualItemSupplierFlowApiTest extends TestCase
{
    use BuildsBusinessMarkets;
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_manual_item_flows_through_response_comparison_and_selection(): void
    {
        $buyer = User::factory()->create();
        $this->joinMarket($buyer, $this->market());
        $memberA = User::factory()->create();
        $memberB = User::factory()->create();

        $supplierA = $this->createSupplier('Flow supplier A', $memberA);
        $supplierB = $this->createSupplier('Flow supplier B', $memberB);

        $product = $this->createProduct($supplierA);

        $order = app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Manual flow order',
                'supplier_ids' => [$supplierA->id, $supplierB->id],
                'items' => [
                    [
                        'product_id' => $product->id,
                        'quantity' => 2,
                        'expected_unit_price' => (float) $product->price,
                        'expected_supplier_id' => $supplierA->id,
                    ],
                    [
                        'item_type' => 'manual',
                        'name' => 'Typed by customer',
                        'quantity' => 3,
                        'unit_price' => 50,
                        'unit' => 'box',
                        'note' => 'Any brand',
                    ],
                ],
            ],
            (string) Str::uuid(),
        );

        $manualOrderItem = $order->items->firstWhere('item_type', 'manual');
        $catalogOrderItem = $order->items->firstWhere('item_type', 'catalog');

        $this->assertNotNull($manualOrderItem);
        $this->assertNotNull($catalogOrderItem);

        $recipientA = $this->recipient($order, $supplierA);
        $recipientB = $this->recipient($order, $supplierB);

        $this->assertCount(2, $recipientA->items);
        $this->assertCount(2, $recipientB->items);

        // Supplier B sees the manual item in received orders.
        $this->actAs($memberB);

        $this
            ->getJson("/api/v1/businesses/{$supplierB->id}/received-orders")
            ->assertOk()
            ->assertJsonFragment(['item_type' => 'manual'])
            ->assertJsonFragment(['product_name' => 'Typed by customer']);

        // Each supplier responds independently with its own price.
        $responseA = $this->respond($memberA, $supplierA, $recipientA, '70.00');
        $responseB = $this->respond($memberB, $supplierB, $recipientB, '60.00');

        $manualResponseB = $this->responseItemFor(
            $responseB,
            $recipientB,
            $manualOrderItem->id,
        );
        $catalogResponseA = $this->responseItemFor(
            $responseA,
            $recipientA,
            $catalogOrderItem->id,
        );

        // Buyer compares: both offers for the manual item are visible.
        $this->actAs($buyer);

        $this
            ->getJson("/api/v1/orders/{$order->id}/supplier-responses")
            ->assertOk()
            ->assertJsonFragment(['item_type' => 'manual'])
            ->assertJsonFragment(['offered_unit_price' => '60.00'])
            ->assertJsonFragment(['offered_unit_price' => '70.00']);

        // Buyer selects manual from B and catalog from A.
        $this
            ->putJson("/api/v1/orders/{$order->id}/supplier-selection", [
                'expected_version' => 1,
                'selections' => [
                    [
                        'order_recipient_item_response_id' => $manualResponseB,
                        'selected_quantity' => 3,
                    ],
                    [
                        'order_recipient_item_response_id' => $catalogResponseA,
                        'selected_quantity' => 2,
                    ],
                ],
            ])
            ->assertOk()
            ->assertJsonPath('data.version', 2);

        $this->assertDatabaseHas('order_item_selections', [
            'order_item_id' => $manualOrderItem->id,
            'order_recipient_item_response_id' => $manualResponseB,
            'selected_quantity' => 3,
        ]);

        $this->assertDatabaseHas('order_item_selections', [
            'order_item_id' => $catalogOrderItem->id,
            'order_recipient_item_response_id' => $catalogResponseA,
            'selected_quantity' => 2,
        ]);

        // Customer snapshot price stays untouched by supplier offers.
        $this->assertDatabaseHas('order_items', [
            'id' => $manualOrderItem->id,
            'unit_price' => '50.00',
            'product_id' => null,
            'supplier_id' => null,
        ]);
    }

    public function test_manual_only_order_can_be_answered_and_selected(): void
    {
        $buyer = User::factory()->create();
        $this->joinMarket($buyer, $this->market());
        $member = User::factory()->create();
        $supplier = $this->createSupplier('Manual only supplier', $member);

        $order = app(OrderService::class)->create(
            $buyer,
            [
                'supplier_ids' => [$supplier->id],
                'items' => [
                    [
                        'item_type' => 'manual',
                        'name' => 'Only manual',
                        'quantity' => 4,
                        'unit_price' => 10,
                    ],
                ],
            ],
            (string) Str::uuid(),
        );

        $recipient = $this->recipient($order, $supplier);
        $orderItem = $order->items->firstOrFail();

        $response = $this->respond($member, $supplier, $recipient, '9.00', 4);
        $responseItemId = $this->responseItemFor(
            $response,
            $recipient,
            $orderItem->id,
        );

        $this->actAs($buyer);

        $this
            ->putJson("/api/v1/orders/{$order->id}/supplier-selection", [
                'expected_version' => 1,
                'selections' => [
                    [
                        'order_recipient_item_response_id' => $responseItemId,
                        'selected_quantity' => 4,
                    ],
                ],
            ])
            ->assertOk()
            ->assertJsonPath('data.aggregate_status', 'suppliers_selected');
    }

    private function recipient(Order $order, Business $supplier): OrderRecipient
    {
        return OrderRecipient::query()
            ->where('order_id', $order->id)
            ->where('supplier_id', $supplier->id)
            ->with('items.orderItem')
            ->firstOrFail();
    }

    /**
     * @return array<string, mixed>
     */
    private function respond(
        User $member,
        Business $supplier,
        OrderRecipient $recipient,
        string $price,
        ?int $forceQuantity = null,
    ): array {
        $this->actAs($member);

        return $this
            ->withHeader('Idempotency-Key', (string) Str::uuid())
            ->postJson(
                "/api/v1/businesses/{$supplier->id}"
                ."/received-orders/{$recipient->id}/response",
                [
                    'items' => $recipient->items
                        ->map(
                            static fn ($ri): array => [
                                'order_recipient_item_id' => $ri->id,
                                'availability_status' => 'full',
                                'available_quantity' => $forceQuantity
                                    ?? (int) $ri->orderItem->quantity,
                                'offered_unit_price' => $price,
                                'response_notes' => null,
                            ],
                        )
                        ->values()
                        ->all(),
                ],
            )
            ->assertCreated()
            ->json('data');
    }

    /**
     * @param  array<string, mixed>  $response
     */
    private function responseItemFor(
        array $response,
        OrderRecipient $recipient,
        string $orderItemId,
    ): string {
        $recipientItemId = (string) $recipient->items
            ->firstWhere('order_item_id', $orderItemId)
            ->id;

        $row = collect($response['items'])->firstWhere(
            'order_recipient_item_id',
            $recipientItemId,
        );

        $this->assertNotNull($row);

        return (string) $row['id'];
    }

    private function createSupplier(string $name, User $member): Business
    {
        $supplier = Business::query()->create([
            'name' => $name,
            'status' => 'active',
        ]);

        $supplier->categories()->attach($this->market()->id);

        $supplier->capabilities()->attach('supplier', [
            'enabled_at' => now()->subMinute(),
            'disabled_at' => null,
        ]);

        $supplier->memberships()->create([
            'user_id' => $member->id,
            'status' => 'active',
            'joined_at' => now()->subDay(),
            'left_at' => null,
        ]);

        return $supplier;
    }

    private function createProduct(Business $supplier): Product
    {
        $product = new Product;

        $product->id = (string) Str::uuid();
        $product->supplier_id = $supplier->id;
        $product->name = 'Flow catalog product';
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

    private function actAs(User $user): void
    {
        Auth::forgetGuards();

        Sanctum::actingAs($user);
    }
}
