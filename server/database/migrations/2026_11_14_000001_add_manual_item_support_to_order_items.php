<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('order_items', function (Blueprint $table): void {
            /*
             * catalog: item linked to a real product and its source supplier.
             * manual: item typed by the customer, never part of the catalog.
             *
             * Every existing row is a catalog item.
             */
            $table->string('item_type', 20)->default('catalog');

            $table->string('unit', 50)->nullable();
            $table->text('note')->nullable();
        });

        DB::statement('
            ALTER TABLE order_items
            ALTER COLUMN product_id DROP NOT NULL
        ');

        DB::statement('
            ALTER TABLE order_items
            ALTER COLUMN supplier_id DROP NOT NULL
        ');

        DB::statement('
            ALTER TABLE order_items
            ALTER COLUMN supplier_name DROP NOT NULL
        ');

        DB::statement("
            ALTER TABLE order_items
            ADD CONSTRAINT order_items_item_type_check
            CHECK (item_type IN ('catalog', 'manual'))
        ");

        /*
         * A manual item must never carry a product or a source supplier,
         * and a catalog item must always carry both.
         */
        DB::statement("
            ALTER TABLE order_items
            ADD CONSTRAINT order_items_item_shape_check
            CHECK (
                (
                    item_type = 'catalog'
                    AND product_id IS NOT NULL
                    AND supplier_id IS NOT NULL
                    AND supplier_name IS NOT NULL
                )
                OR
                (
                    item_type = 'manual'
                    AND product_id IS NULL
                    AND supplier_id IS NULL
                    AND supplier_name IS NULL
                )
            )
        ");
    }

    public function down(): void
    {
        $hasManualItems = DB::table('order_items')
            ->where('item_type', 'manual')
            ->exists();

        if ($hasManualItems) {
            throw new RuntimeException(
                'Cannot restore NOT NULL product and supplier columns '
                .'because manual order items exist.',
            );
        }

        DB::statement('
            ALTER TABLE order_items
            DROP CONSTRAINT order_items_item_shape_check
        ');

        DB::statement('
            ALTER TABLE order_items
            DROP CONSTRAINT order_items_item_type_check
        ');

        DB::statement('
            ALTER TABLE order_items
            ALTER COLUMN supplier_name SET NOT NULL
        ');

        DB::statement('
            ALTER TABLE order_items
            ALTER COLUMN supplier_id SET NOT NULL
        ');

        DB::statement('
            ALTER TABLE order_items
            ALTER COLUMN product_id SET NOT NULL
        ');

        Schema::table('order_items', function (Blueprint $table): void {
            $table->dropColumn([
                'item_type',
                'unit',
                'note',
            ]);
        });
    }
};
