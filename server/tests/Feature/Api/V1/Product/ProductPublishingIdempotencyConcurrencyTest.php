<?php

namespace Tests\Feature\Api\V1\Product;

use App\Models\Business;
use App\Models\BusinessMembership;
use App\Models\User;
use App\Services\Product\ProductPublishingService;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Support\Facades\Concurrency;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use RuntimeException;
use Tests\TestCase;

class ProductPublishingIdempotencyConcurrencyTest extends TestCase
{
    use DatabaseMigrations;

    private const IDEMPOTENCY_KEY =
        '73000000-0000-4000-8000-000000000099';

    public function test_two_concurrent_retries_create_exactly_one_product(): void
    {
        $this->assertSame(
            'pgsql',
            DB::connection()->getDriverName(),
            'This acceptance test must run against PostgreSQL.',
        );

        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            $user,
        );

        $userId = (string) $user->getKey();
        $businessId = (string) $business->getKey();

        $payload = [
            'name' => 'Concurrent Product',
            'category' => 'Electronics',
            'brand' => 'Talbatiyk',
            'price' => 2500.00,
            'quantity' => 10,
            'description' => 'Concurrent product idempotency acceptance.',
            'is_available' => true,
        ];

        $barrierDirectory = storage_path(
            'framework/testing/product-idempotency-concurrency-'.
            uniqid('', true),
        );

        File::ensureDirectoryExists(
            $barrierDirectory,
        );

        $makeTask = static function (
            string $worker,
        ) use (
            $barrierDirectory,
            $userId,
            $businessId,
            $payload,
        ): \Closure {
            return static function () use (
                $worker,
                $barrierDirectory,
                $userId,
                $businessId,
                $payload,
            ): string {
                $user = User::query()->findOrFail(
                    $userId,
                );

                file_put_contents(
                    $barrierDirectory.
                    DIRECTORY_SEPARATOR.
                    $worker.
                    '.ready',
                    'ready',
                );

                $deadline =
                    microtime(true) + 15;

                while (true) {
                    $readyWorkers = glob(
                        $barrierDirectory.
                        DIRECTORY_SEPARATOR.
                        '*.ready',
                    ) ?: [];

                    if (
                        count($readyWorkers) >= 2
                    ) {
                        break;
                    }

                    if (
                        microtime(true)
                        >= $deadline
                    ) {
                        throw new RuntimeException(
                            'Timed out waiting for both workers.',
                        );
                    }

                    usleep(
                        10_000,
                    );
                }

                $product = app(
                    ProductPublishingService::class,
                )->publish(
                    $user,
                    $businessId,
                    $payload,
                    self::IDEMPOTENCY_KEY,
                );

                return (string) $product->getKey();
            };
        };

        try {
            [
                $firstProductId,
                $secondProductId,
            ] = Concurrency::driver(
                'process',
            )->run(
                [
                    $makeTask('worker-a'),
                    $makeTask('worker-b'),
                ],
                30,
            );
        } finally {
            File::deleteDirectory(
                $barrierDirectory,
            );
        }

        $this->assertSame(
            $firstProductId,
            $secondProductId,
        );

        $this->assertDatabaseCount(
            'products',
            1,
        );

        $this->assertDatabaseHas(
            'products',
            [
                'id' => $firstProductId,
                'supplier_id' => $businessId,
                'idempotency_key' => self::IDEMPOTENCY_KEY,
            ],
        );
    }

    private function supplierBusinessFor(
        User $user,
    ): Business {
        DB::table(
            'business_roles',
        )->updateOrInsert(
            [
                'code' => 'owner',
            ],
            [
                'is_active' => true,
            ],
        );

        DB::table(
            'business_capabilities',
        )->updateOrInsert(
            [
                'code' => 'supplier',
            ],
            [
                'retired_at' => null,
            ],
        );

        $business = Business::query()->create([
            'name' => 'Concurrent Product Supplier',
            'status' => 'active',
        ]);

        $membership =
            BusinessMembership::query()->create([
                'user_id' => $user->id,
                'business_id' => $business->id,
                'status' => 'active',
                'joined_at' => now(),
            ]);

        $membership->roles()->attach(
            'owner',
            [
                'assigned_at' => now(),
            ],
        );

        DB::table(
            'business_capability_assignments',
        )->insert([
            'business_id' => $business->id,
            'capability_code' => 'supplier',
            'enabled_by_membership_id' => $membership->id,
            'enabled_at' => now(),
            'disabled_at' => null,
        ]);

        return $business;
    }
}
