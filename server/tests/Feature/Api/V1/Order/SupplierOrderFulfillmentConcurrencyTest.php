<?php

namespace Tests\Feature\Api\V1\Order;

use App\Actions\Order\SelectOrderSupplierResponsesAction;
use App\Actions\Order\SubmitSupplierOrderResponseAction;
use App\Actions\Order\UpdateSupplierFulfillmentAction;
use App\Models\Business;
use App\Models\OrderRecipient;
use App\Models\Product;
use App\Models\User;
use App\Services\Order\OrderService;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Support\Facades\Concurrency;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;
use RuntimeException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Tests\TestCase;

class SupplierOrderFulfillmentConcurrencyTest extends TestCase
{
    use DatabaseMigrations;

    protected function setUp(): void
    {
        parent::setUp();

        $this->assertSame(
            'pgsql',
            DB::connection()->getDriverName(),
            'Fulfillment concurrency acceptance tests require PostgreSQL.',
        );

        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_same_recipient_same_version_allows_exactly_one_transition(): void
    {
        $buyer = User::factory()->create();
        $member = User::factory()->create();

        $supplier = $this->createSupplier(
            'Same recipient concurrency supplier',
            $member,
        );

        $product = $this->createProduct(
            $supplier,
            'Same recipient concurrency product',
        );

        $order = $this->createOrder(
            $buyer,
            [
                [$product, 2],
            ],
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

        $supplierId = (string) $supplier->id;
        $recipientId = (string) $recipient->id;
        $actorId = (string) $member->id;

        $barrierDirectory = storage_path(
            'framework/testing/fulfillment-same-recipient-'
            .uniqid('', true),
        );

        File::ensureDirectoryExists($barrierDirectory);

        $makeTask = static function (
            string $worker,
        ) use (
            $barrierDirectory,
            $supplierId,
            $recipientId,
            $actorId,
        ): \Closure {
            return static function () use (
                $worker,
                $barrierDirectory,
                $supplierId,
                $recipientId,
                $actorId,
            ): string {
                $supplier = Business::query()
                    ->findOrFail($supplierId);

                $actor = User::query()
                    ->findOrFail($actorId);

                file_put_contents(
                    $barrierDirectory
                    .DIRECTORY_SEPARATOR
                    .$worker
                    .'.ready',
                    'ready',
                );

                $deadline = microtime(true) + 15;

                while (true) {
                    $readyWorkers = glob(
                        $barrierDirectory
                        .DIRECTORY_SEPARATOR
                        .'*.ready',
                    ) ?: [];

                    if (count($readyWorkers) >= 2) {
                        break;
                    }

                    if (microtime(true) >= $deadline) {
                        throw new RuntimeException(
                            'Timed out waiting for concurrent fulfillment workers.',
                        );
                    }

                    usleep(10_000);
                }

                try {
                    $result = app(
                        UpdateSupplierFulfillmentAction::class,
                    )->execute(
                        $supplier,
                        $recipientId,
                        $actor,
                        [
                            'expected_version' => 2,
                            'status' => 'preparing',
                        ],
                    );

                    return 'ok:'
                        .(int) $result->fulfillment_version;
                } catch (ConflictHttpException $exception) {
                    return 'conflict:'
                        .$exception->getStatusCode();
                }
            };
        };

        try {
            $results = Concurrency::driver('process')->run(
                [
                    $makeTask('worker-a'),
                    $makeTask('worker-b'),
                ],
                30,
            );
        } finally {
            File::deleteDirectory($barrierDirectory);
        }

        $successes = collect($results)
            ->filter(
                static fn (string $result): bool => str_starts_with($result, 'ok:'),
            )
            ->values();

        $conflicts = collect($results)
            ->filter(
                static fn (string $result): bool => str_starts_with($result, 'conflict:'),
            )
            ->values();

        $this->assertSame(
            ['ok:3'],
            $successes->all(),
        );

        $this->assertSame(
            ['conflict:409'],
            $conflicts->all(),
        );

        $recipient->refresh();

        $this->assertSame(
            'preparing',
            $recipient->fulfillment_status->value,
        );

        $this->assertSame(
            3,
            (int) $recipient->fulfillment_version,
        );

        $this->assertDatabaseCount(
            'order_recipient_fulfillment_histories',
            1,
        );

        $this->assertDatabaseHas(
            'order_recipient_fulfillment_histories',
            [
                'order_recipient_id' => $recipient->id,
                'from_status' => 'confirmed',
                'to_status' => 'preparing',
            ],
        );

        $this->assertDatabaseHas(
            'order_item_selections',
            [
                'order_recipient_item_response_id' => $responseItemId,
                'selected_quantity' => 1,
            ],
        );
    }

    public function test_different_recipients_can_transition_without_version_conflict(): void
    {
        $buyer = User::factory()->create();

        $memberA = User::factory()->create();
        $memberB = User::factory()->create();

        $supplierA = $this->createSupplier(
            'Concurrent supplier A',
            $memberA,
        );

        $supplierB = $this->createSupplier(
            'Concurrent supplier B',
            $memberB,
        );

        $productA = $this->createProduct(
            $supplierA,
            'Concurrent product A',
        );

        $productB = $this->createProduct(
            $supplierB,
            'Concurrent product B',
        );

        $order = $this->createOrder(
            $buyer,
            [
                [$productA, 2],
                [$productB, 2],
            ],
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

        $responseA = $this->submitResponse(
            $supplierA,
            $recipientA,
        );

        $responseB = $this->submitResponse(
            $supplierB,
            $recipientB,
        );

        app(SelectOrderSupplierResponsesAction::class)->execute(
            $buyer,
            (string) $order->id,
            [
                'expected_version' => 1,
                'selections' => [
                    [
                        'order_recipient_item_response_id' => $responseA,
                        'selected_quantity' => 1,
                    ],
                    [
                        'order_recipient_item_response_id' => $responseB,
                        'selected_quantity' => 1,
                    ],
                ],
            ],
        );

        $recipientA->refresh();
        $recipientB->refresh();

        $this->assertSame(
            2,
            (int) $recipientA->fulfillment_version,
        );

        $this->assertSame(
            2,
            (int) $recipientB->fulfillment_version,
        );

        $barrierDirectory = storage_path(
            'framework/testing/fulfillment-independent-'
            .uniqid('', true),
        );

        File::ensureDirectoryExists($barrierDirectory);

        $makeTask = static function (
            string $worker,
            string $supplierId,
            string $recipientId,
            string $actorId,
        ) use ($barrierDirectory): \Closure {
            return static function () use (
                $worker,
                $supplierId,
                $recipientId,
                $actorId,
                $barrierDirectory,
            ): string {
                $supplier = Business::query()
                    ->findOrFail($supplierId);

                $actor = User::query()
                    ->findOrFail($actorId);

                file_put_contents(
                    $barrierDirectory
                    .DIRECTORY_SEPARATOR
                    .$worker
                    .'.ready',
                    'ready',
                );

                $deadline = microtime(true) + 15;

                while (true) {
                    $readyWorkers = glob(
                        $barrierDirectory
                        .DIRECTORY_SEPARATOR
                        .'*.ready',
                    ) ?: [];

                    if (count($readyWorkers) >= 2) {
                        break;
                    }

                    if (microtime(true) >= $deadline) {
                        throw new RuntimeException(
                            'Timed out waiting for independent fulfillment workers.',
                        );
                    }

                    usleep(10_000);
                }

                try {
                    $result = app(
                        UpdateSupplierFulfillmentAction::class,
                    )->execute(
                        $supplier,
                        $recipientId,
                        $actor,
                        [
                            'expected_version' => 2,
                            'status' => 'preparing',
                        ],
                    );

                    return 'ok:'
                        .(int) $result->fulfillment_version;
                } catch (ConflictHttpException $exception) {
                    return 'conflict:'
                        .$exception->getStatusCode();
                }
            };
        };

        try {
            $results = Concurrency::driver('process')->run(
                [
                    $makeTask(
                        'supplier-a',
                        (string) $supplierA->id,
                        (string) $recipientA->id,
                        (string) $memberA->id,
                    ),
                    $makeTask(
                        'supplier-b',
                        (string) $supplierB->id,
                        (string) $recipientB->id,
                        (string) $memberB->id,
                    ),
                ],
                30,
            );
        } finally {
            File::deleteDirectory($barrierDirectory);
        }

        $this->assertSame(
            ['ok:3', 'ok:3'],
            collect($results)->sort()->values()->all(),
        );

        $recipientA->refresh();
        $recipientB->refresh();

        foreach ([$recipientA, $recipientB] as $recipient) {
            $this->assertSame(
                'preparing',
                $recipient->fulfillment_status->value,
            );

            $this->assertSame(
                3,
                (int) $recipient->fulfillment_version,
            );

            $this->assertSame(
                1,
                $recipient->fulfillmentHistory()->count(),
            );
        }

        $this->assertSame(
            2,
            (int) $order->fresh()->version,
            'Supplier fulfillment must not mutate aggregate Order.version.',
        );
    }

    /**
     * @param  array<int, array{0: Product, 1: int}>  $items
     */
    private function createOrder(
        User $buyer,
        array $items,
    ) {
        return app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Fulfillment concurrency order',
                'items' => array_map(
                    static fn (array $entry): array => [
                        'product_id' => $entry[0]->id,
                        'quantity' => $entry[1],
                        'expected_unit_price' => (float) $entry[0]->price,
                        'expected_supplier_id' => $entry[0]->supplier_id,
                    ],
                    $items,
                ),
            ],
            (string) Str::uuid(),
        );
    }

    private function submitResponse(
        Business $supplier,
        OrderRecipient $recipient,
    ): string {
        $recipient->loadMissing('items');

        $recipientItem = $recipient->items->firstOrFail();

        $response = app(
            SubmitSupplierOrderResponseAction::class,
        )->execute(
            $supplier,
            (string) $recipient->id,
            [
                'items' => [
                    [
                        'order_recipient_item_id' => $recipientItem->id,
                        'availability_status' => 'full',
                        'available_quantity' => (int) $recipientItem
                            ->orderItem()
                            ->value('quantity'),
                        'offered_unit_price' => '100.00',
                        'response_notes' => null,
                    ],
                ],
            ],
            (string) Str::uuid(),
        );

        return (string) $response
            ->items
            ->firstOrFail()
            ->id;
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
}
