<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('business_categories', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 80)->unique();
            $table->string('name_ar', 150);
            $table->uuid('parent_id')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestampsTz();

            $table->index('parent_id');
        });

        Schema::table('business_categories', function (Blueprint $table) {
            $table->foreign('parent_id')
                ->references('id')
                ->on('business_categories')
                ->restrictOnDelete();
        });

        DB::statement("
            ALTER TABLE business_categories
            ADD CONSTRAINT business_categories_code_check
            CHECK (code ~ '^[a-z][a-z0-9_]*$')
        ");

        DB::statement('
            ALTER TABLE business_categories
            ADD CONSTRAINT business_categories_not_self_parent
            CHECK (parent_id IS NULL OR parent_id <> id)
        ');
    }

    public function down(): void
    {
        Schema::dropIfExists('business_categories');
    }
};
