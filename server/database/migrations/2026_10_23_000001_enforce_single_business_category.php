<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $duplicate = DB::table('business_category_assignments')
            ->select('business_id')
            ->groupBy('business_id')
            ->havingRaw('COUNT(*) > 1')
            ->first();

        if ($duplicate !== null) {
            throw new RuntimeException(
                'Cannot enforce one category per business: existing multiple assignments must be reviewed first.'
            );
        }

        Schema::table('business_category_assignments', function (Blueprint $table) {
            $table->unique(
                'business_id',
                'business_category_assignments_one_category_unique'
            );
        });
    }

    public function down(): void
    {
        Schema::table('business_category_assignments', function (Blueprint $table) {
            $table->dropUnique(
                'business_category_assignments_one_category_unique'
            );
        });
    }
};
