<?php

/*
|--------------------------------------------------------------------------
| أنواع التوثيق
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تعريف أنواع التوثيق مرة واحدة فقط.
| - تحديد هل النوع يخص مستخدمًا أم نشاطًا.
| - عدم تخزين أسماء العرض والترجمات داخل قاعدة البيانات.
| - السماح بإيقاف نوع مستقبلاً دون حذف التاريخ.
|
| أمثلة مستقبلية:
| identity
| business_registration
| official_business
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء قاموس أنواع التوثيق.
     */
    public function up(): void
    {
        Schema::create('verification_types', function (Blueprint $table) {
            /*
             * الكود هو هوية النوع نفسه.
             * لذلك لا نحتاج id إضافيًا.
             */
            $table->string('code', 60)->primary();

            /*
             * الجهة التي يمكن تطبيق هذا النوع عليها.
             *
             * user     = حساب شخص.
             * business = نشاط تجاري.
             */
            $table->string('subject_kind', 20);

            /*
             * null = النوع متاح.
             * وجود تاريخ = توقف استخدام النوع للطلبات الجديدة.
             */
            $table->timestampTz('retired_at')->nullable();
        });

        DB::statement("
            ALTER TABLE verification_types
            ADD CONSTRAINT verification_types_subject_kind_check
            CHECK (subject_kind IN ('user', 'business'))
        ");

        DB::statement("
            ALTER TABLE verification_types
            ADD CONSTRAINT verification_types_code_format_check
            CHECK (code ~ '^[a-z][a-z0-9_]*$')
        ");
    }

    /**
     * حذف أنواع التوثيق.
     */
    public function down(): void
    {
        Schema::dropIfExists('verification_types');
    }
};
