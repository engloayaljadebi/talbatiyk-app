<?php

/*
|--------------------------------------------------------------------------
| الاستثناءات اليومية للدوام
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تحديد يوم معين يختلف عن الجدول الأسبوعي.
| - تخزين التاريخ والسبب مرة واحدة فقط.
| - دعم الإغلاق الكامل أو دوام مخصص.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء استثناءات الأيام.
     */
    public function up(): void
    {
        Schema::create('business_day_overrides', function (Blueprint $table) {
            $table->uuid('id')->primary();

            $table->uuid('business_location_id');

            // اليوم الاستثنائي بالتوقيت المحلي للموقع.
            $table->date('date');

            /*
             * closed = الموقع مغلق طوال اليوم.
             * custom_hours = تجاهل الجدول الأسبوعي واستخدم فترات مخصصة.
             */
            $table->string('mode', 30);

            // سبب اختياري مثل عيد أو جرد أو ظرف طارئ.
            $table->string('reason', 300)->nullable();

            $table->timestampsTz();

            $table->foreign('business_location_id')
                ->references('id')
                ->on('business_locations')
                ->cascadeOnDelete();

            // للموقع استثناء واحد فقط في نفس التاريخ.
            $table->unique(
                ['business_location_id', 'date'],
                'business_day_overrides_location_date_unique',
            );
        });

        DB::statement("
            ALTER TABLE business_day_overrides
            ADD CONSTRAINT business_day_overrides_mode_check
            CHECK (mode IN ('closed', 'custom_hours'))
        ");
    }

    /**
     * حذف الاستثناءات.
     */
    public function down(): void
    {
        Schema::dropIfExists('business_day_overrides');
    }
};
