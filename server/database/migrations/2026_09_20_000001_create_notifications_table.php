<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->string('type');

            // Talbatiyk User primary keys are UUIDs.
            $table->uuidMorphs('notifiable');

            $table->json('data');
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
        });

        /*
         * Hot path:
         * user notification timeline ordered newest first.
         */
        DB::statement(
            <<<'SQL'
            CREATE INDEX notifications_notifiable_created_at_index
            ON notifications (
                notifiable_type,
                notifiable_id,
                created_at DESC
            )
            SQL
        );

        /*
         * Hot path:
         * unread count / unread notification queries.
         *
         * PostgreSQL partial index stores only unread rows.
         */
        DB::statement(
            <<<'SQL'
            CREATE INDEX notifications_unread_notifiable_index
            ON notifications (
                notifiable_type,
                notifiable_id
            )
            WHERE read_at IS NULL
            SQL
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
