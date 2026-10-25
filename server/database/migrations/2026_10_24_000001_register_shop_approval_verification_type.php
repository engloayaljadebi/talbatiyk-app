<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::table('verification_types')->insertOrIgnore([
            'code' => 'shop_approval',
            'subject_kind' => 'business',
            'retired_at' => null,
        ]);

        $type = DB::table('verification_types')
            ->where('code', 'shop_approval')
            ->first();

        if (
            $type === null ||
            $type->subject_kind !== 'business' ||
            $type->retired_at !== null
        ) {
            throw new RuntimeException(
                'Shop approval verification type is invalid.'
            );
        }
    }

    public function down(): void
    {
        // Preserve reference data and historical verification records.
    }
};
