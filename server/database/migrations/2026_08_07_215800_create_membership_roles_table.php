<?php

/*
|--------------------------------------------------------------------------
| أدوار عضويات الأنشطة
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - ربط العضوية بدور أو أكثر.
| - عدم تكرار معلومات المستخدم أو النشاط.
| - عدم إنشاء id غير ضروري للسجل الوسيط.
| - تسجيل من منح الدور ومتى تم منحه.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء العلاقة بين العضويات والأدوار.
     */
    public function up(): void
    {
        Schema::create('membership_roles', function (Blueprint $table) {
            // العضوية التي حصلت على الدور.
            $table->uuid('membership_id');

            // الكود يعود إلى business_roles.
            $table->string('role_code', 50);

            /*
             * العضوية التي منحت هذا الدور.
             *
             * null عند إنشاء مالك النشاط الأول بواسطة النظام.
             */
            $table->uuid('assigned_by_membership_id')->nullable();

            $table->timestampTz('assigned_at')->useCurrent();

            /*
             * العلاقة نفسها هي المفتاح.
             *
             * لا نحتاج id إضافيًا.
             */
            $table->primary(
                ['membership_id', 'role_code'],
                'membership_roles_primary',
            );

            $table->foreign('membership_id')
                ->references('id')
                ->on('business_memberships')
                ->cascadeOnDelete();

            $table->foreign('role_code')
                ->references('code')
                ->on('business_roles')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            $table->foreign('assigned_by_membership_id')
                ->references('id')
                ->on('business_memberships')
                ->nullOnDelete();

            $table->index('role_code');
        });
    }

    /**
     * حذف علاقات الأدوار.
     */
    public function down(): void
    {
        Schema::dropIfExists('membership_roles');
    }
};
