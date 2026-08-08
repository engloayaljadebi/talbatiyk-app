<?php

/*
|--------------------------------------------------------------------------
| اختبارات نظام التوثيق
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - السماح بتوثيق المستخدم بنوع خاص بالمستخدم.
| - السماح بتوثيق النشاط بنوع خاص بالنشاط.
| - منع استخدام نوع توثيق المستخدم مع نشاط والعكس.
| - منع وجود طلبين حاليين من النوع نفسه لنفس الجهة.
| - السماح بطلب جديد بعد رفض الطلب السابق.
| - اختبار الحالات approved وrevoked وقواعد تواريخها.
|
*/

namespace Tests\Feature;

use App\Models\Business;
use App\Models\User;
use App\Models\Verification;
use App\Models\VerificationType;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class VerificationConstraintsTest extends TestCase
{
    use RefreshDatabase;

    /**
     * يمكن إنشاء توثيق خاص بالمستخدم.
     */
    public function test_user_can_have_user_verification(): void
    {
        $type = VerificationType::create([
            'code' => 'identity',
            'subject_kind' => 'user',
        ]);

        $user = User::factory()->create();

        $verification = $user->verifications()->create([
            'verification_type_code' => $type->code,
            'status' => 'pending',
        ]);

        $this->assertTrue($verification->user->is($user));
        $this->assertNull($verification->business_id);
        $this->assertSame('identity', $verification->type->code);
    }

    /**
     * يمكن إنشاء توثيق خاص بالنشاط التجاري.
     */
    public function test_business_can_have_business_verification(): void
    {
        $type = VerificationType::create([
            'code' => 'official_business',
            'subject_kind' => 'business',
        ]);

        $business = Business::create([
            'name' => 'نشاط موثق',
        ]);

        $verification = $business->verifications()->create([
            'verification_type_code' => $type->code,
            'status' => 'pending',
        ]);

        $this->assertTrue($verification->business->is($business));
        $this->assertNull($verification->user_id);
    }

    /**
     * لا يسمح باستخدام نوع توثيق المستخدم مع نشاط.
     */
    public function test_user_verification_type_cannot_be_used_for_business(): void
    {
        $type = VerificationType::create([
            'code' => 'identity',
            'subject_kind' => 'user',
        ]);

        $business = Business::create([
            'name' => 'نشاط اختبار',
        ]);

        $this->expectException(QueryException::class);

        Verification::create([
            'verification_type_code' => $type->code,
            'business_id' => $business->id,
            'status' => 'pending',
        ]);
    }

    /**
     * لا يسمح باستخدام نوع توثيق النشاط مع مستخدم.
     */
    public function test_business_verification_type_cannot_be_used_for_user(): void
    {
        $type = VerificationType::create([
            'code' => 'official_business',
            'subject_kind' => 'business',
        ]);

        $user = User::factory()->create();

        $this->expectException(QueryException::class);

        Verification::create([
            'verification_type_code' => $type->code,
            'user_id' => $user->id,
            'status' => 'pending',
        ]);
    }

    /**
     * لا يسمح بوجود طلبين حاليين من النوع نفسه
     * لنفس المستخدم.
     */
    public function test_user_cannot_have_duplicate_current_verification(): void
    {
        $type = VerificationType::create([
            'code' => 'identity',
            'subject_kind' => 'user',
        ]);

        $user = User::factory()->create();

        $user->verifications()->create([
            'verification_type_code' => $type->code,
            'status' => 'pending',
        ]);

        $this->expectException(QueryException::class);

        $user->verifications()->create([
            'verification_type_code' => $type->code,
            'status' => 'pending',
        ]);
    }

    /**
     * بعد رفض الطلب السابق يمكن تقديم طلب جديد.
     */
    public function test_new_verification_can_be_requested_after_rejection(): void
    {
        $type = VerificationType::create([
            'code' => 'identity',
            'subject_kind' => 'user',
        ]);

        $user = User::factory()->create();

        $user->verifications()->create([
            'verification_type_code' => $type->code,
            'status' => 'rejected',
            'reviewed_at' => now(),
        ]);

        $newVerification = $user->verifications()->create([
            'verification_type_code' => $type->code,
            'status' => 'pending',
        ]);

        $this->assertSame('pending', $newVerification->status);
        $this->assertSame(2, $user->verifications()->count());
    }

    /**
     * حالة approved يجب أن تحتوي reviewed_at.
     */
    public function test_approved_verification_requires_reviewed_at(): void
    {
        $type = VerificationType::create([
            'code' => 'identity',
            'subject_kind' => 'user',
        ]);

        $user = User::factory()->create();

        $this->expectException(QueryException::class);

        $user->verifications()->create([
            'verification_type_code' => $type->code,
            'status' => 'approved',
        ]);
    }

    /**
     * يمكن اعتماد التوثيق عند وجود وقت المراجعة.
     */
    public function test_verification_can_be_approved(): void
    {
        $type = VerificationType::create([
            'code' => 'identity',
            'subject_kind' => 'user',
        ]);

        $user = User::factory()->create();
        $reviewer = User::factory()->create();

        $verification = $user->verifications()->create([
            'verification_type_code' => $type->code,
            'status' => 'approved',
            'reviewed_at' => now(),
            'reviewed_by_user_id' => $reviewer->id,
        ]);

        $this->assertSame('approved', $verification->status);
        $this->assertTrue($verification->reviewedBy->is($reviewer));
    }

    /**
     * حالة revoked يجب أن تحتوي revoked_at.
     */
    public function test_revoked_verification_requires_revoked_at(): void
    {
        $type = VerificationType::create([
            'code' => 'identity',
            'subject_kind' => 'user',
        ]);

        $user = User::factory()->create();

        $this->expectException(QueryException::class);

        $user->verifications()->create([
            'verification_type_code' => $type->code,
            'status' => 'revoked',
            'reviewed_at' => now(),
        ]);
    }

    /**
     * يمكن تخزين توثيق ملغى مع تاريخ الإلغاء.
     */
    public function test_verification_can_be_revoked(): void
    {
        $type = VerificationType::create([
            'code' => 'identity',
            'subject_kind' => 'user',
        ]);

        $user = User::factory()->create();

        $verification = $user->verifications()->create([
            'verification_type_code' => $type->code,
            'status' => 'revoked',
            'reviewed_at' => now()->subDay(),
            'revoked_at' => now(),
        ]);

        $this->assertSame('revoked', $verification->status);
        $this->assertNotNull($verification->revoked_at);
    }
}
