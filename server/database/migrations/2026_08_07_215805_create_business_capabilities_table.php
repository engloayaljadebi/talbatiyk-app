<?php

/*
|--------------------------------------------------------------------------
| قدرات الأنشطة التجارية
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تعريف أنواع القدرات التجارية مرة واحدة فقط.
| - عدم تخزين supplier / shop داخل كل نشاط كنص مكرر.
| - استخدام code كمفتاح طبيعي ثابت.
| - السماح بإضافة قدرات جديدة مستقبلًا دون تعديل جدول businesses.
|
| أمثلة القدرات:
| - supplier
| - shop
|
| ملاحظة:
| أسماء العرض والترجمات لا تخزن هنا.
| واجهة Flutter تعرض الاسم المناسب حسب اللغة.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء قاموس قدرات الأنشطة.
     */
    public function up(): void
    {
        Schema::create('business_capabilities', function (Blueprint $table) {
            /*
             * الكود هو هوية القدرة نفسها.
             *
             * لذلك لا نضيف id رقميًا أو UUID إضافيًا بلا حاجة.
             */
            $table->string('code', 50)->primary();

            /*
             * عند إيقاف استخدام قدرة مستقبلًا لا نحذفها،
             * لأن سجلات تاريخية قد تعتمد عليها.
             *
             * null = القدرة متاحة.
             */
            $table->timestampTz('retired_at')->nullable();
        });

        /*
         * توحيد شكل الأكواد.
         *
         * أمثلة صحيحة:
         * supplier
         * shop
         * wholesale_supplier
         */
        DB::statement("
            ALTER TABLE business_capabilities
            ADD CONSTRAINT business_capabilities_code_format_check
            CHECK (code ~ '^[a-z][a-z0-9_]*$')
        ");
    }

    /**
     * حذف قاموس القدرات.
     */
    public function down(): void
    {
        Schema::dropIfExists('business_capabilities');
    }
};
