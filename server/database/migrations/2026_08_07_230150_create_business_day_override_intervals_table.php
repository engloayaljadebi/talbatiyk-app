<?php

/*
|--------------------------------------------------------------------------
| فترات الدوام في الأيام الاستثنائية
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تخزين فترات العمل الخاصة بيوم استثنائي.
| - عدم تكرار التاريخ أو سبب الاستثناء؛ فهما موجودان في
|   business_day_overrides.
| - السماح بأكثر من فترة في اليوم نفسه.
| - دعم الدوام الممتد بعد منتصف الليل.
| - منع إضافة فترات إلى يوم حالته closed.
|
| مثال:
|
| business_day_overrides
| 2026-09-01 | custom_hours | دوام العيد
|
| business_day_override_intervals
| 08:00 → 12:00
| 16:00 → 21:00
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء فترات الدوام الاستثنائية.
     */
    public function up(): void
    {
        Schema::create(
            'business_day_override_intervals',
            function (Blueprint $table) {
                // المعرّف الأساسي للفترة.
                $table->uuid('id')->primary();

                // اليوم الاستثنائي الذي تتبع له هذه الفترة.
                $table->uuid('business_day_override_id');

                // بداية الفترة بالتوقيت المحلي للموقع.
                $table->time('opens_at');

                // نهاية الفترة بالتوقيت المحلي للموقع.
                $table->time('closes_at');

                /*
                 * 0 = الإغلاق في نفس اليوم.
                 * 1 = الإغلاق في اليوم التالي.
                 *
                 * مثال:
                 * 20:00 → 02:00
                 * end_day_offset = 1
                 */
                $table
                    ->unsignedTinyInteger('end_day_offset')
                    ->default(0);

                // created_at و updated_at مع دعم المنطقة الزمنية.
                $table->timestampsTz();

                /*
                 * ربط الفترة باليوم الاستثنائي.
                 *
                 * عند حذف اليوم الاستثنائي،
                 * يتم حذف جميع فتراته تلقائيًا.
                 */
                $table
                    ->foreign('business_day_override_id')
                    ->references('id')
                    ->on('business_day_overrides')
                    ->cascadeOnDelete();

                /*
                 * يمنع إدخال نفس الفترة حرفيًا مرتين
                 * لنفس اليوم الاستثنائي.
                 */
                $table->unique(
                    [
                        'business_day_override_id',
                        'opens_at',
                        'closes_at',
                        'end_day_offset',
                    ],
                    'business_day_override_intervals_exact_unique',
                );

                /*
                 * فهرس لتسريع جلب جميع الفترات
                 * الخاصة بيوم استثنائي معين.
                 */
                $table->index(
                    'business_day_override_id',
                    'business_day_override_intervals_override_index',
                );
            },
        );

        /*
         * الفترة لا يمكن أن تتجاوز اليوم التالي.
         *
         * القيم المسموحة:
         * 0 = نفس اليوم.
         * 1 = اليوم التالي.
         */
        DB::statement(<<<'SQL'
ALTER TABLE business_day_override_intervals
ADD CONSTRAINT business_day_override_intervals_offset_check
CHECK (end_day_offset IN (0, 1))
SQL);

        /*
         * التحقق من منطق البداية والنهاية.
         *
         * إذا كانت الفترة تنتهي في نفس اليوم:
         * closes_at يجب أن تكون أكبر من opens_at.
         *
         * وإذا كانت تنتهي في اليوم التالي:
         * closes_at يجب أن تكون أقل من أو تساوي opens_at.
         *
         * مثال صحيح:
         * 08:00 → 12:00 / offset = 0
         *
         * مثال صحيح لدوام ليلي:
         * 20:00 → 02:00 / offset = 1
         */
        DB::statement(<<<'SQL'
ALTER TABLE business_day_override_intervals
ADD CONSTRAINT business_day_override_intervals_time_check
CHECK (
    (end_day_offset = 0 AND closes_at > opens_at)
    OR
    (end_day_offset = 1 AND closes_at <= opens_at)
)
SQL);

        /*
         * حماية من مستوى PostgreSQL.
         *
         * لا يمكن إنشاء أو تعديل فترة دوام إلا إذا كان
         * اليوم الاستثنائي المرتبط بها من نوع:
         *
         * custom_hours
         */
        DB::unprepared(<<<'SQL'
CREATE OR REPLACE FUNCTION validate_business_day_override_interval()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    override_mode varchar;
BEGIN
    SELECT mode
    INTO override_mode
    FROM business_day_overrides
    WHERE id = NEW.business_day_override_id;

    IF override_mode IS NULL THEN
        RAISE EXCEPTION
            'Business day override does not exist';
    END IF;

    IF override_mode <> 'custom_hours' THEN
        RAISE EXCEPTION
            'Intervals are only allowed for custom_hours overrides';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER business_day_override_intervals_validate_parent
BEFORE INSERT OR UPDATE
ON business_day_override_intervals
FOR EACH ROW
EXECUTE FUNCTION validate_business_day_override_interval();
SQL);

        /*
         * يمنع تحويل اليوم الاستثنائي إلى closed
         * بينما ما تزال توجد له فترات دوام.
         *
         * الترتيب الصحيح:
         *
         * 1. حذف الفترات المرتبطة باليوم.
         * 2. تغيير mode إلى closed.
         */
        DB::unprepared(<<<'SQL'
CREATE OR REPLACE FUNCTION prevent_closed_override_with_intervals()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.mode = 'closed'
       AND EXISTS (
           SELECT 1
           FROM business_day_override_intervals
           WHERE business_day_override_id = NEW.id
       )
    THEN
        RAISE EXCEPTION
            'Closed override cannot contain working intervals';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER business_day_overrides_prevent_closed_with_intervals
BEFORE UPDATE OF mode
ON business_day_overrides
FOR EACH ROW
EXECUTE FUNCTION prevent_closed_override_with_intervals();
SQL);
    }

    /**
     * حذف فترات الدوام وقواعد التحقق المرتبطة بها.
     */
    public function down(): void
    {
        /*
         * حذف Trigger الموجود على جدول
         * business_day_overrides أولًا.
         */
        DB::unprepared(<<<'SQL'
DROP TRIGGER IF EXISTS
    business_day_overrides_prevent_closed_with_intervals
ON business_day_overrides;
SQL);

        /*
         * حذف Trigger الخاص بجدول الفترات.
         */
        DB::unprepared(<<<'SQL'
DROP TRIGGER IF EXISTS
    business_day_override_intervals_validate_parent
ON business_day_override_intervals;
SQL);

        /*
         * حذف جدول الفترات.
         */
        Schema::dropIfExists(
            'business_day_override_intervals',
        );

        /*
         * حذف دالة منع تحويل اليوم إلى closed
         * مع وجود فترات.
         */
        DB::unprepared(
            'DROP FUNCTION IF EXISTS prevent_closed_override_with_intervals();',
        );

        /*
         * حذف دالة التحقق من نوع اليوم الاستثنائي.
         */
        DB::unprepared(
            'DROP FUNCTION IF EXISTS validate_business_day_override_interval();',
        );
    }
};
