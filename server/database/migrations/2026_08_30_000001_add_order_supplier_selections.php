<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table): void {
            $table->unsignedBigInteger('version')->default(1);
        });

        DB::statement('
            ALTER TABLE orders
            ADD CONSTRAINT orders_version_check
            CHECK (version > 0)
        ');

        Schema::create('order_item_selections', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('order_item_id');
            $table->uuid('order_recipient_item_response_id');
            $table->unsignedInteger('selected_quantity');
            $table->timestampsTz();

            $table->foreign('order_item_id')
                ->references('id')
                ->on('order_items')
                ->cascadeOnDelete();

            $table->foreign('order_recipient_item_response_id')
                ->references('id')
                ->on('order_recipient_item_responses')
                ->cascadeOnDelete();

            $table->unique(
                'order_item_id',
                'order_item_selections_order_item_unique',
            );

            $table->unique(
                'order_recipient_item_response_id',
                'order_item_selections_response_item_unique',
            );
        });

        DB::statement('
            ALTER TABLE order_item_selections
            ADD CONSTRAINT order_item_selections_quantity_check
            CHECK (selected_quantity > 0)
        ');
    }

    public function down(): void
    {
        Schema::dropIfExists('order_item_selections');

        Schema::table('orders', function (Blueprint $table): void {
            $table->dropColumn('version');
        });
    }
};