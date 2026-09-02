<?php

namespace Tests\Feature\Api\V1\Order;

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

class OrderSupplierSelectionFulfillmentIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_selection_changes_bump_recipient_fulfillment_version(): void
    {
        [
            $buyer,
            ,
            ,
            $order,
            $recipient,
            $responseItemId,
        ] = $this->fixture();

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

        $this->assertSame(
            2,
            (int) $recipient->fresh()->fulfillment_version,
        );

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
            ->assertJsonPath('data.version', 3);

        $this->assertSame(
            3,
            (int) $recipient->fresh()->fulfillment_version,
        );

        $this->assertDatabaseHas(
            'order_item_selections',
            [
                'order_recipient_item_response_id' => $responseItemId,
                'selected_quantity' => 2,
            ],
        );
    }

    public function test_selection_is_frozen_after_fulfillment_starts(): void
    {
        [
            $buyer,
            $member,
            $supplier,
            $order,
            $recipient,
            $responseItemId,
        ] = $this->fixture();

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
            ->assertOk();

        $this->assertSame(
            2,
            (int) $recipient->fresh()->fulfillment_version,
        );

        $this->actAs($member);

        $this
            ->patchJson(
                $this->fulfillmentEndpoint(
                    $supplier,
                    $recipient,
                ),
                [
                    'expected_version' => 2,
                    'status' => 'preparing',
                ],
            )
            ->assertOk();

        $this->actAs($buyer);

        $this
            ->putJson(
                $this->selectionEndpoint($order),
                $this->selectionPayload(
                    $responseItemId,
                    expectedVersion: 2,
                    selectedQuantity: 2,
                ),
            )
            ->assertConflict();

        $recipient->refresh();

        $this->assertSame(
            'preparing',
            $recipient->fulfillment_status->value,
        );

        $this->assertSame(
            3,
            (int) $recipient->fulfillment_version,
        );

        $this->assertSame(
            2,
            (int) $order->fresh()->version,
        );

        $this->assertDatabaseHas(
            'order_item_selections',
            [
                'order_recipient_item_response_id' => $responseItemId,
                'selected_quantity' => 1,
            ],
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

        $supplier = Business::query()->create([
            'name' => 'Selection fulfillment supplier',
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

        $product = new Product;

        $product->id = (string) Str::uuid();
        $product->supplier_id = $supplier->id;
        $product->name = 'Selection fulfillment product';
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

        $order = app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Selection fulfillment integration',
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

        return [
            $buyer,
            $member,
            $supplier,
            $order,
            $recipient,
            (string) $response->items->firstOrFail()->id,
        ];
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

    private function selectionEndpoint(
        Order $order,
    ): string {
        return "/api/v1/orders/{$order->id}/supplier-selection";
    }

    private function fulfillmentEndpoint(
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
