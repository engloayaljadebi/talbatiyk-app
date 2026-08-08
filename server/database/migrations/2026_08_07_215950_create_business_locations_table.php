<?php

/*
|--------------------------------------------------------------------------
| مواقع وفروع النشاط التجاري
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل كل فرع أو متجر أو مكتب أو مخزن كموقع مستقل.
| - تخزين عنوان الموقع وإحداثياته.
| - السماح للنشاط بامتلاك عدد غير محدود من المواقع.
| - تحديد الموقع الرئيسي بدون تكرار بيانات النشاط.
|
| الدوام سيرتبط بهذا الجدول وليس businesses.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء مواقع الأنشطة التجارية.
     */
    public function up(): void
    {
        Schema::create('business_locations', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // النشاط الذي يتبع له الموقع.
            $table->uuid('business_id');

            /*
             * اسم الموقع داخل النشاط.
             *
             * أمثلة:
             * الفرع الرئيسي
             * فرع التحرير
             * مخزن حدة
             */
            $table->string('name', 160);

            // نوع الموقع.
            $table->string('type', 30)->default('branch');
            /*
             * المنطقة الزمنية تخص الموقع نفسه، وليس كل فترة دوام.
             *
             * مثال اليمن:
             * Asia/Aden
             */
            $table->string('timezone', 64);
            /*
             * أجزاء العنوان منفصلة حتى يمكن البحث والفرز عليها.
             */
            $table->char('country_code', 2);
            $table->string('administrative_area', 160)->nullable();
            $table->string('locality', 160)->nullable();
            $table->string('district', 160)->nullable();
            $table->string('street_address', 300)->nullable();

            /*
             * وصف إضافي للوصول إلى الموقع.
             * مثال: بجوار المستشفى، الدور الثاني.
             */
            $table->string('address_notes', 500)->nullable();

            /*
             * إحداثيات الموقع.
             * decimal يمنع مشاكل دقة floating point.
             */
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();

            // هل هذا هو الموقع الرئيسي للنشاط؟
            $table->boolean('is_primary')->default(false);

            // حالة هذا الموقع تحديدًا.
            $table->string('status', 30)->default('active');

            $table->timestampsTz();
            $table->softDeletesTz();

            $table->foreign('business_id')
                ->references('id')
                ->on('businesses')
                ->cascadeOnDelete();

            $table->index(
                ['business_id', 'status'],
                'business_locations_business_status_index',
            );
        });

        DB::statement("
            ALTER TABLE business_locations
            ADD CONSTRAINT business_locations_type_check
            CHECK (type IN ('branch', 'office', 'warehouse', 'store'))
        ");

        DB::statement("
            ALTER TABLE business_locations
            ADD CONSTRAINT business_locations_status_check
            CHECK (status IN ('active', 'temporarily_closed', 'closed'))
        ");

        /*
         * لا يسمح للنشاط بأكثر من موقع رئيسي فعال.
         */
        DB::statement('
            CREATE UNIQUE INDEX business_locations_one_primary
            ON business_locations (business_id)
            WHERE is_primary = TRUE
              AND deleted_at IS NULL
        ');

        /*
         * التحقق من صحة الإحداثيات من مستوى PostgreSQL.
         */
        DB::statement('
            ALTER TABLE business_locations
            ADD CONSTRAINT business_locations_latitude_check
            CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90)
        ');

        DB::statement('
            ALTER TABLE business_locations
            ADD CONSTRAINT business_locations_longitude_check
            CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
        ');
    }

    /**
     * حذف مواقع النشاط.
     */
    public function down(): void
    {
        Schema::dropIfExists('business_locations');
    }
};
