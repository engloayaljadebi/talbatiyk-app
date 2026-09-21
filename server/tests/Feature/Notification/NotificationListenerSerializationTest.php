<?php

namespace Tests\Feature\Notification;

use App\Events\Order\SupplierOrderFulfillmentUpdated;
use App\Events\Order\SupplierOrderResponseSubmitted;
use App\Listeners\Order\SendOrderFulfillmentStatusChangedNotification;
use App\Listeners\Order\SendOrderResponseReceivedNotification;
use App\Models\User;
use Illuminate\Database\Events\QueryExecuted;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Notifications\DatabaseNotification;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

final class NotificationListenerSerializationTest extends TestCase
{
    use RefreshDatabase;

    public function test_lifecycle_notification_critical_sections_are_transactional_and_customer_locked(): void
    {
        $customer = User::factory()->create();

        $transactionLevels = [];

        DatabaseNotification::creating(
            static function () use (
                &$transactionLevels,
            ): void {
                $transactionLevels[] =
                    DB::transactionLevel();
            },
        );

        $queries = [];

        DB::listen(
            static function (
                QueryExecuted $query,
            ) use (&$queries): void {
                $queries[] =
                    strtolower($query->sql);
            },
        );

        app(
            SendOrderResponseReceivedNotification::class,
        )->handle(
            new SupplierOrderResponseSubmitted(
                customerUserId: (string) $customer->id,
                orderId: (string) Str::uuid(),
                orderRecipientId: (string) Str::uuid(),
                responseId: (string) Str::uuid(),
                supplierId: (string) Str::uuid(),
                supplierName: 'Concurrent supplier',
            ),
        );

        app(
            SendOrderFulfillmentStatusChangedNotification::class,
        )->handle(
            new SupplierOrderFulfillmentUpdated(
                customerUserId: (string) $customer->id,
                orderId: (string) Str::uuid(),
                orderRecipientId: (string) Str::uuid(),
                supplierId: (string) Str::uuid(),
                supplierName: 'Concurrent supplier',
                fulfillmentStatus: 'preparing',
                fulfillmentVersion: 2,
            ),
        );

        $this->assertCount(
            2,
            $transactionLevels,
        );

        foreach ($transactionLevels as $level) {
            $this->assertGreaterThan(
                0,
                $level,
                'Notification insert must occur inside a transaction.',
            );
        }

        $userLockQueries = collect($queries)
            ->filter(
                static fn (string $sql): bool => str_contains(
                    $sql,
                    'from "users"',
                )
                    && str_contains(
                        $sql,
                        'for update',
                    ),
            );

        $this->assertGreaterThanOrEqual(
            2,
            $userLockQueries->count(),
            'Both lifecycle listeners must serialize the customer '
            .'check-and-insert critical section with a row lock.',
        );
    }
}
