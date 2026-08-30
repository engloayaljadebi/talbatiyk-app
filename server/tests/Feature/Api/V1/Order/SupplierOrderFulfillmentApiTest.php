<?php

namespace Tests\Feature\Api\V1\Order;

use App\Actions\Order\SubmitSupplierOrderResponseAction;
use App\Models\Business;
use App\Models\OrderItemSelection;
use App\Models\OrderRecipient;
use App\Models\Product;
use App\Models\User;
use App\Services\Order\OrderService;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SupplierOrderFulfillmentApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_selected_supplier_can_start_fulfillment(): void
    {
        [$member, $supplier, $recipient] = $this->fixture(
            selected: true,
        );

        Sanctum::actingAs($member);

        $this
            ->patchJson(
                $this->endpoint($supplier, $recipient),
                [
                    'expected_version' => 1,
                    'status' => 'preparing',
                ],
            )
            ->assertOk()
            ->assertJsonPath(
                'data.fulfillment_status',
                'preparing',
            )
            ->assertJsonPath(
                'data.fulfillment_version',
                2,
            )
            ->assertJsonPath(
                'data.items.0.selected_quantity',
                1,
            );

        $this->assertDatabaseHas(
            'order_recipients',
            [
                'id' => $recipient->id,
                'fulfillment_status' => 'preparing',
                'fulfillment_version' => 2,
            ],
        );

        $this->assertDatabaseHas(
            'order_recipient_fulfillment_histories',
            [
                'order_recipient_id' => $recipient->id,
                'actor_user_id' => $member->id,
                'from_status' => 'confirmed',
                'to_status' => 'preparing',
            ],
        );
    }

    public function test_supplier_cannot_start_before_customer_selection(): void
    {
        [$member, $supplier, $recipient] = $this->fixture(
            selected: false,
        );

        Sanctum::actingAs($member);

        $this
            ->patchJson(
                $this->endpoint($supplier, $recipient),
                [
                    'expected_version' => 1,
                    'status' => 'preparing',
                ],
            )
            ->assertConflict();

        $this->assertDatabaseCount(
            'order_recipient_fulfillment_histories',
            0,
        );

        $this->assertNull(
            $recipient->fresh()->fulfillment_status,
        );
    }

    public function test_supplier_cannot_skip_fulfillment_state(): void
    {
        [$member, $supplier, $recipient] = $this->fixture(
            selected: true,
        );

        Sanctum::actingAs($member);

        $this
            ->patchJson(
                $this->endpoint($supplier, $recipient),
                [
                    'expected_version' => 1,
                    'status' => 'ready_for_delivery',
                ],
            )
            ->assertConflict();

        $this->assertDatabaseCount(
            'order_recipient_fulfillment_histories',
            0,
        );
    }

    public function test_stale_fulfillment_version_is_conflict(): void
    {
        [$member, $supplier, $recipient] = $this->fixture(
            selected: true,
        );

        Sanctum::actingAs($member);

        $endpoint = $this->endpoint(
            $supplier,
            $recipient,
        );

        $this
            ->patchJson(
                $endpoint,
                [
                    'expected_version' => 1,
                    'status' => 'preparing',
                ],
            )
            ->assertOk();

        $this
            ->patchJson(
                $endpoint,
                [
                    'expected_version' => 1,
                    'status' => 'ready_for_delivery',
                ],
            )
            ->assertConflict();

        $this->assertSame(
            2,
            (int) $recipient->fresh()->fulfillment_version,
        );

        $this->assertDatabaseCount(
            'order_recipient_fulfillment_histories',
            1,
        );
    }

    public function test_received_orders_exposes_selection_and_confirmed_status(): void
    {
        [$member, $supplier, $recipient] = $this->fixture(
            selected: true,
        );

        Sanctum::actingAs($member);

        $this
            ->getJson(
                "/api/v1/businesses/{$supplier->id}/received-orders",
            )
            ->assertOk()
            ->assertJsonPath(
                'data.0.fulfillment_status',
                'confirmed',
            )
            ->assertJsonPath(
                'data.0.fulfillment_version',
                1,
            )
            ->assertJsonPath(
                'data.0.items.0.selected_quantity',
                1,
            );
    }

    public function test_supplier_cannot_update_another_suppliers_recipient(): void
    {
        [$member, $supplier] = $this->fixture(
            selected: true,
        );

        [,, $otherRecipient] = $this->fixture(
            selected: true,
        );

        Sanctum::actingAs($member);

        $this
            ->patchJson(
                $this->endpoint(
                    $supplier,
                    $otherRecipient,
                ),
                [
                    'expected_version' => 1,
                    'status' => 'preparing',
                ],
            )
            ->assertNotFound();
    }

    /**
     * @return array{0: User, 1: Business, 2: OrderRecipient}
     */
    private function fixture(bool $selected): array
    {
        $buyer = User::factory()->create();
        $member = User::factory()->create();

        $supplier = $this->createSupplier(
            'Fulfillment supplier '.Str::random(8),
            $member,
        );

        $product = $this->createProduct(
            $supplier,
            (string) Str::uuid(),
        );

        $order = app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Supplier fulfillment test order',
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

        $recipientItem = $recipient->items->firstOrFail();

        $response = app(
            SubmitSupplierOrderResponseAction::class,
        )->execute(
            $supplier,
            $recipient->id,
            [
                'items' => [
                    [
                        'order_recipient_item_id' => $recipientItem->id,
                        'availability_status' => 'full',
                        'available_quantity' => 2,
                        'offered_unit_price' => '100.00',
                        'response_notes' => null,
                    ],
                ],
            ],
            (string) Str::uuid(),
        );

        if ($selected) {
            $responseItem = $response->items->firstOrFail();

            OrderItemSelection::query()->create([
                'order_item_id' => $recipientItem->order_item_id,
                'order_recipient_item_response_id' => $responseItem->id,
                'selected_quantity' => 1,
            ]);
        }

        return [
            $member,
            $supplier,
            $recipient,
        ];
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
    ): Product {
        $product = new Product;

        $product->id = $id;
        $product->supplier_id = $supplier->id;
        $product->name = 'Fulfillment product';
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
}
