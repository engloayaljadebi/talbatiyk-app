<?php

/*
|--------------------------------------------------------------------------
| وسائل اتصال النشاط التجاري
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تخزين وسائل التواصل الخاصة بالنشاط أو بأحد فروعه.
| - عدم وضع phone / email / whatsapp داخل businesses.
| - عدم إنشاء جدول مكرر لوسائل اتصال الفروع.
| - السماح بعدة وسائل اتصال من نفس النوع.
| - تحديد وسيلة رئيسية لكل نوع.
|
| قاعدة الملكية:
| - business_id         => وسيلة اتصال عامة للنشاط كله.
| - business_location_id => وسيلة خاصة بفرع أو موقع محدد.
|
| يجب أن يكون واحد منهما فقط موجودًا في كل سجل.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء جدول وسائل اتصال الأنشطة والفروع.
     */
    public function up(): void
    {
        Schema::create('business_contacts', function (Blueprint $table) {
            $table->uuid('id')->primary();

            /*
             * عند كون وسيلة الاتصال عامة للنشاط نستخدم business_id.
             */
            $table->uuid('business_id')->nullable();

            /*
             * عند كون وسيلة الاتصال خاصة بفرع معين نستخدم
             * business_location_id فقط.
             */
            $table->uuid('business_location_id')->nullable();

            /*
             * نوع وسيلة الاتصال.
             *
             * أمثلة:
             * phone
             * whatsapp
             * email
             * website
             */
            $table->string('type', 30);

            /*
             * نخزن القيمة الموحدة مرة واحدة.
             *
             * الهاتف:
             * +967777123456
             *
             * البريد:
             * sales@example.com
             */
            $table->string('value', 500);

            /*
             * وصف اختياري للوسيلة.
             *
             * أمثلة:
             * المبيعات
             * خدمة العملاء
             * الإدارة
             */
            $table->string('label', 100)->nullable();

            // الوسيلة الرئيسية من هذا النوع.
            $table->boolean('is_primary')->default(false);

            /*
             * يستخدم عند التحقق من ملكية الهاتف أو البريد.
             * null يعني أن الوسيلة غير موثقة.
             */
            $table->timestampTz('verified_at')->nullable();

            $table->timestampsTz();
            $table->softDeletesTz();

            $table->foreign('business_id')
                ->references('id')
                ->on('businesses')
                ->cascadeOnDelete();

            $table->foreign('business_location_id')
                ->references('id')
                ->on('business_locations')
                ->cascadeOnDelete();

            $table->index(
                ['business_id', 'type'],
                'business_contacts_business_type_index',
            );

            $table->index(
                ['business_location_id', 'type'],
                'business_contacts_location_type_index',
            );
        });

        /*
         * لا يسمح بأن تكون الوسيلة بدون مالك،
         * ولا يسمح بربطها بالنشاط والفرع معًا.
         *
         * واحد فقط من المفتاحين يجب أن يحتوي قيمة.
         */
        DB::statement('
            ALTER TABLE business_contacts
            ADD CONSTRAINT business_contacts_exactly_one_owner_check
            CHECK (
                (business_id IS NOT NULL AND business_location_id IS NULL)
                OR
                (business_id IS NULL AND business_location_id IS NOT NULL)
            )
        ');

        // أنواع الاتصال المعروفة حاليًا.
        DB::statement("
            ALTER TABLE business_contacts
            ADD CONSTRAINT business_contacts_type_check
            CHECK (
                type IN (
                    'phone',
                    'whatsapp',
                    'email',
                    'website'
                )
            )
        ");

        /*
         * منع تكرار نفس وسيلة الاتصال العامة لنفس النشاط.
         */
        /*
         * منع تكرار نفس وسيلة الاتصال العامة داخل النشاط.
         *
         * PostgreSQL يتطلب وضع تعبير CASE داخل أقواس إضافية
         * عندما يستخدم كتعبير داخل الفهرس.
         *
         * البريد فقط غير حساس لحالة الأحرف.
         * الهاتف وواتساب والموقع الإلكتروني يخزنان بصيغة موحدة
         * من طبقة التطبيق.
         */
        DB::statement("
           CREATE UNIQUE INDEX business_contacts_business_value_unique
           ON business_contacts (
               business_id,
               type,
               (
                   CASE
                       WHEN type = 'email'
                           THEN LOWER(value)
                       ELSE value
                   END
               )
           )
           WHERE business_id IS NOT NULL
             AND deleted_at IS NULL
       ");

        /*
         * منع تكرار نفس وسيلة الاتصال داخل نفس الفرع.
         */
        /*
         * نفس قاعدة منع التكرار، ولكن لوسائل الاتصال
         * المرتبطة بفرع أو موقع معين.
         */
        DB::statement("
           CREATE UNIQUE INDEX business_contacts_location_value_unique
           ON business_contacts (
               business_location_id,
               type,
               (
                   CASE
                       WHEN type = 'email'
                           THEN LOWER(value)
                       ELSE value
                   END
               )
           )
           WHERE business_location_id IS NOT NULL
             AND deleted_at IS NULL
       ");
        /*
         * النشاط يمتلك وسيلة رئيسية واحدة فقط من كل نوع.
         *
         * مثال:
         * هاتف رئيسي واحد، واتساب رئيسي واحد، وهكذا.
         */
        DB::statement('
            CREATE UNIQUE INDEX business_contacts_one_primary_per_business_type
            ON business_contacts (business_id, type)
            WHERE business_id IS NOT NULL
              AND is_primary = TRUE
              AND deleted_at IS NULL
        ');

        /*
         * كل فرع يمتلك وسيلة رئيسية واحدة فقط من كل نوع.
         */
        DB::statement('
            CREATE UNIQUE INDEX business_contacts_one_primary_per_location_type
            ON business_contacts (business_location_id, type)
            WHERE business_location_id IS NOT NULL
              AND is_primary = TRUE
              AND deleted_at IS NULL
        ');
    }

    /**
     * حذف جدول وسائل الاتصال.
     */
    public function down(): void
    {
        Schema::dropIfExists('business_contacts');
    }
};
