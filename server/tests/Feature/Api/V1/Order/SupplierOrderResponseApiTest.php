<?php

namespace Tests\Feature\Api\V1\Order;

use App\Models\Business;
use App\Models\OrderRecipient;
use App\Models\Product;
use App\Models\User;
use App\Services\Order\OrderService;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SupplierOrderResponseApiTest extends TestCase
{
    use RefreshDatabase;

    private const IDEMPOTENCY_KEY = '10000000-0000-4000-8000-000000000001';

    private const SECOND_IDEMPOTENCY_KEY = '10000000-0000-4000-8000-000000000002';

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_active_member_can_submit_full_and_partial_item_responses(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture(2);

        Sanctum::actingAs($member);

        $payload = [
            'items' => [
                [
                    'order_recipient_item_id' => $items[0]->id,
                    'availability_status' => 'full',
                    'available_quantity' => 2,
                    'offered_unit_price' => '95.50',
                    'response_notes' => 'Ready now',
                ],
                [
                    'order_recipient_item_id' => $items[1]->id,
                    'availability_status' => 'partial',
                    'available_quantity' => 1,
                    'offered_unit_price' => '88.00',
                    'response_notes' => 'One unit available',
                ],
            ],
        ];

        $response = $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload);

        $response
            ->assertCreated()
            ->assertJsonPath('data.order_recipient_id', $recipient->id)
            ->assertJsonCount(2, 'data.items');

        $this->assertDatabaseCount('order_recipient_responses', 1);
        $this->assertDatabaseCount('order_recipient_item_responses', 2);

        $this->assertDatabaseHas('order_recipient_item_responses', [
            'order_recipient_item_id' => $items[0]->id,
            'requested_quantity' => 2,
            'available_quantity' => 2,
            'availability_status' => 'full',
            'offered_unit_price' => '95.50',
        ]);

        $this->assertDatabaseHas('order_recipient_item_responses', [
            'order_recipient_item_id' => $items[1]->id,
            'requested_quantity' => 2,
            'available_quantity' => 1,
            'availability_status' => 'partial',
            'offered_unit_price' => '88.00',
        ]);
    }

    public function test_offered_price_is_optional_independent_of_availability_status(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture(2);

        Sanctum::actingAs($member);

        $payload = [
            'items' => [
                [
                    'order_recipient_item_id' => $items[0]->id,
                    'availability_status' => 'full',
                    'available_quantity' => 2,
                    'offered_unit_price' => null,
                    'response_notes' => null,
                ],
                [
                    'order_recipient_item_id' => $items[1]->id,
                    'availability_status' => 'unavailable',
                    'available_quantity' => 0,
                    'offered_unit_price' => '75.00',
                    'response_notes' => null,
                ],
            ],
        ];

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson(
                $this->endpoint($supplier, $recipient),
                $payload,
            )
            ->assertCreated();

        $this->assertDatabaseHas('order_recipient_item_responses', [
            'order_recipient_item_id' => $items[0]->id,
            'availability_status' => 'full',
            'available_quantity' => 2,
            'offered_unit_price' => null,
        ]);

        $this->assertDatabaseHas('order_recipient_item_responses', [
            'order_recipient_item_id' => $items[1]->id,
            'availability_status' => 'unavailable',
            'available_quantity' => 0,
            'offered_unit_price' => '75.00',
        ]);
    }

    public function test_unavailable_item_requires_zero_quantity(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture();

        Sanctum::actingAs($member);

        $payload = $this->fullPayload($items);
        $payload['items'][0]['availability_status'] = 'unavailable';
        $payload['items'][0]['available_quantity'] = 1;
        $payload['items'][0]['offered_unit_price'] = null;

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.available_quantity',
            ]);

        $this->assertDatabaseCount('order_recipient_responses', 0);
    }

    public function test_full_availability_must_equal_requested_quantity(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture();

        Sanctum::actingAs($member);

        $payload = $this->fullPayload($items);
        $payload['items'][0]['available_quantity'] = 1;

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.available_quantity',
            ]);
    }

    public function test_partial_availability_must_be_between_zero_and_requested_quantity(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture();

        Sanctum::actingAs($member);

        $payload = $this->fullPayload($items);
        $payload['items'][0]['availability_status'] = 'partial';
        $payload['items'][0]['available_quantity'] = 2;

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.available_quantity',
            ]);
    }

    public function test_response_must_include_every_recipient_item(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture(2);

        Sanctum::actingAs($member);

        $payload = $this->fullPayload($items);
        array_pop($payload['items']);

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['items']);
    }

    public function test_supplier_cannot_respond_to_another_suppliers_recipient(): void
    {
        [$member, $supplier] = $this->fixture();
        [,, $otherRecipient, $otherItems] = $this->fixture();

        Sanctum::actingAs($member);

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson(
                $this->endpoint($supplier, $otherRecipient),
                $this->fullPayload($otherItems),
            )
            ->assertNotFound();

        $this->assertDatabaseCount('order_recipient_responses', 0);
    }

    public function test_user_without_membership_cannot_submit_response(): void
    {
        [, $supplier, $recipient, $items] = $this->fixture();
        $outsider = User::factory()->create();

        Sanctum::actingAs($outsider);

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson(
                $this->endpoint($supplier, $recipient),
                $this->fullPayload($items),
            )
            ->assertNotFound();
    }

    public function test_suspended_membership_cannot_submit_response(): void
    {
        $member = User::factory()->create();

        [$member, $supplier, $recipient, $items] = $this->fixture(
            member: $member,
            membershipStatus: 'suspended',
        );

        Sanctum::actingAs($member);

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson(
                $this->endpoint($supplier, $recipient),
                $this->fullPayload($items),
            )
            ->assertNotFound();
    }

    public function test_left_membership_cannot_submit_response(): void
    {
        $member = User::factory()->create();

        [$member, $supplier, $recipient, $items] = $this->fixture(
            member: $member,
            membershipStatus: 'left',
        );

        Sanctum::actingAs($member);

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson(
                $this->endpoint($supplier, $recipient),
                $this->fullPayload($items),
            )
            ->assertNotFound();
    }

    public function test_same_idempotency_key_and_payload_replays_same_response(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture();

        Sanctum::actingAs($member);

        $payload = $this->fullPayload($items);

        $first = $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertCreated();

        $second = $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertCreated();

        $this->assertSame(
            $first->json('data.id'),
            $second->json('data.id'),
        );

        $this->assertDatabaseCount('order_recipient_responses', 1);
        $this->assertDatabaseCount('order_recipient_item_responses', 1);
    }

    public function test_same_idempotency_key_with_different_payload_is_conflict(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture();

        Sanctum::actingAs($member);

        $payload = $this->fullPayload($items);

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertCreated();

        $payload['items'][0]['offered_unit_price'] = '90.00';

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertConflict();

        $this->assertDatabaseCount('order_recipient_responses', 1);
    }

    public function test_second_logical_response_is_rejected_after_final_response(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture();

        Sanctum::actingAs($member);

        $payload = $this->fullPayload($items);

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertCreated();

        $this
            ->withHeader('Idempotency-Key', self::SECOND_IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertConflict();

        $this->assertDatabaseCount('order_recipient_responses', 1);
    }

    public function test_requested_quantity_cannot_be_supplied_by_client(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture();

        Sanctum::actingAs($member);

        $payload = $this->fullPayload($items);
        $payload['items'][0]['requested_quantity'] = 999;

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.requested_quantity',
            ]);
    }

    public function test_alternative_status_is_not_accepted_without_business_rule(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture();

        Sanctum::actingAs($member);

        $payload = $this->fullPayload($items);
        $payload['items'][0]['availability_status'] = 'alternative';

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson($this->endpoint($supplier, $recipient), $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'items.0.availability_status',
            ]);
    }

    public function test_received_orders_read_returns_own_submitted_response(): void
    {
        [$member, $supplier, $recipient, $items] = $this->fixture();

        Sanctum::actingAs($member);

        $this
            ->withHeader('Idempotency-Key', self::IDEMPOTENCY_KEY)
            ->postJson(
                $this->endpoint($supplier, $recipient),
                $this->fullPayload($items),
            )
            ->assertCreated();

        $this
            ->getJson(
                "/api/v1/businesses/{$supplier->id}/received-orders",
            )
            ->assertOk()
            ->assertJsonPath('data.0.response.order_recipient_id', $recipient->id)
            ->assertJsonPath(
                'data.0.response.items.0.availability_status',
                'full',
            )
            ->assertJsonPath(
                'data.0.response.items.0.requested_quantity',
                2,
            );
    }

    /**
     * @return array{0: User, 1: Business, 2: OrderRecipient, 3: Collection<int, mixed>}
     */
    private function fixture(
        int $itemCount = 1,
        ?User $member = null,
        string $membershipStatus = 'active',
    ): array {
        $buyer = User::factory()->create();
        $member ??= User::factory()->create();

        $supplier = $this->createSupplier(
            'Response supplier',
            $member,
            $membershipStatus,
        );

        $products = [];

        for ($index = 0; $index < $itemCount; $index++) {
            $products[] = $this->createProduct(
                $supplier,
                (string) Str::uuid(),
                'Response product '.($index + 1),
            );
        }

        $order = app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Supplier response test order',
                'supplier_ids' => [$supplier->id],
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

        $recipient = OrderRecipient::query()
            ->where('order_id', $order->id)
            ->where('supplier_id', $supplier->id)
            ->with('items')
            ->firstOrFail();

        return [
            $member,
            $supplier,
            $recipient,
            $recipient->items->values(),
        ];
    }

    private function createSupplier(
        string $name,
        User $member,
        string $membershipStatus,
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
            'status' => $membershipStatus,
            'joined_at' => now()->subDay(),
            'left_at' => $membershipStatus === 'left'
                ? now()
                : null,
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
     * @param  Collection<int, mixed>  $items
     * @return array{items: array<int, array<string, mixed>>}
     */
    private function fullPayload(Collection $items): array
    {
        return [
            'items' => $items
                ->map(
                    static fn ($item): array => [
                        'order_recipient_item_id' => $item->id,
                        'availability_status' => 'full',
                        'available_quantity' => 2,
                        'offered_unit_price' => '100.00',
                        'response_notes' => null,
                    ],
                )
                ->all(),
        ];
    }

    private function endpoint(
        Business $supplier,
        OrderRecipient $recipient,
    ): string {
        return "/api/v1/businesses/{$supplier->id}"
            ."/received-orders/{$recipient->id}/response";
    }
}
