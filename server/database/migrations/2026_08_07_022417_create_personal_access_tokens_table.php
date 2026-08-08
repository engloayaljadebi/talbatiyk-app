<?php

/*
|--------------------------------------------------------------------------
| رموز الوصول الشخصية - Laravel Sanctum
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تخزين Bearer Tokens الخاصة بتطبيق Flutter.
| - ربط الرمز بالمستخدم باستخدام UUID.
| - تخزين الصلاحيات وتاريخ آخر استخدام والانتهاء.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء جدول رموز الوصول الخاصة بـ Sanctum.
     */
    public function up(): void
    {
        Schema::create('personal_access_tokens', function (Blueprint $table) {
            $table->id();

            /*
             * مهم:
             * المستخدمون عندنا UUID، لذلك لا نستخدم morphs العادي.
             */
            $table->uuidMorphs('tokenable');

            $table->text('name');
            $table->string('token', 64)->unique();

            // الصلاحيات الممنوحة لهذا الرمز.
            $table->text('abilities')->nullable();

            // آخر وقت استُخدم فيه الرمز.
            $table->timestampTz('last_used_at')->nullable();

            // تاريخ انتهاء الرمز عند تحديده.
            $table->timestampTz('expires_at')->nullable()->index();

            $table->timestampsTz();
        });
    }

    /**
     * حذف جدول رموز الوصول.
     */
    public function down(): void
    {
        Schema::dropIfExists('personal_access_tokens');
    }
};
