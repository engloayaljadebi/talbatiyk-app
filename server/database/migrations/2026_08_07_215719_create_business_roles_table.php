<?php

/*
|--------------------------------------------------------------------------
| أدوار العضوية داخل الأنشطة التجارية
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تعريف أدوار المستخدم داخل النشاط مرة واحدة فقط.
| - عدم تكرار owner / manager / staff لكل نشاط.
| - استخدام code كمفتاح طبيعي ثابت بدل إنشاء id غير ضروري.
|
| أسماء العرض والترجمة لا تخزن هنا؛
| Flutter / Laravel translations تعرض الاسم المناسب حسب اللغة.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء قاموس أدوار الأنشطة.
     */
    public function up(): void
    {
        Schema::create('business_roles', function (Blueprint $table) {
            /*
             * الكود هو هوية الدور نفسها.
             *
             * أمثلة:
             * owner
             * manager
             * staff
             */
            $table->string('code', 50)->primary();

            // يسمح بإيقاف دور مستقبلاً بدون حذف العلاقات التاريخية.
            $table->boolean('is_active')->default(true);
        });

        /*
         * يمنع أكواد غير منظمة.
         *
         * المسموح:
         * owner
         * sales_manager
         * warehouse_staff
         */
        DB::statement("
            ALTER TABLE business_roles
            ADD CONSTRAINT business_roles_code_format_check
            CHECK (code ~ '^[a-z][a-z0-9_]*$')
        ");
    }

    /**
     * حذف قاموس الأدوار.
     */
    public function down(): void
    {
        Schema::dropIfExists('business_roles');
    }
};
