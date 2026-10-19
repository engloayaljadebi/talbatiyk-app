<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Reference data required for supplier onboarding.
        DB::table('verification_types')->insertOrIgnore([
            'code' => 'supplier_approval',
            'subject_kind' => 'business',
            'retired_at' => null,
        ]);

        $type = DB::table('verification_types')
            ->where('code', 'supplier_approval')
            ->first();

        if ($type === null ||
            $type->subject_kind !== 'business' ||
            $type->retired_at !== null) {
            throw new RuntimeException(
                'Supplier approval verification type is invalid.',
            );
        }
    }

    public function down(): void
    {
        // Preserve reference data and historical verification records.
    }
};
