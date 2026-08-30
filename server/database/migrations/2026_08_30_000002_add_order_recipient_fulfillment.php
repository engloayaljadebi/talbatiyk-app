<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('order_recipients', function (Blueprint $table): void {
            $table->string('fulfillment_status', 30)->nullable();
            $table->unsignedBigInteger('fulfillment_version')->default(1);
        });

        DB::statement(<<<'SQL'
ALTER TABLE order_recipients
ADD CONSTRAINT order_recipients_fulfillment_status_check
CHECK (
    fulfillment_status IS NULL
    OR fulfillment_status IN (
        'preparing',
        'ready_for_delivery',
        'out_for_delivery',
        'delivered'
    )
)
SQL);

        DB::statement(<<<'SQL'
ALTER TABLE order_recipients
ADD CONSTRAINT order_recipients_fulfillment_version_check
CHECK (fulfillment_version > 0)
SQL);

        Schema::create(
            'order_recipient_fulfillment_histories',
            function (Blueprint $table): void {
                $table->uuid('id')->primary();
                $table->uuid('order_recipient_id');
                $table->uuid('actor_user_id');
                $table->string('from_status', 30);
                $table->string('to_status', 30);
                $table->timestampsTz();

                $table->foreign('order_recipient_id')
                    ->references('id')
                    ->on('order_recipients')
                    ->cascadeOnDelete();

                $table->foreign('actor_user_id')
                    ->references('id')
                    ->on('users')
                    ->restrictOnDelete();

                $table->index(
                    ['order_recipient_id', 'created_at'],
                    'order_recipient_fulfillment_history_recipient_created_index',
                );
            },
        );

        DB::statement(<<<'SQL'
ALTER TABLE order_recipient_fulfillment_histories
ADD CONSTRAINT order_recipient_fulfillment_histories_from_status_check
CHECK (
    from_status IN (
        'confirmed',
        'preparing',
        'ready_for_delivery',
        'out_for_delivery',
        'delivered'
    )
)
SQL);

        DB::statement(<<<'SQL'
ALTER TABLE order_recipient_fulfillment_histories
ADD CONSTRAINT order_recipient_fulfillment_histories_to_status_check
CHECK (
    to_status IN (
        'preparing',
        'ready_for_delivery',
        'out_for_delivery',
        'delivered'
    )
)
SQL);
    }

    public function down(): void
    {
        Schema::dropIfExists(
            'order_recipient_fulfillment_histories',
        );

        $columns = collect([
            'fulfillment_status',
            'fulfillment_version',
        ])->filter(
            fn (string $column): bool => Schema::hasColumn('order_recipients', $column),
        )->values()->all();

        if ($columns !== []) {
            Schema::table(
                'order_recipients',
                function (Blueprint $table) use ($columns): void {
                    $table->dropColumn($columns);
                },
            );
        }
    }
};
