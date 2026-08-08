<?php

/*
|--------------------------------------------------------------------------
| قدرات كل نشاط تجاري
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - ربط النشاط بقدرة أو أكثر.
| - النشاط يمكن أن يكون موردًا ومتجرًا معًا.
| - عدم تكرار معلومات النشاط.
| - عدم تكرار تعريف القدرة.
| - تسجيل تاريخ تفعيل وتعطيل القدرة.
|
| مثال:
|
| business_id = ABC
| capability_code = supplier
|
| business_id = ABC
| capability_code = shop
|
| نفس النشاط أصبح موردًا ومتجرًا دون إنشاء نشاطين.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء علاقات الأنشطة بقدراتها.
     */
    public function up(): void
    {
        Schema::create('business_capability_assignments', function (Blueprint $table) {
            // النشاط الذي يمتلك القدرة.
            $table->uuid('business_id');

            // القدرة المعرفة مرة واحدة في business_capabilities.
            $table->string('capability_code', 50);

            /*
             * العضوية التي فعّلت القدرة.
             *
             * null يسمح للنظام بإنشاء القدرة عند إنشاء النشاط لأول مرة.
             */
            $table->uuid('enabled_by_membership_id')->nullable();

            // وقت بدء تفعيل القدرة.
            $table->timestampTz('enabled_at')->useCurrent();

            /*
             * null = القدرة تعمل حاليًا.
             * وجود قيمة = القدرة موقوفة.
             *
             * لا نحتاج is_active إضافيًا.
             */
            $table->timestampTz('disabled_at')->nullable();

            /*
             * النشاط + القدرة هما هوية العلاقة.
             *
             * لذلك لا نحتاج id إضافيًا.
             */
            $table->primary(
                ['business_id', 'capability_code'],
                'business_capability_assignments_primary',
            );

            $table->foreign('business_id')
                ->references('id')
                ->on('businesses')
                ->cascadeOnDelete();

            $table->foreign('capability_code')
                ->references('code')
                ->on('business_capabilities')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            $table->foreign('enabled_by_membership_id')
                ->references('id')
                ->on('business_memberships')
                ->nullOnDelete();

            $table->index('capability_code');
        });

        /*
         * لا يسمح بأن يكون تاريخ التعطيل قبل تاريخ التفعيل.
         */
        DB::statement('
            ALTER TABLE business_capability_assignments
            ADD CONSTRAINT business_capability_assignments_dates_check
            CHECK (
                disabled_at IS NULL
                OR disabled_at >= enabled_at
            )
        ');
    }

    /**
     * حذف علاقات القدرات.
     */
    public function down(): void
    {
        Schema::dropIfExists('business_capability_assignments');
    }
};
