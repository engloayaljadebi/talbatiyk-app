<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('order_recipient_items', function (Blueprint $table): void {
            $table->dropUnique('order_recipient_items_order_item_unique');

            $table->unique(
                ['order_recipient_id', 'order_item_id'],
                'order_recipient_items_recipient_item_unique',
            );
        });
    }

    public function down(): void
    {
        $duplicateOrderItem = DB::table('order_recipient_items')
            ->select('order_item_id')
            ->groupBy('order_item_id')
            ->havingRaw('COUNT(*) > 1')
            ->first();

        if ($duplicateOrderItem !== null) {
            throw new RuntimeException(
                'Cannot restore the legacy one-recipient-per-order-item '
                .'constraint because broadcast recipient data exists.',
            );
        }

        Schema::table('order_recipient_items', function (Blueprint $table): void {
            $table->dropUnique(
                'order_recipient_items_recipient_item_unique',
            );

            $table->unique(
                'order_item_id',
                'order_recipient_items_order_item_unique',
            );
        });
    }
};
