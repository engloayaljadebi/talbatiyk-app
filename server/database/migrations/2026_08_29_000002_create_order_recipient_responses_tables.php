<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('order_recipient_responses', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('order_recipient_id');
            $table->uuid('idempotency_key');
            $table->char('idempotency_payload_hash', 64);
            $table->timestampsTz();

            $table->foreign('order_recipient_id')
                ->references('id')
                ->on('order_recipients')
                ->cascadeOnDelete();

            /*
             * Gate 4.2 treats a supplier response as final. The unique Recipient
             * constraint is also the database race guard against duplicate submits.
             */
            $table->unique(
                'order_recipient_id',
                'order_recipient_responses_recipient_unique',
            );

            $table->index(
                'idempotency_key',
                'order_recipient_responses_idempotency_index',
            );
        });

        Schema::create('order_recipient_item_responses', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('order_recipient_response_id');
            $table->uuid('order_recipient_item_id');
            $table->unsignedInteger('requested_quantity');
            $table->unsignedInteger('available_quantity');
            $table->string('availability_status', 20);
            $table->decimal('offered_unit_price', 18, 2)->nullable();
            $table->text('response_notes')->nullable();
            $table->timestampsTz();

            $table->foreign('order_recipient_response_id')
                ->references('id')
                ->on('order_recipient_responses')
                ->cascadeOnDelete();

            $table->foreign('order_recipient_item_id')
                ->references('id')
                ->on('order_recipient_items')
                ->cascadeOnDelete();

            /*
             * One RecipientItem can be answered only once in the final response.
             */
            $table->unique(
                'order_recipient_item_id',
                'order_recipient_item_responses_item_unique',
            );

            $table->index(
                'order_recipient_response_id',
                'order_recipient_item_responses_response_index',
            );
        });

        DB::statement('
            ALTER TABLE order_recipient_item_responses
            ADD CONSTRAINT order_recipient_item_responses_requested_quantity_check
            CHECK (requested_quantity > 0)
        ');

        DB::statement('
            ALTER TABLE order_recipient_item_responses
            ADD CONSTRAINT order_recipient_item_responses_available_quantity_check
            CHECK (available_quantity <= requested_quantity)
        ');

        DB::statement('
            ALTER TABLE order_recipient_item_responses
            ADD CONSTRAINT order_recipient_item_responses_offered_price_check
            CHECK (offered_unit_price IS NULL OR offered_unit_price >= 0)
        ');

        /*
         * AvailabilityStatus is constrained at the database boundary as well as
         * through the PHP enum so invalid combinations cannot be persisted silently.
         */
        DB::statement(<<<'SQL'
    ALTER TABLE order_recipient_item_responses
    ADD CONSTRAINT order_recipient_item_responses_availability_check
    CHECK (
        (
            availability_status = 'full'
            AND available_quantity = requested_quantity
        )
        OR (
            availability_status = 'partial'
            AND available_quantity > 0
            AND available_quantity < requested_quantity
        )
        OR (
            availability_status = 'unavailable'
            AND available_quantity = 0
        )
    )
SQL);
    }

    public function down(): void
    {
        Schema::dropIfExists('order_recipient_item_responses');
        Schema::dropIfExists('order_recipient_responses');
    }
};
