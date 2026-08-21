<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // المستخدم الذي أنشأ الطلب.
            $table->uuid('user_id');

            /*
             * حالة الطلب:
             * pending
             * confirmed
             * preparing
             * ready_for_delivery
             * out_for_delivery
             * delivered
             * cancelled
             */
            $table->string('status', 30)->default('pending');

            // ملاحظات المستخدم على الطلب.
            $table->text('notes')->nullable();

            $table->timestampsTz();

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->restrictOnDelete();

            $table->index(
                ['user_id', 'created_at'],
                'orders_user_created_at_index'
            );

            $table->index('status');
        });

        DB::statement("
            ALTER TABLE orders
            ADD CONSTRAINT orders_status_check
            CHECK (
                status IN (
                    'pending',
                    'confirmed',
                    'preparing',
                    'ready_for_delivery',
                    'out_for_delivery',
                    'delivered',
                    'cancelled'
                )
            )
        ");

        Schema::create('order_items', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // الطلب الأب.
            $table->uuid('order_id');

            /*
             * معرف المنتج القادم من Flutter.
             *
             * لا نربطه بجدول products الآن لأن migrations الحالية
             * لا تحتوي جدول منتجات.
             */
            $table->string('product_id', 255);

            /*
             * Snapshot لاسم المنتج وقت الطلب.
             * لا نعتمد على الاسم الحالي للمنتج مستقبلاً.
             */
            $table->string('product_name', 255);

            /*
             * Snapshot للسعر وقت إنشاء الطلب.
             *
             * decimal مناسب للقيم المالية بدل floating point.
             */
            $table->decimal('unit_price', 18, 2);

            $table->unsignedInteger('quantity');

            /*
             * المورد هو Business لديه capability = supplier.
             */
            $table->uuid('supplier_id');

            /*
             * Snapshot لاسم المورد وقت إنشاء الطلب.
             *
             * وجوده مهم حتى يبقى تاريخ الطلب قابلًا للعرض
             * إذا تغير الاسم التجاري لاحقًا.
             */
            $table->string('supplier_name', 200);

            $table->text('image_url')->nullable();

            $table->timestampsTz();

            $table->foreign('order_id')
                ->references('id')
                ->on('orders')
                ->cascadeOnDelete();

            /*
             * نستخدم restrict بدل cascade:
             * حذف النشاط لا ينبغي أن يمحو تاريخ الطلب.
             *
             * businesses أصلًا يستخدم Soft Deletes.
             */
            $table->foreign('supplier_id')
                ->references('id')
                ->on('businesses')
                ->restrictOnDelete();

            $table->index(
                ['order_id', 'supplier_id'],
                'order_items_order_supplier_index'
            );

            $table->index(
                'supplier_id',
                'order_items_supplier_index'
            );
        });

        DB::statement('
            ALTER TABLE order_items
            ADD CONSTRAINT order_items_quantity_check
            CHECK (quantity > 0)
        ');

        DB::statement('
            ALTER TABLE order_items
            ADD CONSTRAINT order_items_unit_price_check
            CHECK (unit_price >= 0)
        ');
    }

    public function down(): void
    {
        Schema::dropIfExists('order_items');
        Schema::dropIfExists('orders');
    }
};
