<?php

namespace Tests\Feature\Api\V1\Order;

use App\Models\Business;
use App\Models\Product;
use App\Models\User;
use App\Services\Order\OrderService;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Support\Facades\Concurrency;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use RuntimeException;
use Tests\TestCase;

class OrderIdempotencyConcurrencyTest extends TestCase
{
    use DatabaseMigrations;

    private const IDEMPOTENCY_KEY = '550e8400-e29b-41d4-a716-446655440099';

    private const PRODUCT_ID = '00000000-0000-4000-8000-000000000199';

    public function test_concurrent_same_key_and_payload_returns_same_order_without_duplicate(): void
    {
        $this->assertSame(
            'pgsql',
            DB::connection()->getDriverName(),
            'This acceptance test must run against PostgreSQL.',
        );

        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Concurrency supplier',
        );

        $payload = $this->orderPayload($supplier);

        $userId = (string) $user->getKey();
        $idempotencyKey = self::IDEMPOTENCY_KEY;

        $barrierDirectory = storage_path(
            'framework/testing/order-idempotency-concurrency-' . uniqid('', true),
        );

        File::ensureDirectoryExists($barrierDirectory);

        $makeTask = static function (string $worker) use (
            $barrierDirectory,
            $userId,
            $payload,
            $idempotencyKey,
        ): \Closure {
            return static function () use (
                $worker,
                $barrierDirectory,
                $userId,
                $payload,
                $idempotencyKey,
            ): string {
                $user = User::query()->findOrFail($userId);

                file_put_contents(
                    $barrierDirectory . DIRECTORY_SEPARATOR . $worker . '.ready',
                    'ready',
                );

                $deadline = microtime(true) + 15;

                while (true) {
                    $readyWorkers = glob(
                        $barrierDirectory . DIRECTORY_SEPARATOR . '*.ready',
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

                $order = app(OrderService::class)->create(
                    $user,
                    $payload,
                    $idempotencyKey,
                );

                return (string) $order->getKey();
            };
        };

        try {
            [$firstOrderId, $secondOrderId] = Concurrency::driver('process')->run(
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
            $firstOrderId,
            $secondOrderId,
            'Concurrent retries must resolve to the same Order.',
        );

        $this->assertDatabaseCount('orders', 1);
        $this->assertDatabaseCount('order_items', 1);

        $this->assertDatabaseHas('orders', [
            'id' => $firstOrderId,
            'user_id' => $userId,
            'idempotency_key' => $idempotencyKey,
        ]);

        $this->assertDatabaseHas('order_items', [
            'order_id' => $firstOrderId,
            'product_id' => self::PRODUCT_ID,
            'supplier_id' => $supplier->id,
            'quantity' => 2,
        ]);
    }

    private function createSupplier(string $name): Business
    {
        $this->seed(BusinessCapabilitySeeder::class);

        $supplier = Business::query()->create([
            'name' => $name,
            'status' => 'active',
        ]);

        $supplier->capabilities()->attach('supplier', [
            'enabled_at' => now()->subMinute(),
            'disabled_at' => null,
        ]);

        return $supplier;
    }

    /**
     * @return array<string, mixed>
     */
    private function orderPayload(Business $supplier): array
    {
        $product = new Product();

        $product->id = self::PRODUCT_ID;
        $product->supplier_id = $supplier->id;
        $product->name = 'Concurrency product';
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

        return [
            'notes' => 'Concurrent idempotency order',
            'items' => [
                [
                    'product_id' => $product->id,
                    'quantity' => 2,
                    'expected_unit_price' => (float) $product->price,
                    'expected_supplier_id' => $supplier->id,
                ],
            ],
        ];
    }
}
