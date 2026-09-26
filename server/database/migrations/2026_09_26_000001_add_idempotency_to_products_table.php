<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table): void {
            /*
             * Historical rows remain valid.
             * New Product Publishing requests require these through API.
             */
            $table->uuid('idempotency_key')->nullable();

            $table
                ->char(
                    'idempotency_payload_hash',
                    64,
                )
                ->nullable();

            /*
             * Database-enforced invariant:
             *
             * one logical Product publication per supplier/key.
             */
            $table->unique(
                [
                    'supplier_id',
                    'idempotency_key',
                ],
                'products_supplier_idempotency_unique',
            );
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table): void {
            $table->dropUnique(
                'products_supplier_idempotency_unique',
            );

            $table->dropColumn([
                'idempotency_key',
                'idempotency_payload_hash',
            ]);
        });
    }
};
