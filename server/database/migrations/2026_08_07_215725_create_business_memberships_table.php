<?php

/*
|--------------------------------------------------------------------------
| عضويات المستخدمين في الأنشطة
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - ربط المستخدم بالنشاط دون نسخ بيانات أي منهما.
| - المستخدم يمكنه الانضمام لعدة أنشطة.
| - النشاط يمكن أن يحتوي عدة مستخدمين.
| - لكل User + Business سجل عضوية واحد فقط طوال عمر النظام.
|
| الدور لا يخزن هنا؛ مكانه membership_roles.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء عضويات الأنشطة.
     */
    public function up(): void
    {
        Schema::create('business_memberships', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // المستخدم العضو.
            $table->uuid('user_id');

            // النشاط الذي ينتمي إليه.
            $table->uuid('business_id');

            // حالة العضوية نفسها، وليس حالة المستخدم أو النشاط.
            $table->string('status', 30)->default('active');

            // بداية أول عضوية فعلية.
            $table->timestampTz('joined_at')->useCurrent();

            // يمتلئ عند مغادرة العضو للنشاط.
            $table->timestampTz('left_at')->nullable();

            $table->timestampsTz();

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->cascadeOnDelete();

            $table->foreign('business_id')
                ->references('id')
                ->on('businesses')
                ->cascadeOnDelete();

            /*
             * لا نكرر علاقة نفس المستخدم بنفس النشاط.
             *
             * عند خروجه نغير status، ولا ننشئ سجلًا ثانيًا.
             */
            $table->unique(
                ['user_id', 'business_id'],
                'business_memberships_user_business_unique',
            );

            $table->index(
                ['business_id', 'status'],
                'business_memberships_business_status_index',
            );

            $table->index(
                ['user_id', 'status'],
                'business_memberships_user_status_index',
            );
        });

        DB::statement("
            ALTER TABLE business_memberships
            ADD CONSTRAINT business_memberships_status_check
            CHECK (status IN ('active', 'suspended', 'left'))
        ");

        /*
         * left_at لا يكون موجودًا إلا عند مغادرة العضو.
         */
        DB::statement("
            ALTER TABLE business_memberships
            ADD CONSTRAINT business_memberships_left_at_check
            CHECK (
                (status = 'left' AND left_at IS NOT NULL)
                OR
                (status <> 'left' AND left_at IS NULL)
            )
        ");
    }

    /**
     * حذف عضويات الأنشطة.
     */
    public function down(): void
    {
        Schema::dropIfExists('business_memberships');
    }
};
