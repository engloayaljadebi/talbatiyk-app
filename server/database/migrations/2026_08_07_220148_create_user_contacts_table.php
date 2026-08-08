<?php

/*
|--------------------------------------------------------------------------
| وسائل اتصال المستخدم
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تخزين الهاتف والبريد بعيدًا عن users.
| - السماح للمستخدم بأكثر من هاتف أو بريد.
| - تحديد وسيلة رئيسية لكل نوع.
| - تخزين حالة التحقق في مكان واحد فقط.
| - منع استخدام نفس الهاتف أو البريد في حسابين.
|
| قاعدة مهمة:
| القيمة تخزن موحدة من البداية:
|
| Phone:
| +967777123456
|
| Email:
| user@example.com
|
| لذلك لا نحتاج normalized_value منفصلًا.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء وسائل اتصال المستخدمين.
     */
    public function up(): void
    {
        Schema::create('user_contacts', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // صاحب وسيلة الاتصال.
            $table->uuid('user_id');

            // phone أو email.
            $table->string('type', 20);

            /*
             * القيمة الموحدة فقط.
             *
             * الهاتف يخزن E.164.
             * البريد يخزن lowercase.
             */
            $table->string('value', 320);

            // هل هي الوسيلة الرئيسية من نفس النوع؟
            $table->boolean('is_primary')->default(false);

            // null يعني أنها لم تتحقق بعد.
            $table->timestampTz('verified_at')->nullable();

            $table->timestampsTz();

            // يسمح بإلغاء ربط وسيلة الاتصال بدون فقد التاريخ.
            $table->softDeletesTz();

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->cascadeOnDelete();

            $table->index(
                ['user_id', 'type'],
                'user_contacts_user_type_index',
            );
        });

        // لا نقبل نوع اتصال غير معروف.
        DB::statement("
            ALTER TABLE user_contacts
            ADD CONSTRAINT user_contacts_type_check
            CHECK (type IN ('phone', 'email'))
        ");

        /*
         * يمنع وجود نفس الهاتف أو البريد في حسابين نشطين.
         *
         * نستخدم LOWER للبريد، ولا نحتاج تخزين نسخة ثانية.
         */
        /*
         * يمنع تكرار نفس الهاتف أو البريد في حسابين نشطين.
         *
         * البريد غير حساس لحالة الأحرف،
         * بينما الهاتف يخزن مسبقًا بالصيغة الموحدة E.164.
         */
        DB::statement("
           CREATE UNIQUE INDEX user_contacts_type_value_unique
           ON user_contacts (
               type,
               (
                   CASE
                       WHEN type = 'email'
                           THEN LOWER(value)
                       ELSE value
                   END
               )
           )
           WHERE deleted_at IS NULL
       ");

        /*
         * المستخدم يمكن أن يمتلك عدة أرقام،
         * لكن هاتف رئيسي واحد فقط.
         *
         * وكذلك بريد رئيسي واحد فقط.
         */
        DB::statement('
            CREATE UNIQUE INDEX user_contacts_one_primary_per_type
            ON user_contacts (user_id, type)
            WHERE is_primary = TRUE
              AND deleted_at IS NULL
        ');
    }

    /**
     * حذف جدول وسائل الاتصال.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_contacts');
    }
};
