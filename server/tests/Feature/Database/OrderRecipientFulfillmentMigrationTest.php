<?php

namespace Tests\Feature\Database;

use App\Models\Business;
use App\Models\User;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Tests\TestCase;

class OrderRecipientFulfillmentMigrationTest extends TestCase
{
    use DatabaseMigrations;

    public function test_migration_preserves_existing_recipient_and_adds_fulfillment_foundation(): void
    {
        Schema::dropIfExists(
            'order_recipient_fulfillment_histories',
        );

        Schema::table(
            'order_recipients',
            function (Blueprint $table): void {
                $table->dropColumn([
                    'fulfillment_status',
                    'fulfillment_version',
                ]);
            },
        );

        $buyer = User::factory()->create();
        $member = User::factory()->create();

        $supplier = Business::query()->create([
            'name' => 'Historical fulfillment supplier',
            'status' => 'active',
        ]);

        $orderId = (string) Str::uuid7();
        $recipientId = (string) Str::uuid7();

        DB::table('orders')->insert([
            'id' => $orderId,
            'user_id' => $buyer->id,
            'idempotency_key' => null,
            'idempotency_payload_hash' => null,
            'status' => 'pending',
            'notes' => 'Historical order before fulfillment',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('order_recipients')->insert([
            'id' => $recipientId,
            'order_id' => $orderId,
            'supplier_id' => $supplier->id,
            'supplier_name' => $supplier->name,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $migration = require database_path(
            'migrations/2026_08_30_000002_add_order_recipient_fulfillment.php',
        );

        $migration->up();

        $recipient = DB::table('order_recipients')
            ->where('id', $recipientId)
            ->first();

        $this->assertNotNull($recipient);
        $this->assertNull($recipient->fulfillment_status);
        $this->assertSame(
            1,
            (int) $recipient->fulfillment_version,
        );

        $this->assertTrue(
            Schema::hasTable(
                'order_recipient_fulfillment_histories',
            ),
        );

        DB::table(
            'order_recipient_fulfillment_histories',
        )->insert([
            'id' => (string) Str::uuid7(),
            'order_recipient_id' => $recipientId,
            'actor_user_id' => $member->id,
            'from_status' => 'confirmed',
            'to_status' => 'preparing',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->assertDatabaseHas(
            'order_recipient_fulfillment_histories',
            [
                'order_recipient_id' => $recipientId,
                'actor_user_id' => $member->id,
                'from_status' => 'confirmed',
                'to_status' => 'preparing',
            ],
        );
    }
}
