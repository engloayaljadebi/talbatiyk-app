<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('platform_role_assignments', function (Blueprint $table) {
            $table->uuid('user_id');
            $table->string('role_code', 50);
            $table->uuid('granted_by_user_id')->nullable();
            $table->timestampTz('granted_at')->useCurrent();
            $table->timestampTz('revoked_at')->nullable();

            $table->primary(
                ['user_id', 'role_code'],
                'platform_role_assignments_primary',
            );

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->restrictOnDelete();

            $table->foreign('granted_by_user_id')
                ->references('id')
                ->on('users')
                ->nullOnDelete();

            $table->index('role_code');
        });

        DB::statement("
            ALTER TABLE platform_role_assignments
            ADD CONSTRAINT platform_role_assignments_allowed_role_check
            CHECK (role_code = 'platform_admin')
        ");

        DB::statement('
            ALTER TABLE platform_role_assignments
            ADD CONSTRAINT platform_role_assignments_revoked_date_check
            CHECK (revoked_at IS NULL OR revoked_at >= granted_at)
        ');
    }

    public function down(): void
    {
        Schema::dropIfExists('platform_role_assignments');
    }
};
