<?php

namespace Tests\Feature\Database;

use App\Models\Business;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Tests\TestCase;

class OrderRecipientMigrationTest extends TestCase
{
    use DatabaseMigrations;

    public function test_migration_backfills_existing_order_history(): void
    {
        /*
         * Recreate the pre-Gate-4.1 schema inside the isolated testing database,
         * seed historical rows directly, then run only the new forward migration.
         *
         * Query Builder is intentional here: Eloquent timestamps would make this
         * fixture test model behavior instead of migration preservation semantics.
         */
        /*
         * Later response tables reference the Gate 4.1 tables. Drop them first so
         * this test can still recreate the pre-Gate-4.1 schema in isolation.
         */
        Schema::dropIfExists('order_recipient_item_responses');
        Schema::dropIfExists('order_recipient_responses');
        Schema::dropIfExists('order_recipient_items');
        Schema::dropIfExists('order_recipients');

        $buyer = User::factory()->create();

        $supplier = Business::query()->create([
            'name' => 'Historical migration supplier',
            'status' => 'active',
        ]);

        $orderId = (string) Str::uuid7();
        $orderItemId = (string) Str::uuid7();

        $orderCreatedAt = Carbon::parse('2026-08-20 10:00:00+00:00');
        $itemCreatedAt = Carbon::parse('2026-08-20 10:00:01+00:00');

        DB::table('orders')->insert([
            'id' => $orderId,
            'user_id' => $buyer->id,
            'idempotency_key' => null,
            'idempotency_payload_hash' => null,
            'status' => 'pending',
            'notes' => 'Historical order before recipients',
            'created_at' => $orderCreatedAt,
            'updated_at' => $orderCreatedAt,
        ]);

        DB::table('order_items')->insert([
            'id' => $orderItemId,
            'order_id' => $orderId,
            'product_id' => 'historical-product',
            'product_name' => 'Historical product',
            'unit_price' => '12.50',
            'quantity' => 3,
            'supplier_id' => $supplier->id,
            'supplier_name' => $supplier->name,
            'image_url' => null,
            'created_at' => $itemCreatedAt,
            'updated_at' => $itemCreatedAt,
        ]);

        $migration = require database_path(
            'migrations/2026_08_29_000001_create_order_recipients_tables.php',
        );

        $migration->up();

        $recipient = DB::table('order_recipients')
            ->where('order_id', $orderId)
            ->where('supplier_id', $supplier->id)
            ->first();
        $this->assertNotNull($recipient);

        $storedOrderCreatedAt = DB::table('orders')
            ->where('id', $orderId)
            ->value('created_at');

        /*
 * نقارن بتاريخ Order المخزن فعليًا في PostgreSQL.
 * الهدف هو إثبات أن Migration حافظت على التاريخ ولم تستبدله بوقت التنفيذ.
 */
        $this->assertSame(
            Carbon::parse($storedOrderCreatedAt)->toISOString(),
            Carbon::parse($recipient->created_at)->toISOString(),
        );
        $recipientItem = DB::table('order_recipient_items')
            ->where('order_recipient_id', $recipient->id)
            ->where('order_item_id', $orderItemId)
            ->first();
        $this->assertNotNull($recipientItem);

        $storedItemCreatedAt = DB::table('order_items')
            ->where('id', $orderItemId)
            ->value('created_at');

        /*
 * RecipientItem يجب أن يحتفظ بنفس timestamp المخزن للـOrderItem التاريخي.
 */
        $this->assertSame(
            Carbon::parse($storedItemCreatedAt)->toISOString(),
            Carbon::parse($recipientItem->created_at)->toISOString(),
        );

        $this->assertDatabaseCount('orders', 1);
        $this->assertDatabaseCount('order_items', 1);
        $this->assertDatabaseCount('order_recipients', 1);
        $this->assertDatabaseCount('order_recipient_items', 1);
    }
}
