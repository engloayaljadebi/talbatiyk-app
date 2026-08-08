<?php

/*
|--------------------------------------------------------------------------
| جدول المستخدمين
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تخزين هوية تسجيل الدخول الأساسية للمستخدم.
| - تخزين اسم المستخدم بدون نسخة مكررة للتطبيع.
| - عدم تخزين الهاتف أو البريد هنا.
| - استخدام UUID ليتوافق مستقبلًا مع Flutter وOffline Sync.
| - تخزين حالة الحساب وآخر تسجيل دخول.
|
| لا يحتوي هذا الجدول على:
| - معلومات النشاط التجاري.
| - أرقام الهواتف.
| - البريد الإلكتروني.
| - العناوين.
| - علامة التوثيق.
| - نوع النشاط مورد/متجر.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء جداول هوية المستخدم.
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            // معرف عالمي ثابت مناسب للمزامنة بين الأنظمة.
            $table->uuid('id')->primary();

            /*
             * اسم المستخدم الخاص بالحساب.
             *
             * عدم استخدام unique() هنا متعمد؛
             * سننشئ فهرس PostgreSQL يمنع اختلاف حالة الأحرف أيضًا.
             */
            $table->string('username', 50);

            // الاسم الظاهر للشخص، وليس اسم النشاط التجاري.
            $table->string('display_name', 160);

            // كلمة المرور المشفرة فقط.
            $table->string('password');

            // الحالة التشغيلية للحساب.
            $table->string('status', 30)->default('active');

            // آخر دخول ناجح للحساب.
            $table->timestampTz('last_login_at')->nullable();

            // دعم جلسات Remember Me عند الحاجة.
            $table->rememberToken();

            $table->timestampsTz();

            // حذف منطقي للحفاظ على التاريخ والعلاقات.
            $table->softDeletesTz();

            $table->index('status');
        });

        /*
         * username غير حساس لحالة الأحرف.
         *
         * مثال:
         * aljadebi
         * ALJADEBI
         * AlJaDeBi
         *
         * كلها تعتبر اسمًا واحدًا.
         *
         * لا نحتاج username_normalized وبالتالي لا نكرر المعلومة.
         */
        DB::statement('
            CREATE UNIQUE INDEX users_username_case_insensitive_unique
            ON users (LOWER(username))
        ');

        // قاعدة البيانات نفسها تمنع الحالات غير المعروفة.
        DB::statement("
            ALTER TABLE users
            ADD CONSTRAINT users_status_check
            CHECK (status IN ('active', 'suspended', 'disabled'))
        ");

        /*
         * رموز استعادة كلمة المرور مرتبطة بالمستخدم مباشرة.
         *
         * لا نخزن البريد هنا مرة أخرى؛ لأن البريد موجود في user_contacts.
         */

        // جلسات Laravel عند استخدام Session authentication.
        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();

            $table->uuid('user_id')->nullable()->index();

            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->nullOnDelete();
        });
    }

    /**
     * حذف الجداول بعكس ترتيب العلاقات.
     */
    public function down(): void
    {
        Schema::dropIfExists('sessions');
        Schema::dropIfExists('users');
    }
};
