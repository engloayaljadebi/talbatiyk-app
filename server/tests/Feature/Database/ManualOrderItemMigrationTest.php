<?php

namespace Tests\Feature\Database;

use App\Models\Business;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Tests\TestCase;

class ManualOrderItemMigrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_manual_item_migration_preserves_existing_catalog_order(): void
    {
        $migration = require database_path(
            'migrations/2026_11_14_000001_add_manual_item_support_to_order_items.php',
        );

        $migration->down();
        $this->assertFalse(Schema::hasColumn('order_items', 'item_type'));

        $buyer = User::factory()->create();
        $supplier = Business::query()->create([
            'name' => 'Historical supplier',
            'status' => 'active',
        ]);

        $order = [
            'id' => (string) Str::uuid7(),
            'user_id' => $buyer->id,
            'status' => 'pending',
            'notes' => 'Order saved before the manual item upgrade',
        ];
        DB::table('orders')->insert($order);

        $catalogItem = [
            'id' => (string) Str::uuid7(),
            'order_id' => $order['id'],
            'product_id' => (string) Str::uuid7(),
            'product_name' => 'Historical catalog product',
            'supplier_id' => $supplier->id,
            'supplier_name' => $supplier->name,
            'unit_price' => '12.50',
            'quantity' => 3,
        ];
        DB::table('order_items')->insert($catalogItem);

        $migration->up();

        $this->assertDatabaseHas('orders', $order);
        $this->assertDatabaseHas('order_items', $catalogItem + [
            'item_type' => 'catalog',
            'unit' => null,
            'note' => null,
        ]);

        $manualItem = [
            'id' => (string) Str::uuid7(),
            'order_id' => $order['id'],
            'item_type' => 'manual',
            'product_id' => null,
            'product_name' => 'Manual item after the upgrade',
            'supplier_id' => null,
            'supplier_name' => null,
            'unit_price' => '7.25',
            'quantity' => 2,
            'unit' => 'piece',
            'note' => 'Added after migration',
        ];
        DB::table('order_items')->insert($manualItem);

        $this->assertDatabaseHas('order_items', $manualItem);
        $this->assertDatabaseCount('order_items', 2);
    }
}
