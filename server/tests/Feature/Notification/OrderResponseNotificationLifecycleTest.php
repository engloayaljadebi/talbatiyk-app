<?php

namespace Tests\Feature\Notification;

use App\Actions\Order\SubmitSupplierOrderResponseAction;
use App\Events\Order\SupplierOrderResponseSubmitted;
use App\Listeners\Order\SendOrderResponseReceivedNotification;
use App\Models\Business;
use App\Models\OrderRecipient;
use App\Models\Product;
use App\Models\User;
use App\Notifications\Order\OrderResponseReceivedNotification;
use App\Services\Order\OrderService;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Contracts\Queue\ShouldQueueAfterCommit;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use RuntimeException;
use Tests\TestCase;

final class OrderResponseNotificationLifecycleTest extends TestCase
{
    use DatabaseMigrations;

    private const IDEMPOTENCY_KEY =
        '72000000-0000-4000-8000-000000000001';

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(
            BusinessCapabilitySeeder::class,
        );
    }

    public function test_listener_is_queued_after_commit(): void
    {
        $this->assertTrue(
            is_a(
                SendOrderResponseReceivedNotification::class,
                ShouldQueueAfterCommit::class,
                true,
            ),
            'The listener must wait for a successful database commit.',
        );

        $this->assertTrue(
            is_a(
                SendOrderResponseReceivedNotification::class,
                ShouldQueue::class,
                true,
            ),
            'The listener must execute through Laravel queue infrastructure.',
        );
    }

    public function test_database_notification_has_stable_application_contract(): void
    {
        [
            $buyer,
            $member,
            $supplier,
            $recipient,
        ] = $this->fixture();

        $responseId =
            (string) Str::uuid();

        $notification =
            new OrderResponseReceivedNotification(
                orderId: (string) $recipient->order_id,
                orderRecipientId: (string) $recipient->id,
                responseId: $responseId,
                supplierId: (string) $supplier->id,
                supplierName: (string) $supplier->name,
            );

        $this->assertSame(
            ['database'],
            $notification->via($buyer),
        );

        $this->assertSame(
            'order_response_received',
            $notification->databaseType($buyer),
        );

        $payload =
            $notification->toDatabase($buyer);

        $this->assertNotSame(
            '',
            trim(
                (string) ($payload['title'] ?? ''),
            ),
        );

        $this->assertNotSame(
            '',
            trim(
                (string) ($payload['body'] ?? ''),
            ),
        );

        $this->assertSame(
            (string) $recipient->order_id,
            data_get(
                $payload,
                'data.order_id',
            ),
        );

        $this->assertSame(
            (string) $recipient->id,
            data_get(
                $payload,
                'data.order_recipient_id',
            ),
        );

        $this->assertSame(
            $responseId,
            data_get(
                $payload,
                'data.response_id',
            ),
        );

        $this->assertSame(
            (string) $supplier->id,
            data_get(
                $payload,
                'data.supplier_id',
            ),
        );

        $this->assertSame(
            (string) $supplier->name,
            data_get(
                $payload,
                'data.supplier_name',
            ),
        );

        $this->assertSame(
            '/orders/'.$recipient->order_id,
            data_get(
                $payload,
                'data.target_route',
            ),
        );

        $this->assertNotSame(
            $buyer->id,
            $member->id,
        );
    }

    public function test_first_response_notifies_customer_once_and_idempotent_replay_does_not_duplicate(): void
    {
        [
            $buyer,
            $member,
            $supplier,
            $recipient,
            $items,
        ] = $this->fixture();

        Notification::fake();

        Sanctum::actingAs($member);

        $payload =
            $this->responsePayload($items);

        $endpoint =
            $this->responseEndpoint(
                $supplier,
                $recipient,
            );

        $first = $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                $endpoint,
                $payload,
            )
            ->assertCreated();

        $second = $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                $endpoint,
                $payload,
            )
            ->assertCreated();

        $this->assertSame(
            $first->json('data.id'),
            $second->json('data.id'),
        );

        $sentToBuyer =
            Notification::sent(
                $buyer,
                OrderResponseReceivedNotification::class,
            );

        $this->assertCount(
            1,
            $sentToBuyer,
            'Replay must not create a second customer notification.',
        );

        $this->assertCount(
            0,
            Notification::sent(
                $member,
                OrderResponseReceivedNotification::class,
            ),
            'The supplier actor must not receive the customer notification.',
        );

        /** @var OrderResponseReceivedNotification $notification */
        $notification =
            $sentToBuyer->first();

        $storedPayload =
            $notification->toDatabase($buyer);

        $this->assertSame(
            (string) $recipient->order_id,
            data_get(
                $storedPayload,
                'data.order_id',
            ),
        );

        $this->assertSame(
            $first->json('data.id'),
            data_get(
                $storedPayload,
                'data.response_id',
            ),
        );
    }

    public function test_outer_transaction_rollback_prevents_notification_delivery(): void
    {
        [
            $buyer,
            $member,
            $supplier,
            $recipient,
            $items,
        ] = $this->fixture();

        Notification::fake();

        try {
            DB::transaction(
                function () use (
                    $supplier,
                    $recipient,
                    $items,
                ): void {
                    app(
                        SubmitSupplierOrderResponseAction::class,
                    )->execute(
                        $supplier,
                        (string) $recipient->id,
                        $this->responsePayload(
                            $items,
                        ),
                        self::IDEMPOTENCY_KEY,
                    );

                    throw new RuntimeException(
                        'Force outer rollback.',
                    );
                },
            );

            $this->fail(
                'The forced rollback was not executed.',
            );
        } catch (RuntimeException $exception) {
            $this->assertSame(
                'Force outer rollback.',
                $exception->getMessage(),
            );
        }

        Notification::assertNothingSent();

        $this->assertDatabaseCount(
            'order_recipient_responses',
            0,
        );

        $this->assertDatabaseCount(
            'notifications',
            0,
        );

        $this->assertNotNull($buyer);
        $this->assertNotNull($member);
    }

    public function test_listener_retry_is_idempotent_for_same_response_event(): void
    {
        [
            $buyer,
            $member,
            $supplier,
            $recipient,
            $items,
        ] = $this->fixture();

        $response =
            app(
                SubmitSupplierOrderResponseAction::class,
            )->execute(
                $supplier,
                (string) $recipient->id,
                $this->responsePayload(
                    $items,
                ),
                self::IDEMPOTENCY_KEY,
            );

        $event =
            new SupplierOrderResponseSubmitted(
                customerUserId: (string) $buyer->id,
                orderId: (string) $recipient->order_id,
                orderRecipientId: (string) $recipient->id,
                responseId: (string) $response->id,
                supplierId: (string) $supplier->id,
                supplierName: (string) $supplier->name,
            );

        $listener =
            app(
                SendOrderResponseReceivedNotification::class,
            );

        /*
         * Simulate queue retry/redelivery explicitly.
         * The same business event may be handled more than once,
         * but it must correspond to one stored notification.
         */
        $listener->handle($event);
        $listener->handle($event);

        $rows =
            $buyer
                ->fresh()
                ->notifications()
                ->where(
                    'type',
                    'order_response_received',
                )
                ->get();

        $this->assertCount(
            1,
            $rows,
            'Queue retry must not duplicate a business notification.',
        );

        $stored =
            $rows->firstOrFail();

        $this->assertSame(
            (string) $response->id,
            data_get(
                $stored->data,
                'data.response_id',
            ),
        );

        $this->assertSame(
            (string) $recipient->order_id,
            data_get(
                $stored->data,
                'data.order_id',
            ),
        );

        $this->assertNotSame(
            $buyer->id,
            $member->id,
        );
    }

    /**
     * @return array{
     *     0: User,
     *     1: User,
     *     2: Business,
     *     3: OrderRecipient,
     *     4: Collection<int, mixed>
     * }
     */
    private function fixture(): array
    {
        $buyer =
            User::factory()->create();

        $member =
            User::factory()->create();

        $supplier =
            Business::query()->create([
                'name' => 'Notification supplier',
                'status' => 'active',
            ]);

        $supplier
            ->capabilities()
            ->attach(
                'supplier',
                [
                    'enabled_at' => now()->subMinute(),
                    'disabled_at' => null,
                ],
            );

        $supplier
            ->memberships()
            ->create([
                'user_id' => $member->id,
                'status' => 'active',
                'joined_at' => now()->subDay(),
                'left_at' => null,
            ]);

        $product =
            new Product;

        $product->id =
            (string) Str::uuid();

        $product->supplier_id =
            $supplier->id;

        $product->name =
            'Notification product';

        $product->description =
            null;

        $product->category =
            '';

        $product->brand =
            '';

        $product->price =
            100;

        $product->quantity =
            100;

        $product->is_available =
            true;

        $product->image_url =
            null;

        $product->colors =
            [];

        $product->discount =
            0;

        $product->rating =
            0;

        $product->save();

        $order =
            app(
                OrderService::class,
            )->create(
                $buyer,
                [
                    'notes' => 'Notification lifecycle test',
                    'supplier_ids' => [
                        $supplier->id,
                    ],
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

        $recipient =
            OrderRecipient::query()
                ->where(
                    'order_id',
                    $order->id,
                )
                ->where(
                    'supplier_id',
                    $supplier->id,
                )
                ->with('items')
                ->firstOrFail();

        return [
            $buyer,
            $member,
            $supplier,
            $recipient,
            $recipient->items->values(),
        ];
    }

    /**
     * @param  Collection<int, mixed>  $items
     * @return array{
     *     items: array<int, array<string, mixed>>
     * }
     */
    private function responsePayload(
        Collection $items,
    ): array {
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

    private function responseEndpoint(
        Business $supplier,
        OrderRecipient $recipient,
    ): string {
        return "/api/v1/businesses/{$supplier->id}"
            ."/received-orders/{$recipient->id}/response";
    }
}
