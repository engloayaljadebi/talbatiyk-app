<?php

/*
|--------------------------------------------------------------------------
| الدوام الأسبوعي للمواقع
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تخزين الدوام المتكرر أسبوعيًا لكل موقع/فرع.
| - السماح بأكثر من فترة في اليوم نفسه.
| - دعم الدوام الممتد بعد منتصف الليل.
| - عدم تكرار المنطقة الزمنية؛ تؤخذ من business_locations.
|
| day_of_week يستخدم معيار ISO:
| 1 = Monday
| 2 = Tuesday
| ...
| 7 = Sunday
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء جدول فترات الدوام الأسبوعية.
     */
    public function up(): void
    {
        Schema::create('business_hours', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // الموقع أو الفرع الذي يطبق عليه هذا الدوام.
            $table->uuid('business_location_id');

            // رقم اليوم وفق ISO من 1 إلى 7.
            $table->unsignedTinyInteger('day_of_week');

            // بداية فترة العمل بالتوقيت المحلي للموقع.
            $table->time('opens_at');

            // نهاية فترة العمل بالتوقيت المحلي للموقع.
            $table->time('closes_at');

            /*
             * 0 = الإغلاق في نفس اليوم.
             * 1 = الإغلاق في اليوم التالي.
             *
             * مثال:
             * 20:00 → 02:00
             * end_day_offset = 1
             */
            $table->unsignedTinyInteger('end_day_offset')->default(0);

            $table->timestampsTz();

            $table->foreign('business_location_id')
                ->references('id')
                ->on('business_locations')
                ->cascadeOnDelete();

            /*
             * يمنع إدخال نفس الفترة حرفيًا مرتين.
             */
            $table->unique(
                [
                    'business_location_id',
                    'day_of_week',
                    'opens_at',
                    'closes_at',
                    'end_day_offset',
                ],
                'business_hours_exact_interval_unique',
            );

            $table->index(
                ['business_location_id', 'day_of_week'],
                'business_hours_location_day_index',
            );
        });

        // اليوم يجب أن يكون من 1 إلى 7.
        DB::statement('
            ALTER TABLE business_hours
            ADD CONSTRAINT business_hours_day_check
            CHECK (day_of_week BETWEEN 1 AND 7)
        ');

        // فترة الدوام لا يمكن أن تمتد لأكثر من اليوم التالي.
        DB::statement('
            ALTER TABLE business_hours
            ADD CONSTRAINT business_hours_end_day_offset_check
            CHECK (end_day_offset IN (0, 1))
        ');

        /*
         * إذا كانت النهاية في نفس اليوم يجب أن تكون بعد البداية.
         *
         * وإذا كانت النهاية في اليوم التالي يجب أن تكون
         * مساوية للبداية أو قبلها زمنيًا.
         *
         * مثال صحيح:
         * 20:00 → 02:00 +1 day
         */
        DB::statement('
            ALTER TABLE business_hours
            ADD CONSTRAINT business_hours_interval_check
            CHECK (
                (end_day_offset = 0 AND closes_at > opens_at)
                OR
                (end_day_offset = 1 AND closes_at <= opens_at)
            )
        ');
    }

    /**
     * حذف جدول الدوام الأسبوعي.
     */
    public function down(): void
    {
        Schema::dropIfExists('business_hours');
    }
};
