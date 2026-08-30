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
use Tests\TestCase;

class OrderResponseComparisonApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_owner_can_compare_final_supplier_response(): void
    {
        [$buyer, $member, $supplier, $order, $recipient, $recipientItem]
            = $this->fixture();

        $responseItemId = $this->submitSupplierResponse(
            $member,
            $supplier,
            $recipient,
            $recipientItem->id,
            status: 'full',
            availableQuantity: 2,
            offeredUnitPrice: '95.50',
        );

        $this->actAs($buyer);

        $this
            ->getJson($this->comparisonEndpoint($order))
            ->assertOk()
            ->assertJsonPath('data.id', $order->id)
            ->assertJsonPath('data.version', 1)
            ->assertJsonPath(
                'data.aggregate_status',
                'responses_received',
            )
            ->assertJsonCount(1, 'data.items')
            ->assertJsonPath(
                'data.items.0.id',
                $recipientItem->order_item_id,
            )
            ->assertJsonPath(
                'data.items.0.requested_quantity',
                2,
            )
            ->assertJsonPath(
                'data.items.0.order_unit_price',
                '100.00',
            )
            ->assertJsonPath(
                'data.items.0.supplier.supplier_id',
                $supplier->id,
            )
            ->assertJsonPath(
                'data.items.0.response.id',
                $responseItemId,
            )
            ->assertJsonPath(
                'data.items.0.response.available_quantity',
                2,
            )
            ->assertJsonPath(
                'data.items.0.response.offered_unit_price',
                '95.50',
            )
            ->assertJsonPath(
                'data.items.0.selection',
                null,
            );
    }

    public function test_non_owner_cannot_read_supplier_response_comparison(): void
    {
        [, , , $order] = $this->fixture();

        $outsider = User::factory()->create();

        $this->actAs($outsider);

        $this
            ->getJson($this->comparisonEndpoint($order))
            ->assertNotFound();
    }

    public function test_owner_can_select_supplier_response_and_version_increments(): void
    {
        [$buyer, $member, $supplier, $order, $recipient, $recipientItem]
            = $this->fixture();

        $responseItemId = $this->submitSupplierResponse(
            $member,
            $supplier,
            $recipient,
            $recipientItem->id,
            status: 'full',
            availableQuantity: 2,
            offeredUnitPrice: '95.50',
        );

        $this->actAs($buyer);

        $this
            ->putJson(
                $this->selectionEndpoint($order),
                [
                    'expected_version' => 1,
                    'selections' => [
                        [
                            'order_recipient_item_response_id' => $responseItemId,
                            'selected_quantity' => 1,
                        ],
                    ],
                ],
            )
            ->assertOk()
            ->assertJsonPath('data.version', 2)
            ->assertJsonPath(
                'data.aggregate_status',
                'suppliers_selected',
            )
            ->assertJsonPath(
                'data.items.0.selection.order_recipient_item_response_id',
                $responseItemId,
            )
            ->assertJsonPath(
                'data.items.0.selection.selected_quantity',
                1,
            );

        $this->assertDatabaseHas('order_item_selections', [
            'order_item_id' => $recipientItem->order_item_id,
            'order_recipient_item_response_id' => $responseItemId,
            'selected_quantity' => 1,
        ]);

        $this->assertSame(
            2,
            (int) $order->fresh()->version,
        );

        /*
         * Selection must not rewrite the supplier's final commercial response.
         */
        $this->assertDatabaseHas(
            'order_recipient_item_responses',
            [
                'id' => $responseItemId,
                'requested_quantity' => 2,
                'available_quantity' => 2,
                'availability_status' => 'full',
                'offered_unit_price' => '95.50',
            ],
        );
    }

    public function test_multi_supplier_order_compares_and_selects_independent_supplier_items(): void
    {
        $buyer = User::factory()->create();

        $memberA = User::factory()->create();
        $memberB = User::factory()->create();

        $supplierA = $this->createSupplier(
            'Comparison supplier A',
            $memberA,
        );

        $supplierB = $this->createSupplier(
            'Comparison supplier B',
            $memberB,
        );

        $productA = $this->createProduct(
            $supplierA,
            (string) Str::uuid(),
            'Comparison product A',
        );

        $productB = $this->createProduct(
            $supplierB,
            (string) Str::uuid(),
            'Comparison product B',
        );

        $order = app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Multi supplier comparison order',
                'items' => [
                    [
                        'product_id' => $productA->id,
                        'quantity' => 2,
                        'expected_unit_price' => (float) $productA->price,
                        'expected_supplier_id' => $supplierA->id,
                    ],
                    [
                        'product_id' => $productB->id,
                        'quantity' => 3,
                        'expected_unit_price' => (float) $productB->price,
                        'expected_supplier_id' => $supplierB->id,
                    ],
                ],
            ],
            (string) Str::uuid(),
        );

        $recipients = OrderRecipient::query()
            ->where('order_id', $order->id)
            ->with('items')
            ->get()
            ->keyBy('supplier_id');

        $recipientA = $recipients->get($supplierA->id);
        $recipientB = $recipients->get($supplierB->id);

        $this->assertNotNull($recipientA);
        $this->assertNotNull($recipientB);

        $recipientItemA = $recipientA->items->firstOrFail();
        $recipientItemB = $recipientB->items->firstOrFail();

        $responseItemAId = $this->submitSupplierResponse(
            $memberA,
            $supplierA,
            $recipientA,
            $recipientItemA->id,
            status: 'full',
            availableQuantity: 2,
            offeredUnitPrice: '91.00',
        );

        $responseItemBId = $this->submitSupplierResponse(
            $memberB,
            $supplierB,
            $recipientB,
            $recipientItemB->id,
            status: 'full',
            availableQuantity: 3,
            offeredUnitPrice: '92.00',
        );

        $this->actAs($buyer);

        $this
            ->getJson($this->comparisonEndpoint($order))
            ->assertOk()
            ->assertJsonPath('data.version', 1)
            ->assertJsonCount(2, 'data.items')
            ->assertJsonFragment([
                'supplier_id' => $supplierA->id,
                'supplier_name' => 'Comparison supplier A',
            ])
            ->assertJsonFragment([
                'supplier_id' => $supplierB->id,
                'supplier_name' => 'Comparison supplier B',
            ])
            ->assertJsonFragment([
                'id' => $responseItemAId,
                'offered_unit_price' => '91.00',
            ])
            ->assertJsonFragment([
                'id' => $responseItemBId,
                'offered_unit_price' => '92.00',
            ]);

        $this
            ->putJson(
                $this->selectionEndpoint($order),
                [
                    'expected_version' => 1,
                    'selections' => [
                        [
                            'order_recipient_item_response_id' => $responseItemAId,
                            'selected_quantity' => 1,
                        ],
                        [
                            'order_recipient_item_response_id' => $responseItemBId,
                            'selected_quantity' => 2,
                        ],
                    ],
                ],
            )
            ->assertOk()
            ->assertJsonPath('data.version', 2)
            ->assertJsonCount(2, 'data.items');

        $this->assertDatabaseCount(
            'order_item_selections',
            2,
        );

        $this->assertDatabaseHas(
            'order_item_selections',
            [
                'order_item_id' => $recipientItemA->order_item_id,
                'order_recipient_item_response_id' => $responseItemAId,
                'selected_quantity' => 1,
            ],
        );

        $this->assertDatabaseHas(
            'order_item_selections',
            [
                'order_item_id' => $recipientItemB->order_item_id,
                'order_recipient_item_response_id' => $responseItemBId,
                'selected_quantity' => 2,
            ],
        );

        $this->assertSame(
            2,
            (int) $order->fresh()->version,
        );
    }

    public function test_stale_expected_version_returns_conflict_without_replacing_selection(): void
    {
        [$buyer, $member, $supplier, $order, $recipient, $recipientItem]
            = $this->fixture();

        $responseItemId = $this->submitSupplierResponse(
            $member,
            $supplier,
            $recipient,
            $recipientItem->id,
            status: 'full',
            availableQuantity: 2,
            offeredUnitPrice: '90.00',
        );

        $this->actAs($buyer);

        $this
            ->putJson(
                $this->selectionEndpoint($order),
                $this->selectionPayload(
                    $responseItemId,
                    expectedVersion: 1,
                    selectedQuantity: 1,
                ),
            )
            ->assertOk()
            ->assertJsonPath('data.version', 2);

        $this
            ->putJson(
                $this->selectionEndpoint($order),
                $this->selectionPayload(
                    $responseItemId,
                    expectedVersion: 1,
                    selectedQuantity: 2,
                ),
            )
            ->assertConflict();

        $this->assertDatabaseHas('order_item_selections', [
            'order_item_id' => $recipientItem->order_item_id,
            'selected_quantity' => 1,
        ]);

        $this->assertSame(
            2,
            (int) $order->fresh()->version,
        );
    }

    public function test_selection_cannot_exceed_supplier_available_quantity(): void
    {
        [$buyer, $member, $supplier, $order, $recipient, $recipientItem]
            = $this->fixture();

        $responseItemId = $this->submitSupplierResponse(
            $member,
            $supplier,
            $recipient,
            $recipientItem->id,
            status: 'partial',
            availableQuantity: 1,
            offeredUnitPrice: '80.00',
        );

        $this->actAs($buyer);

        $this
            ->putJson(
                $this->selectionEndpoint($order),
                $this->selectionPayload(
                    $responseItemId,
                    expectedVersion: 1,
                    selectedQuantity: 2,
                ),
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'selections.0.selected_quantity',
            ]);

        $this->assertDatabaseCount('order_item_selections', 0);

        $this->assertSame(
            1,
            (int) $order->fresh()->version,
        );
    }

    public function test_unavailable_supplier_response_cannot_be_selected(): void
    {
        [$buyer, $member, $supplier, $order, $recipient, $recipientItem]
            = $this->fixture();

        $responseItemId = $this->submitSupplierResponse(
            $member,
            $supplier,
            $recipient,
            $recipientItem->id,
            status: 'unavailable',
            availableQuantity: 0,
            offeredUnitPrice: '75.00',
        );

        $this->actAs($buyer);

        $this
            ->putJson(
                $this->selectionEndpoint($order),
                $this->selectionPayload(
                    $responseItemId,
                    expectedVersion: 1,
                    selectedQuantity: 1,
                ),
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'selections.0.selected_quantity',
            ]);

        $this->assertDatabaseCount('order_item_selections', 0);
    }

    public function test_non_owner_cannot_update_supplier_selection(): void
    {
        [, $member, $supplier, $order, $recipient, $recipientItem]
            = $this->fixture();

        $responseItemId = $this->submitSupplierResponse(
            $member,
            $supplier,
            $recipient,
            $recipientItem->id,
            status: 'full',
            availableQuantity: 2,
            offeredUnitPrice: '100.00',
        );

        $outsider = User::factory()->create();

        $this->actAs($outsider);

        $this
            ->putJson(
                $this->selectionEndpoint($order),
                $this->selectionPayload(
                    $responseItemId,
                    expectedVersion: 1,
                    selectedQuantity: 1,
                ),
            )
            ->assertNotFound();

        $this->assertDatabaseCount('order_item_selections', 0);

        $this->assertSame(
            1,
            (int) $order->fresh()->version,
        );
    }

    public function test_current_version_can_replace_existing_selection_atomically(): void
    {
        [$buyer, $member, $supplier, $order, $recipient, $recipientItem]
            = $this->fixture();

        $responseItemId = $this->submitSupplierResponse(
            $member,
            $supplier,
            $recipient,
            $recipientItem->id,
            status: 'full',
            availableQuantity: 2,
            offeredUnitPrice: '92.00',
        );

        $this->actAs($buyer);

        $this
            ->putJson(
                $this->selectionEndpoint($order),
                $this->selectionPayload(
                    $responseItemId,
                    expectedVersion: 1,
                    selectedQuantity: 1,
                ),
            )
            ->assertOk()
            ->assertJsonPath('data.version', 2);

        $this
            ->putJson(
                $this->selectionEndpoint($order),
                $this->selectionPayload(
                    $responseItemId,
                    expectedVersion: 2,
                    selectedQuantity: 2,
                ),
            )
            ->assertOk()
            ->assertJsonPath('data.version', 3)
            ->assertJsonPath(
                'data.items.0.selection.selected_quantity',
                2,
            );

        $this->assertDatabaseCount(
            'order_item_selections',
            1,
        );

        $this->assertDatabaseHas('order_item_selections', [
            'order_item_id' => $recipientItem->order_item_id,
            'selected_quantity' => 2,
        ]);

        $this->assertSame(
            3,
            (int) $order->fresh()->version,
        );
    }

    /**
     * @return array{
     *     0: User,
     *     1: User,
     *     2: Business,
     *     3: Order,
     *     4: OrderRecipient,
     *     5: mixed
     * }
     */
    private function fixture(): array
    {
        $buyer = User::factory()->create();
        $member = User::factory()->create();

        $supplier = $this->createSupplier(
            'Comparison supplier',
            $member,
        );

        $product = $this->createProduct(
            $supplier,
            (string) Str::uuid(),
            'Comparison product',
        );

        $order = app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Response comparison test order',
                'items' => [
                    [
                        'product_id' => $product->id,
                        'quantity' => 2,
                        'expected_unit_price' => (float) $product->price,
                        'expected_supplier_id' => $product->supplier_id,
                    ],
                ],
            ],
            (string) Str::uuid(),
        );

        $recipient = OrderRecipient::query()
            ->where('order_id', $order->id)
            ->where('supplier_id', $supplier->id)
            ->with('items')
            ->firstOrFail();

        return [
            $buyer,
            $member,
            $supplier,
            $order,
            $recipient,
            $recipient->items->firstOrFail(),
        ];
    }

    private function submitSupplierResponse(
        User $member,
        Business $supplier,
        OrderRecipient $recipient,
        string $recipientItemId,
        string $status,
        int $availableQuantity,
        ?string $offeredUnitPrice,
    ): string {
        $this->actAs($member);

        $response = $this
            ->withHeader(
                'Idempotency-Key',
                (string) Str::uuid(),
            )
            ->postJson(
                "/api/v1/businesses/{$supplier->id}"
                ."/received-orders/{$recipient->id}/response",
                [
                    'items' => [
                        [
                            'order_recipient_item_id' => $recipientItemId,
                            'availability_status' => $status,
                            'available_quantity' => $availableQuantity,
                            'offered_unit_price' => $offeredUnitPrice,
                            'response_notes' => 'Stage 5 comparison response',
                        ],
                    ],
                ],
            )
            ->assertCreated();

        return (string) $response->json('data.items.0.id');
    }

    private function createSupplier(
        string $name,
        User $member,
    ): Business {
        $supplier = Business::query()->create([
            'name' => $name,
            'status' => 'active',
        ]);

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

    /**
     * @return array{
     *     expected_version: int,
     *     selections: array<int, array{
     *         order_recipient_item_response_id: string,
     *         selected_quantity: int
     *     }>
     * }
     */
    private function selectionPayload(
        string $responseItemId,
        int $expectedVersion,
        int $selectedQuantity,
    ): array {
        return [
            'expected_version' => $expectedVersion,
            'selections' => [
                [
                    'order_recipient_item_response_id' => $responseItemId,
                    'selected_quantity' => $selectedQuantity,
                ],
            ],
        ];
    }

    private function comparisonEndpoint(Order $order): string
    {
        return "/api/v1/orders/{$order->id}/supplier-responses";
    }

    private function selectionEndpoint(Order $order): string
    {
        return "/api/v1/orders/{$order->id}/supplier-selection";
    }

    private function actAs(User $user): void
    {
        Auth::forgetGuards();

        Sanctum::actingAs($user);
    }
}
