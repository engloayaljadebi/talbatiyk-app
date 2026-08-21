<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table): void {
            $table->uuid('id')->primary();

            $table->foreignUuid('supplier_id')
                ->constrained('businesses')
                ->restrictOnDelete();

            $table->string('name', 200);
            $table->text('description')->nullable();

            $table->string('category', 150)->default('');
            $table->string('brand', 150)->default('');

            $table->decimal('price', 12, 2)->default(0);
            $table->unsignedInteger('quantity')->default(0);
            $table->boolean('is_available')->default(true);

            $table->text('image_url')->nullable();
            $table->jsonb('colors')->nullable();

            $table->decimal('discount', 5, 2)->default(0);
            $table->decimal('rating', 3, 2)->default(0);

            $table->timestampsTz();
            $table->softDeletesTz();

            $table->index(['supplier_id', 'created_at']);
            $table->index(['created_at', 'id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
