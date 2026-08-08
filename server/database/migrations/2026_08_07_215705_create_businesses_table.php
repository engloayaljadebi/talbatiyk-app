<?php

/*
|--------------------------------------------------------------------------
| جدول الأنشطة التجارية
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تخزين الهوية الأساسية للنشاط التجاري مرة واحدة فقط.
| - عدم تخزين الهاتف أو البريد هنا.
| - عدم تخزين العنوان أو الإحداثيات هنا.
| - عدم تخزين الدوام هنا.
| - عدم تحديد مورد/متجر هنا.
|
| الجداول الأخرى ترتبط بهذا الجدول حسب مسؤوليتها:
| - business_locations: الفروع والمواقع.
| - business_contacts: وسائل التواصل العامة.
| - business_capabilities: قدرات النشاط مثل مورد أو متجر.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء جدول الأنشطة التجارية.
     */
    public function up(): void
    {
        Schema::create('businesses', function (Blueprint $table) {
            // معرف عالمي ثابت للنشاط.
            $table->uuid('id')->primary();

            // الاسم التجاري الظاهر للمستخدمين.
            $table->string('name', 200);

            /*
             * الاسم القانوني الرسمي.
             * null عندما لا يوجد اسم قانوني مختلف عن الاسم التجاري.
             */
            $table->string('legal_name', 250)->nullable();

            // وصف عام للنشاط فقط.
            $table->text('description')->nullable();

            // حالة النشاط داخل المنصة.
            $table->string('status', 30)->default('active');

            $table->timestampsTz();

            // حذف منطقي لحماية الطلبات والسجلات التاريخية.
            $table->softDeletesTz();

            $table->index('name');
            $table->index('status');
        });

        // PostgreSQL يمنع إدخال حالة غير معروفة.
        DB::statement("
            ALTER TABLE businesses
            ADD CONSTRAINT businesses_status_check
            CHECK (status IN ('active', 'suspended', 'closed'))
        ");
    }

    /**
     * حذف جدول الأنشطة.
     */
    public function down(): void
    {
        Schema::dropIfExists('businesses');
    }
};
