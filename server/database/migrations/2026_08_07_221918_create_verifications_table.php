<?php

/*
|--------------------------------------------------------------------------
| عمليات التوثيق
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تخزين توثيق المستخدمين والأنشطة في جدول واحد.
| - الاحتفاظ بتاريخ الطلب والمراجعة والإلغاء والانتهاء.
| - عدم تخزين is_verified في users أو businesses.
| - دعم سجل تاريخي كامل لعمليات التوثيق.
|
| ملكية السجل:
| - user_id موجود      => توثيق مستخدم.
| - business_id موجود  => توثيق نشاط.
|
| يجب أن يكون واحد منهما فقط موجودًا.
|
*/

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * إنشاء سجل عمليات التوثيق.
     */
    public function up(): void
    {
        Schema::create('verifications', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // نوع التوثيق من القاموس المركزي.
            $table->string('verification_type_code', 60);

            // يستخدم عند توثيق حساب شخص.
            $table->uuid('user_id')->nullable();

            // يستخدم عند توثيق نشاط تجاري.
            $table->uuid('business_id')->nullable();

            /*
             * المستخدم الذي بدأ طلب التوثيق.
             *
             * null عندما ينشئ النظام العملية تلقائيًا.
             */
            $table->uuid('requested_by_user_id')->nullable();

            /*
             * المستخدم الإداري الذي راجع الطلب.
             *
             * null قبل المراجعة أو عند إجراء آلي.
             */
            $table->uuid('reviewed_by_user_id')->nullable();

            /*
             * دورة حياة التوثيق:
             *
             * pending
             * approved
             * rejected
             * revoked
             * expired
             */
            $table->string('status', 20)->default('pending');

            // وقت تقديم طلب التوثيق.
            $table->timestampTz('requested_at')->useCurrent();

            // وقت اتخاذ قرار المراجعة.
            $table->timestampTz('reviewed_at')->nullable();

            // انتهاء صلاحية التوثيق عند وجود مدة محددة.
            $table->timestampTz('expires_at')->nullable();

            // وقت إلغاء توثيق سبق اعتماده.
            $table->timestampTz('revoked_at')->nullable();

            // ملاحظة داخلية للمراجعة.
            $table->text('review_note')->nullable();

            $table->timestampsTz();

            $table->foreign('verification_type_code')
                ->references('code')
                ->on('verification_types')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->cascadeOnDelete();

            $table->foreign('business_id')
                ->references('id')
                ->on('businesses')
                ->cascadeOnDelete();

            $table->foreign('requested_by_user_id')
                ->references('id')
                ->on('users')
                ->nullOnDelete();

            $table->foreign('reviewed_by_user_id')
                ->references('id')
                ->on('users')
                ->nullOnDelete();

            $table->index('status');
            $table->index('verification_type_code');
        });

        /*
         * السجل يجب أن يخص مستخدمًا أو نشاطًا،
         * وليس الاثنين معًا وليس بدون مالك.
         */
        DB::statement('
            ALTER TABLE verifications
            ADD CONSTRAINT verifications_exactly_one_subject_check
            CHECK (
                (user_id IS NOT NULL AND business_id IS NULL)
                OR
                (user_id IS NULL AND business_id IS NOT NULL)
            )
        ');

        DB::statement("
            ALTER TABLE verifications
            ADD CONSTRAINT verifications_status_check
            CHECK (
                status IN (
                    'pending',
                    'approved',
                    'rejected',
                    'revoked',
                    'expired'
                )
            )
        ");

        /*
         * الطلب المعلق لم تتم مراجعته بعد.
         */
        DB::statement("
            ALTER TABLE verifications
            ADD CONSTRAINT verifications_review_state_check
            CHECK (
                (status = 'pending'
                    AND reviewed_at IS NULL
                    AND revoked_at IS NULL)
                OR
                (status <> 'pending'
                    AND reviewed_at IS NOT NULL)
            )
        ");

        /*
         * revoked_at لا يظهر إلا عندما تكون الحالة revoked.
         */
        DB::statement("
            ALTER TABLE verifications
            ADD CONSTRAINT verifications_revoked_at_check
            CHECK (
                (status = 'revoked' AND revoked_at IS NOT NULL)
                OR
                (status <> 'revoked' AND revoked_at IS NULL)
            )
        ");

        /*
         * تاريخ الانتهاء لا يمكن أن يسبق المراجعة.
         */
        DB::statement('
            ALTER TABLE verifications
            ADD CONSTRAINT verifications_expiry_check
            CHECK (
                expires_at IS NULL
                OR reviewed_at IS NULL
                OR expires_at >= reviewed_at
            )
        ');

        /*
         * للمستخدم لا نسمح بوجود عمليتي توثيق حاليتين
         * من نفس النوع.
         *
         * التاريخ القديم rejected/revoked/expired يبقى محفوظًا.
         */
        DB::statement("
            CREATE UNIQUE INDEX verifications_user_current_unique
            ON verifications (user_id, verification_type_code)
            WHERE user_id IS NOT NULL
              AND status IN ('pending', 'approved')
        ");

        /*
         * نفس القاعدة للنشاط التجاري.
         */
        DB::statement("
            CREATE UNIQUE INDEX verifications_business_current_unique
            ON verifications (business_id, verification_type_code)
            WHERE business_id IS NOT NULL
              AND status IN ('pending', 'approved')
        ");

        /*
         * PostgreSQL يتأكد أن نوع التوثيق يطابق مالك السجل.
         *
         * مثال:
         * نوع خاص بالمستخدم لا يمكن ربطه بنشاط.
         */
        DB::unprepared(<<<'SQL'
    CREATE OR REPLACE FUNCTION validate_verification_subject_kind()
    RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        expected_kind varchar;
    BEGIN
        SELECT subject_kind
        INTO expected_kind
        FROM verification_types
        WHERE code = NEW.verification_type_code;

        IF expected_kind IS NULL THEN
            RAISE EXCEPTION 'Verification type does not exist';
        END IF;

        IF expected_kind = 'user'
           AND NEW.user_id IS NULL
        THEN
            RAISE EXCEPTION
                'This verification type requires a user subject';
        END IF;

        IF expected_kind = 'business'
           AND NEW.business_id IS NULL
        THEN
            RAISE EXCEPTION
                'This verification type requires a business subject';
        END IF;

        RETURN NEW;
    END;
    $$;

    CREATE TRIGGER verifications_validate_subject_kind
    BEFORE INSERT OR UPDATE
    ON verifications
    FOR EACH ROW
    EXECUTE FUNCTION validate_verification_subject_kind();
    SQL);
    }

    /**
     * حذف نظام عمليات التوثيق.
     */
    public function down(): void
    {
        DB::unprepared('
            DROP TRIGGER IF EXISTS
                verifications_validate_subject_kind
            ON verifications;
        ');

        Schema::dropIfExists('verifications');

        DB::unprepared(
            'DROP FUNCTION IF EXISTS validate_verification_subject_kind();'
        );
    }
};
