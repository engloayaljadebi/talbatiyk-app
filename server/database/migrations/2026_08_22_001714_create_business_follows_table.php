<?php

/*
|--------------------------------------------------------------------------
| متابعات الموردين - Business Follows
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - ربط المستخدم بالمورد الذي يتابعه.
| - منع تكرار متابعة نفس المستخدم لنفس المورد.
| - حذف العلاقة عند الحذف الحقيقي للمستخدم أو النشاط.
|
| ملاحظات معمارية:
| - business_id يشير إلى هوية المورد الأصلية Business.
| - لا نخزن product_id لأن المتابعة تخص المورد وليس المنتج.
| - لا نخزن status أو soft delete:
|   وجود الصف = Follow، وحذف الصف = Unfollow.
| - صلاحية النشاط كمورد فعّال تتحقق في Application Service
|   لأنها تعتمد على business status وsupplier capability الحالية.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء علاقات متابعة الموردين.
     */
    public function up(): void
    {
        Schema::create('business_follows', function (Blueprint $table): void {
            $table->foreignUuid('user_id')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->foreignUuid('business_id')
                ->constrained('businesses')
                ->cascadeOnDelete();

            $table->timestampsTz();

            /*
             * User + Business هما هوية علاقة المتابعة.
             *
             * استخدام Primary Key مركب يمنع التكرار بدون id إضافي
             * ويحافظ على Follow كعلاقة بسيطة.
             */
            $table->primary(
                ['user_id', 'business_id'],
                'business_follows_primary',
            );

            /*
             * الـPrimary Key يخدم الاستعلامات التي تبدأ بـ user_id.
             * هذا الفهرس الإضافي يخدم استعلامات متابعي Business.
             */
            $table->index(
                'business_id',
                'business_follows_business_index',
            );
        });
    }

    /**
     * حذف علاقات متابعة الموردين.
     */
    public function down(): void
    {
        Schema::dropIfExists('business_follows');
    }
};
