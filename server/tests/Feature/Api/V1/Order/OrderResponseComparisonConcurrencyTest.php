<?php

namespace Tests\Feature\Api\V1\Order;

use App\Actions\Order\SelectOrderSupplierResponsesAction;
use App\Actions\Order\SubmitSupplierOrderResponseAction;
use App\Models\Business;
use App\Models\OrderRecipient;
use App\Models\OrderRecipientItemResponse;
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

class OrderResponseComparisonConcurrencyTest extends TestCase
{
    use DatabaseMigrations;

    private const PRODUCT_ID =
        '30000000-0000-4000-8000-000000000299';

    public function test_concurrent_same_expected_version_allows_one_selection_only(): void
    {
        $this->assertSame(
            'pgsql',
            DB::connection()->getDriverName(),
            'This acceptance test must run against PostgreSQL.',
        );

        $this->seed(BusinessCapabilitySeeder::class);

        $buyer = User::factory()->create();
        $supplier = $this->createSupplier();
        $product = $this->createProduct($supplier);

        $order = app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Concurrent supplier selection order',
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

        app(SubmitSupplierOrderResponseAction::class)->execute(
            $supplier,
            (string) $recipient->id,
            [
                'items' => [
                    [
                        'order_recipient_item_id' => $recipientItem->id,
                        'availability_status' => 'full',
                        'available_quantity' => 2,
                        'offered_unit_price' => '91.25',
                        'response_notes' => 'Concurrent selection response',
                    ],
                ],
            ],
            (string) Str::uuid(),
        );

        $responseItem = OrderRecipientItemResponse::query()
            ->where(
                'order_recipient_item_id',
                $recipientItem->id,
            )
            ->firstOrFail();

        $buyerId = (string) $buyer->getKey();
        $orderId = (string) $order->getKey();
        $responseItemId = (string) $responseItem->getKey();

        $barrierDirectory = storage_path(
            'framework/testing/order-selection-concurrency-'
            .uniqid('', true),
        );

        File::ensureDirectoryExists($barrierDirectory);

        $makeTask = static function (
            string $worker,
            int $selectedQuantity,
        ) use (
            $barrierDirectory,
            $buyerId,
            $orderId,
            $responseItemId,
        ): \Closure {
            return static function () use (
                $worker,
                $selectedQuantity,
                $barrierDirectory,
                $buyerId,
                $orderId,
                $responseItemId,
            ): string {
                $buyer = User::query()->findOrFail($buyerId);

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
                            'Timed out waiting for both concurrent workers.',
                        );
                    }

                    usleep(10_000);
                }

                try {
                    $result = app(
                        SelectOrderSupplierResponsesAction::class,
                    )->execute(
                        $buyer,
                        $orderId,
                        [
                            'expected_version' => 1,
                            'selections' => [
                                [
                                    'order_recipient_item_response_id' => $responseItemId,
                                    'selected_quantity' => $selectedQuantity,
                                ],
                            ],
                        ],
                    );

                    return sprintf(
                        'ok:%d:%d',
                        (int) $result->version,
                        $selectedQuantity,
                    );
                } catch (ConflictHttpException $exception) {
                    return 'conflict:'.$exception->getStatusCode();
                }
            };
        };

        try {
            $results = Concurrency::driver('process')->run(
                [
                    $makeTask('worker-a', 1),
                    $makeTask('worker-b', 2),
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

        $this->assertCount(
            1,
            $successes,
            'Exactly one concurrent selection must succeed.',
        );

        $this->assertSame(
            ['conflict:409'],
            $conflicts->all(),
            'The losing writer must observe stale-version HTTP conflict semantics.',
        );

        $this->assertSame(
            2,
            (int) $order->fresh()->version,
            'The order version must increment exactly once.',
        );

        $this->assertDatabaseCount(
            'order_item_selections',
            1,
        );

        $selection = DB::table('order_item_selections')
            ->where(
                'order_item_id',
                $recipientItem->order_item_id,
            )
            ->first();

        $this->assertNotNull($selection);

        $successParts = explode(
            ':',
            (string) $successes->first(),
        );

        $this->assertSame(
            '2',
            $successParts[1],
            'The successful writer must receive version 2.',
        );

        $winningQuantity = (int) $successParts[2];

        $this->assertContains(
            $winningQuantity,
            [1, 2],
        );

        $this->assertSame(
            $winningQuantity,
            (int) $selection->selected_quantity,
            'Persisted selection must belong to the successful writer.',
        );

        $this->assertDatabaseHas(
            'order_recipient_item_responses',
            [
                'id' => $responseItemId,
                'requested_quantity' => 2,
                'available_quantity' => 2,
                'availability_status' => 'full',
                'offered_unit_price' => '91.25',
            ],
        );
    }

    private function createSupplier(): Business
    {
        $supplier = Business::query()->create([
            'name' => 'Selection concurrency supplier',
            'status' => 'active',
        ]);

        $supplier->capabilities()->attach('supplier', [
            'enabled_at' => now()->subMinute(),
            'disabled_at' => null,
        ]);

        return $supplier;
    }

    private function createProduct(
        Business $supplier,
    ): Product {
        $product = new Product;

        $product->id = self::PRODUCT_ID;
        $product->supplier_id = $supplier->id;
        $product->name = 'Selection concurrency product';
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
