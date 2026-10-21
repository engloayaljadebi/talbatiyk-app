<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('business_category_assignments', function (Blueprint $table) {
            $table->uuid('business_id');
            $table->uuid('category_id');
            $table->timestampTz('created_at')->useCurrent();

            $table->primary(
                ['business_id', 'category_id'],
                'business_category_assignments_primary'
            );

            $table->foreign('business_id')
                ->references('id')
                ->on('businesses')
                ->restrictOnDelete();

            $table->foreign('category_id')
                ->references('id')
                ->on('business_categories')
                ->restrictOnDelete();

            $table->index('category_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('business_category_assignments');
    }
};
