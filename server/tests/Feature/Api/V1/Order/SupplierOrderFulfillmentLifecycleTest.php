<?php

namespace Tests\Feature\Api\V1\Order;

use App\Actions\Order\SelectOrderSupplierResponsesAction;
use App\Actions\Order\SubmitSupplierOrderResponseAction;
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

class SupplierOrderFulfillmentLifecycleTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_supplier_can_complete_full_fulfillment_lifecycle(): void
    {
        [
            $buyer,
            $member,
            $supplier,
            $order,
            $recipient,
            $responseItemId,
        ] = $this->fixture();

        app(SelectOrderSupplierResponsesAction::class)->execute(
            $buyer,
            (string) $order->id,
            [
                'expected_version' => 1,
                'selections' => [
                    [
                        'order_recipient_item_response_id' => $responseItemId,
                        'selected_quantity' => 1,
                    ],
                ],
            ],
        );

        $this->assertSame(
            2,
            (int) $recipient->fresh()->fulfillment_version,
        );

        $this->actAs($member);

        $transitions = [
            [2, 'preparing', 3],
            [3, 'ready_for_delivery', 4],
            [4, 'out_for_delivery', 5],
            [5, 'delivered', 6],
        ];

        foreach ($transitions as [$expected, $status, $version]) {
            $this
                ->patchJson(
                    $this->endpoint($supplier, $recipient),
                    [
                        'expected_version' => $expected,
                        'status' => $status,
                    ],
                )
                ->assertOk()
                ->assertJsonPath(
                    'data.fulfillment_status',
                    $status,
                )
                ->assertJsonPath(
                    'data.fulfillment_version',
                    $version,
                );
        }

        $recipient->refresh();

        $this->assertSame(
            'delivered',
            $recipient->fulfillment_status->value,
        );

        $this->assertSame(
            6,
            (int) $recipient->fulfillment_version,
        );

        $history = $recipient
            ->fulfillmentHistory()
            ->orderBy('created_at')
            ->orderBy('id')
            ->get();

        $this->assertCount(4, $history);

        $this->assertSame(
            [
                ['confirmed', 'preparing'],
                ['preparing', 'ready_for_delivery'],
                ['ready_for_delivery', 'out_for_delivery'],
                ['out_for_delivery', 'delivered'],
            ],
            $history
                ->map(
                    static fn ($row): array => [
                        $row->from_status->value,
                        $row->to_status->value,
                    ],
                )
                ->all(),
        );

        $this
            ->patchJson(
                $this->endpoint($supplier, $recipient),
                [
                    'expected_version' => 6,
                    'status' => 'preparing',
                ],
            )
            ->assertConflict();

        $recipient->refresh();

        $this->assertSame(
            6,
            (int) $recipient->fulfillment_version,
        );

        $this->assertSame(
            4,
            $recipient->fulfillmentHistory()->count(),
        );

        $this->assertDatabaseHas(
            'order_item_selections',
            [
                'order_recipient_item_response_id' => $responseItemId,
                'selected_quantity' => 1,
            ],
        );
    }

    public function test_two_suppliers_progress_independently(): void
    {
        $buyer = User::factory()->create();

        $memberA = User::factory()->create();
        $memberB = User::factory()->create();

        $supplierA = $this->createSupplier(
            'Lifecycle supplier A',
            $memberA,
        );

        $supplierB = $this->createSupplier(
            'Lifecycle supplier B',
            $memberB,
        );

        $productA = $this->createProduct(
            $supplierA,
            (string) Str::uuid(),
            'Lifecycle product A',
        );

        $productB = $this->createProduct(
            $supplierB,
            (string) Str::uuid(),
            'Lifecycle product B',
        );

        $order = app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Independent supplier fulfillment',
                'supplier_ids' => [$supplierA->id, $supplierB->id],
                'items' => [
                    [
                        'product_id' => $productA->id,
                        'quantity' => 2,
                        'expected_unit_price' => (float) $productA->price,
                        'expected_supplier_id' => $supplierA->id,
                    ],
                    [
                        'product_id' => $productB->id,
                        'quantity' => 2,
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

        $responseItemA = $this->submitResponse(
            $supplierA,
            $recipientA,
            $productA->id,
        );

        $responseItemB = $this->submitResponse(
            $supplierB,
            $recipientB,
            $productB->id,
        );

        app(SelectOrderSupplierResponsesAction::class)->execute(
            $buyer,
            (string) $order->id,
            [
                'expected_version' => 1,
                'selections' => [
                    [
                        'order_recipient_item_response_id' => $responseItemA,
                        'selected_quantity' => 1,
                    ],
                    [
                        'order_recipient_item_response_id' => $responseItemB,
                        'selected_quantity' => 1,
                    ],
                ],
            ],
        );

        $this->assertSame(
            2,
            (int) $recipientA->fresh()->fulfillment_version,
        );

        $this->assertSame(
            2,
            (int) $recipientB->fresh()->fulfillment_version,
        );

        $this->actAs($memberA);

        $this
            ->patchJson(
                $this->endpoint($supplierA, $recipientA),
                [
                    'expected_version' => 2,
                    'status' => 'preparing',
                ],
            )
            ->assertOk();

        $this->actAs($memberB);

        $this
            ->patchJson(
                $this->endpoint($supplierB, $recipientB),
                [
                    'expected_version' => 2,
                    'status' => 'preparing',
                ],
            )
            ->assertOk();

        $this->actAs($memberA);

        $this
            ->patchJson(
                $this->endpoint($supplierA, $recipientA),
                [
                    'expected_version' => 3,
                    'status' => 'ready_for_delivery',
                ],
            )
            ->assertOk();

        $recipientA->refresh();
        $recipientB->refresh();

        $this->assertSame(
            'ready_for_delivery',
            $recipientA->fulfillment_status->value,
        );

        $this->assertSame(
            4,
            (int) $recipientA->fulfillment_version,
        );

        $this->assertSame(
            'preparing',
            $recipientB->fulfillment_status->value,
        );

        $this->assertSame(
            3,
            (int) $recipientB->fulfillment_version,
        );

        $this->actAs($buyer);

        $this
            ->getJson(
                "/api/v1/orders/{$order->id}/supplier-responses",
            )
            ->assertOk()
            ->assertJsonPath(
                'data.aggregate_status',
                'in_fulfillment',
            );

        $this->actAs($memberA);

        $this
            ->patchJson(
                $this->endpoint($supplierA, $recipientA),
                [
                    'expected_version' => 4,
                    'status' => 'out_for_delivery',
                ],
            )
            ->assertOk();

        $this
            ->patchJson(
                $this->endpoint($supplierA, $recipientA),
                [
                    'expected_version' => 5,
                    'status' => 'delivered',
                ],
            )
            ->assertOk();

        $this->actAs($buyer);

        $this
            ->getJson(
                "/api/v1/orders/{$order->id}/supplier-responses",
            )
            ->assertOk()
            ->assertJsonPath(
                'data.aggregate_status',
                'partially_completed',
            );

        $this->actAs($memberB);

        $this
            ->patchJson(
                $this->endpoint($supplierB, $recipientB),
                [
                    'expected_version' => 3,
                    'status' => 'ready_for_delivery',
                ],
            )
            ->assertOk();

        $this
            ->patchJson(
                $this->endpoint($supplierB, $recipientB),
                [
                    'expected_version' => 4,
                    'status' => 'out_for_delivery',
                ],
            )
            ->assertOk();

        $this
            ->patchJson(
                $this->endpoint($supplierB, $recipientB),
                [
                    'expected_version' => 5,
                    'status' => 'delivered',
                ],
            )
            ->assertOk();

        $this->actAs($buyer);

        $this
            ->getJson(
                "/api/v1/orders/{$order->id}/supplier-responses",
            )
            ->assertOk()
            ->assertJsonPath(
                'data.aggregate_status',
                'completed',
            );

        $recipientA->refresh();
        $recipientB->refresh();

        $this->assertSame(
            'delivered',
            $recipientA->fulfillment_status->value,
        );

        $this->assertSame(
            'delivered',
            $recipientB->fulfillment_status->value,
        );

        /*
         * Supplier fulfillment advances Recipient-local versions only.
         * The Order version remains the customer selection concurrency token.
         */
        $this->assertSame(
            2,
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
     *     5: string
     * }
     */
    private function fixture(): array
    {
        $buyer = User::factory()->create();
        $member = User::factory()->create();

        $supplier = $this->createSupplier(
            'Lifecycle supplier',
            $member,
        );

        $product = $this->createProduct(
            $supplier,
            (string) Str::uuid(),
            'Lifecycle product',
        );

        $order = app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Full fulfillment lifecycle',
                'supplier_ids' => [$supplier->id],
                'items' => [
                    [
                        'product_id' => $product->id,
                        'quantity' => 2,
                        'expected_unit_price' => (float) $product->price,
                        'expected_supplier_id' => $supplier->id,
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

        $responseItemId = $this->submitResponse(
            $supplier,
            $recipient,
        );

        return [
            $buyer,
            $member,
            $supplier,
            $order,
            $recipient,
            $responseItemId,
        ];
    }

    private function submitResponse(
        Business $supplier,
        OrderRecipient $recipient,
        ?string $targetProductId = null,
    ): string {
        $recipient->loadMissing('items.orderItem');

        $targetRecipientItem = $targetProductId === null
            ? $recipient->items->firstOrFail()
            : $recipient->items->first(
                static fn ($recipientItem): bool => (string) $recipientItem->orderItem->product_id
                    === $targetProductId,
            );

        if ($targetRecipientItem === null) {
            throw new \RuntimeException(
                'Target recipient item was not found.',
            );
        }

        $response = app(
            SubmitSupplierOrderResponseAction::class,
        )->execute(
            $supplier,
            (string) $recipient->id,
            [
                'items' => $recipient->items
                    ->map(
                        static fn ($recipientItem): array => [
                            'order_recipient_item_id' => $recipientItem->id,
                            'availability_status' => 'full',
                            'available_quantity' => (int) $recipientItem
                                ->orderItem
                                ->quantity,
                            'offered_unit_price' => '100.00',
                            'response_notes' => null,
                        ],
                    )
                    ->values()
                    ->all(),
            ],
            (string) Str::uuid(),
        );

        $responseItem = $response->items->firstWhere(
            'order_recipient_item_id',
            $targetRecipientItem->id,
        );

        if ($responseItem === null) {
            throw new \RuntimeException(
                'Target response item was not found.',
            );
        }

        return (string) $responseItem->id;
    }

    private function createSupplier(
        string $name,
        User $member,
    ): Business {
        $supplier = Business::query()->create([
            'name' => $name,
            'status' => 'active',
        ]);

        $supplier->capabilities()->attach(
            'supplier',
            [
                'enabled_at' => now()->subMinute(),
                'disabled_at' => null,
            ],
        );

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

    private function endpoint(
        Business $supplier,
        OrderRecipient $recipient,
    ): string {
        return "/api/v1/businesses/{$supplier->id}"
            ."/received-orders/{$recipient->id}"
            .'/fulfillment';
    }

    private function actAs(User $user): void
    {
        Auth::forgetGuards();

        Sanctum::actingAs($user);
    }
}
