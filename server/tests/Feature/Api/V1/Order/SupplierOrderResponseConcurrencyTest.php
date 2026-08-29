<?php

namespace Tests\Feature\Api\V1\Order;

use App\Actions\Order\SubmitSupplierOrderResponseAction;
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
use Tests\TestCase;

class SupplierOrderResponseConcurrencyTest extends TestCase
{
    use DatabaseMigrations;

    private const IDEMPOTENCY_KEY = '650e8400-e29b-41d4-a716-446655440099';

    private const PRODUCT_ID = '30000000-0000-4000-8000-000000000199';

    public function test_concurrent_same_key_and_payload_returns_same_response_without_duplicate(): void
    {
        $this->assertSame(
            'pgsql',
            DB::connection()->getDriverName(),
            'This acceptance test must run against PostgreSQL.',
        );

        $buyer = User::factory()->create();
        $supplier = $this->createSupplier();
        $product = $this->createProduct($supplier);

        $order = app(OrderService::class)->create(
            $buyer,
            [
                'notes' => 'Concurrent supplier response order',
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

        $payload = [
            'items' => [
                [
                    'order_recipient_item_id' => $recipientItem->id,
                    'availability_status' => 'full',
                    'available_quantity' => 2,
                    'offered_unit_price' => '91.25',
                    'response_notes' => 'Concurrent response',
                ],
            ],
        ];

        $supplierId = (string) $supplier->getKey();
        $recipientId = (string) $recipient->getKey();
        $idempotencyKey = self::IDEMPOTENCY_KEY;

        $barrierDirectory = storage_path(
            'framework/testing/supplier-response-concurrency-'.uniqid('', true),
        );

        File::ensureDirectoryExists($barrierDirectory);

        $makeTask = static function (string $worker) use (
            $barrierDirectory,
            $supplierId,
            $recipientId,
            $payload,
            $idempotencyKey,
        ): \Closure {
            return static function () use (
                $worker,
                $barrierDirectory,
                $supplierId,
                $recipientId,
                $payload,
                $idempotencyKey,
            ): string {
                $supplier = Business::query()->findOrFail($supplierId);

                file_put_contents(
                    $barrierDirectory.DIRECTORY_SEPARATOR.$worker.'.ready',
                    'ready',
                );

                $deadline = microtime(true) + 15;

                while (true) {
                    $readyWorkers = glob(
                        $barrierDirectory.DIRECTORY_SEPARATOR.'*.ready',
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

                $response = app(
                    SubmitSupplierOrderResponseAction::class,
                )->execute(
                    $supplier,
                    $recipientId,
                    $payload,
                    $idempotencyKey,
                );

                return (string) $response->getKey();
            };
        };

        try {
            [$firstResponseId, $secondResponseId] = Concurrency::driver('process')->run(
                [
                    $makeTask('worker-a'),
                    $makeTask('worker-b'),
                ],
                30,
            );
        } finally {
            File::deleteDirectory($barrierDirectory);
        }

        $this->assertSame(
            $firstResponseId,
            $secondResponseId,
            'Concurrent retries must resolve to the same supplier response.',
        );

        $this->assertDatabaseCount('order_recipient_responses', 1);
        $this->assertDatabaseCount('order_recipient_item_responses', 1);

        $this->assertDatabaseHas('order_recipient_responses', [
            'id' => $firstResponseId,
            'order_recipient_id' => $recipientId,
            'idempotency_key' => $idempotencyKey,
        ]);

        $this->assertDatabaseHas('order_recipient_item_responses', [
            'order_recipient_response_id' => $firstResponseId,
            'order_recipient_item_id' => $recipientItem->id,
            'requested_quantity' => 2,
            'available_quantity' => 2,
            'availability_status' => 'full',
            'offered_unit_price' => '91.25',
        ]);
    }

    private function createSupplier(): Business
    {
        $this->seed(BusinessCapabilitySeeder::class);

        $supplier = Business::query()->create([
            'name' => 'Response concurrency supplier',
            'status' => 'active',
        ]);

        $supplier->capabilities()->attach('supplier', [
            'enabled_at' => now()->subMinute(),
            'disabled_at' => null,
        ]);

        return $supplier;
    }

    private function createProduct(Business $supplier): Product
    {
        $product = new Product;

        $product->id = self::PRODUCT_ID;
        $product->supplier_id = $supplier->id;
        $product->name = 'Response concurrency product';
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
