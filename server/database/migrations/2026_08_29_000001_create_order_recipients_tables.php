<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('order_recipients', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('order_id');
            $table->uuid('supplier_id');
            $table->string('supplier_name', 200);
            $table->timestampsTz();

            $table->foreign('order_id')
                ->references('id')
                ->on('orders')
                ->cascadeOnDelete();

            /*
             * Historical supplier references must survive Business soft deletion.
             * Physical deletion stays restricted while historical Orders reference it.
             */
            $table->foreign('supplier_id')
                ->references('id')
                ->on('businesses')
                ->restrictOnDelete();

            /*
             * A multi-supplier Order has one logical Recipient per supplier.
             * This also prevents duplicate recipient rows during creation/backfill.
             */
            $table->unique(
                ['order_id', 'supplier_id'],
                'order_recipients_order_supplier_unique',
            );

            $table->index(
                ['supplier_id', 'created_at'],
                'order_recipients_supplier_created_index',
            );
        });

        Schema::create('order_recipient_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('order_recipient_id');
            $table->uuid('order_item_id');
            $table->timestampsTz();

            $table->foreign('order_recipient_id')
                ->references('id')
                ->on('order_recipients')
                ->cascadeOnDelete();

            $table->foreign('order_item_id')
                ->references('id')
                ->on('order_items')
                ->cascadeOnDelete();

            /*
             * Each OrderItem belongs to exactly one supplier Recipient.
             * This is a database-level isolation invariant, not only a UI rule.
             */
            $table->unique(
                'order_item_id',
                'order_recipient_items_order_item_unique',
            );

            $table->index(
                'order_recipient_id',
                'order_recipient_items_recipient_index',
            );
        });

        /*
         * Existing Order history must remain usable after this forward migration.
         *
         * Orders are processed in bounded chunks so a large production history is
         * not loaded into memory at once. Recipient timestamps are derived from the
         * historical Order/OrderItem rows instead of the migration execution time.
         */
        DB::table('orders')
            ->select([
                'id',
                'created_at',
                'updated_at',
            ])
            ->chunkById(
                100,
                function (Collection $orders): void {
                    $ordersById = $orders->keyBy('id');

                    $items = DB::table('order_items')
                        ->select([
                            'id',
                            'order_id',
                            'supplier_id',
                            'supplier_name',
                            'created_at',
                            'updated_at',
                        ])
                        ->whereIn('order_id', $orders->pluck('id')->all())
                        ->orderBy('order_id')
                        ->orderBy('supplier_id')
                        ->orderBy('id')
                        ->get();

                    foreach ($items->groupBy(
                        fn ($item): string => $item->order_id.'|'.$item->supplier_id,
                    ) as $supplierItems) {
                        $firstItem = $supplierItems->first();
                        $order = $ordersById->get($firstItem->order_id);
                        $recipientId = (string) Str::uuid7();

                        DB::table('order_recipients')->insert([
                            'id' => $recipientId,
                            'order_id' => $firstItem->order_id,
                            'supplier_id' => $firstItem->supplier_id,
                            'supplier_name' => $firstItem->supplier_name,
                            'created_at' => $order->created_at,
                            'updated_at' => $order->updated_at,
                        ]);

                        DB::table('order_recipient_items')->insert(
                            $supplierItems
                                ->map(
                                    fn ($item): array => [
                                        'id' => (string) Str::uuid7(),
                                        'order_recipient_id' => $recipientId,
                                        'order_item_id' => $item->id,
                                        'created_at' => $item->created_at,
                                        'updated_at' => $item->updated_at,
                                    ],
                                )
                                ->all(),
                        );
                    }
                },
                'id',
            );
    }

    public function down(): void
    {
        Schema::dropIfExists('order_recipient_items');
        Schema::dropIfExists('order_recipients');
    }
};
