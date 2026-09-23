<?php

namespace Tests\Feature\Notification;

use App\Actions\Order\SubmitSupplierOrderResponseAction;
use App\Actions\Order\UpdateSupplierFulfillmentAction;
use App\Events\Order\SupplierOrderFulfillmentUpdated;
use App\Listeners\Order\SendOrderFulfillmentStatusChangedNotification;
use App\Models\Business;
use App\Models\OrderItemSelection;
use App\Models\OrderRecipient;
use App\Models\Product;
use App\Models\User;
use App\Notifications\Order\OrderFulfillmentStatusChangedNotification;
use App\Services\Order\OrderService;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Contracts\Queue\ShouldQueueAfterCommit;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Str;
use RuntimeException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Tests\TestCase;

final class OrderFulfillmentNotificationLifecycleTest extends TestCase
{
    use DatabaseMigrations;

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
                SendOrderFulfillmentStatusChangedNotification::class,
                ShouldQueueAfterCommit::class,
                true,
            ),
            'Fulfillment notifications must wait for commit.',
        );

        $this->assertTrue(
            is_a(
                SendOrderFulfillmentStatusChangedNotification::class,
                ShouldQueue::class,
                true,
            ),
            'Fulfillment listener must use Laravel queue infrastructure.',
        );
    }

    public function test_database_notification_has_stable_fulfillment_contract(): void
    {
        [
            $buyer,
            $member,
            $supplier,
            $recipient,
        ] = $this->fixture();

        $notification =
            new OrderFulfillmentStatusChangedNotification(
                orderId: (string) $recipient->order_id,
                orderRecipientId: (string) $recipient->id,
                supplierId: (string) $supplier->id,
                supplierName: (string) $supplier->name,
                fulfillmentStatus: 'preparing',
                fulfillmentVersion: 2,
            );

        $this->assertSame(
            ['database'],
            $notification->via($buyer),
        );

        $this->assertSame(
            'order_fulfillment_status_changed',
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
            (string) $supplier->id,
            data_get(
                $payload,
                'data.supplier_id',
            ),
        );

        $this->assertSame(
            'preparing',
            data_get(
                $payload,
                'data.fulfillment_status',
            ),
        );

        $this->assertSame(
            2,
            data_get(
                $payload,
                'data.fulfillment_version',
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

    public function test_successful_transition_notifies_customer_once(): void
    {
        Notification::fake();

        [
            $buyer,
            $member,
            $supplier,
            $recipient,
        ] = $this->fixture();

        $updated =
            app(
                UpdateSupplierFulfillmentAction::class,
            )->execute(
                $supplier,
                (string) $recipient->id,
                $member,
                [
                    'expected_version' => 1,
                    'status' => 'preparing',
                ],
            );

        $this->assertSame(
            'preparing',
            $updated->fulfillment_status->value,
        );

        $this->assertSame(
            2,
            (int) $updated->fulfillment_version,
        );

        $sent =
            Notification::sent(
                $buyer,
                OrderFulfillmentStatusChangedNotification::class,
            );

        $this->assertCount(
            1,
            $sent,
        );

        $this->assertCount(
            0,
            Notification::sent(
                $member,
                OrderFulfillmentStatusChangedNotification::class,
            ),
            'Supplier actor must not receive the customer notification.',
        );

        /** @var OrderFulfillmentStatusChangedNotification $notification */
        $notification =
            $sent->first();

        $payload =
            $notification->toDatabase($buyer);

        $this->assertSame(
            'preparing',
            data_get(
                $payload,
                'data.fulfillment_status',
            ),
        );

        $this->assertSame(
            2,
            data_get(
                $payload,
                'data.fulfillment_version',
            ),
        );
    }

    public function test_stale_version_does_not_create_second_notification(): void
    {
        Notification::fake();

        [
            $buyer,
            $member,
            $supplier,
            $recipient,
        ] = $this->fixture();

        $action =
            app(
                UpdateSupplierFulfillmentAction::class,
            );

        $action->execute(
            $supplier,
            (string) $recipient->id,
            $member,
            [
                'expected_version' => 1,
                'status' => 'preparing',
            ],
        );

        try {
            $action->execute(
                $supplier,
                (string) $recipient->id,
                $member,
                [
                    'expected_version' => 1,
                    'status' => 'ready_for_delivery',
                ],
            );

            $this->fail(
                'Expected stale fulfillment version conflict.',
            );
        } catch (ConflictHttpException) {
            // Expected.
        }

        $this->assertCount(
            1,
            Notification::sent(
                $buyer,
                OrderFulfillmentStatusChangedNotification::class,
            ),
        );

        $this->assertSame(
            2,
            (int) $recipient
                ->fresh()
                ->fulfillment_version,
        );

        $this->assertDatabaseCount(
            'order_recipient_fulfillment_histories',
            1,
        );
    }

    public function test_invalid_skip_does_not_notify_customer(): void
    {
        Notification::fake();

        [
            $buyer,
            $member,
            $supplier,
            $recipient,
        ] = $this->fixture();

        try {
            app(
                UpdateSupplierFulfillmentAction::class,
            )->execute(
                $supplier,
                (string) $recipient->id,
                $member,
                [
                    'expected_version' => 1,
                    'status' => 'ready_for_delivery',
                ],
            );

            $this->fail(
                'Expected invalid transition conflict.',
            );
        } catch (ConflictHttpException) {
            // Expected.
        }

        $this->assertCount(
            0,
            Notification::sent(
                $buyer,
                OrderFulfillmentStatusChangedNotification::class,
            ),
        );

        $this->assertDatabaseCount(
            'order_recipient_fulfillment_histories',
            0,
        );
    }

    public function test_outer_transaction_rollback_prevents_fulfillment_notification(): void
    {
        Notification::fake();

        [
            $buyer,
            $member,
            $supplier,
            $recipient,
        ] = $this->fixture();

        try {
            DB::transaction(
                function () use (
                    $member,
                    $supplier,
                    $recipient,
                ): void {
                    app(
                        UpdateSupplierFulfillmentAction::class,
                    )->execute(
                        $supplier,
                        (string) $recipient->id,
                        $member,
                        [
                            'expected_version' => 1,
                            'status' => 'preparing',
                        ],
                    );

                    throw new RuntimeException(
                        'Force fulfillment rollback.',
                    );
                },
            );

            $this->fail(
                'Forced rollback did not execute.',
            );
        } catch (RuntimeException $exception) {
            $this->assertSame(
                'Force fulfillment rollback.',
                $exception->getMessage(),
            );
        }

        $this->assertCount(
            0,
            Notification::sent(
                $buyer,
                OrderFulfillmentStatusChangedNotification::class,
            ),
        );

        $fresh =
            $recipient->fresh();

        $this->assertNull(
            $fresh->fulfillment_status,
        );

        $this->assertSame(
            1,
            (int) $fresh->fulfillment_version,
        );

        $this->assertDatabaseCount(
            'order_recipient_fulfillment_histories',
            0,
        );
    }

    public function test_listener_retry_is_idempotent_per_recipient_version(): void
    {
        [
            $buyer,
            $member,
            $supplier,
            $recipient,
        ] = $this->fixture();

        $updated =
            app(
                UpdateSupplierFulfillmentAction::class,
            )->execute(
                $supplier,
                (string) $recipient->id,
                $member,
                [
                    'expected_version' => 1,
                    'status' => 'preparing',
                ],
            );

        $event =
            new SupplierOrderFulfillmentUpdated(
                customerUserId: (string) $buyer->id,
                orderId: (string) $recipient->order_id,
                orderRecipientId: (string) $recipient->id,
                supplierId: (string) $supplier->id,
                supplierName: (string) $supplier->name,
                fulfillmentStatus: 'preparing',
                fulfillmentVersion: (int) $updated->fulfillment_version,
            );

        $listener =
            app(
                SendOrderFulfillmentStatusChangedNotification::class,
            );

        $listener->handle($event);
        $listener->handle($event);

        $rows =
            $buyer
                ->fresh()
                ->notifications()
                ->where(
                    'type',
                    'order_fulfillment_status_changed',
                )
                ->get();

        $this->assertCount(
            1,
            $rows,
            'Queue retry must not duplicate a fulfillment transition notification.',
        );

        $stored =
            $rows->firstOrFail();

        $this->assertSame(
            (string) $recipient->id,
            data_get(
                $stored->data,
                'data.order_recipient_id',
            ),
        );

        $this->assertSame(
            2,
            data_get(
                $stored->data,
                'data.fulfillment_version',
            ),
        );
    }

    /**
     * @return array{
     *     0: User,
     *     1: User,
     *     2: Business,
     *     3: OrderRecipient
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
                'name' => 'Fulfillment notification supplier',
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
            'Fulfillment notification product';

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

        $order =
            app(
                OrderService::class,
            )->create(
                $buyer,
                [
                    'notes' => 'Fulfillment notification lifecycle test',
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

        $recipientItem =
            $recipient
                ->items
                ->firstOrFail();

        $response =
            app(
                SubmitSupplierOrderResponseAction::class,
            )->execute(
                $supplier,
                (string) $recipient->id,
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

        $responseItem =
            $response
                ->items
                ->firstOrFail();

        OrderItemSelection::query()->create([
            'order_item_id' => $recipientItem->order_item_id,
            'order_recipient_item_response_id' => $responseItem->id,
            'selected_quantity' => 1,
        ]);

        return [
            $buyer,
            $member,
            $supplier,
            $recipient,
        ];
    }
}
