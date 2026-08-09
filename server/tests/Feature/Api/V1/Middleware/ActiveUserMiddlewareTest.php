<?php

/*
|--------------------------------------------------------------------------
| اختبارات حماية الحساب النشط
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التأكد أن Token قديم لا يستمر بالعمل بعد إيقاف الحساب.
| - منع suspended و disabled من المسارات التي تتطلب حسابًا نشطًا.
| - حماية Business API بالحالة الحالية للمستخدم.
| - إبقاء logout متاحًا للحساب الموقوف حتى يستطيع إلغاء Token.
|
*/

namespace Tests\Feature\Api\V1\Middleware;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ActiveUserMiddlewareTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Token صدر أثناء نشاط الحساب،
     * ثم تم تعليق الحساب.
     *
     * يجب أن يصبح Token غير قادر على استخدام /me فورًا.
     */
    public function test_existing_token_cannot_use_protected_api_after_user_is_suspended(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $token = $user->createToken('test-device');

        /*
         * نحاكي قرار إداري حدث بعد إصدار Token.
         */
        $user->update([
            'status' => 'suspended',
        ]);

        $this
            ->withToken($token->plainTextToken)
            ->getJson('/api/v1/auth/me')
            ->assertForbidden()
            ->assertJson([
                'message' => 'هذا الحساب غير نشط.',
                'code' => 'ACCOUNT_INACTIVE',
            ]);
    }

    /**
     * الحساب المعطل disabled لا يستطيع استخدام /me
     * حتى لو كان يمتلك Token صالحًا سابقًا.
     */
    public function test_existing_token_cannot_use_protected_api_after_user_is_disabled(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $token = $user->createToken('test-device');

        $user->update([
            'status' => 'disabled',
        ]);

        $this
            ->withToken($token->plainTextToken)
            ->getJson('/api/v1/auth/me')
            ->assertForbidden()
            ->assertJsonPath(
                'code',
                'ACCOUNT_INACTIVE',
            );
    }

    /**
     * حماية النشاط التجاري يجب أن تستخدم
     * نفس قاعدة حالة المستخدم.
     */
    public function test_suspended_user_cannot_create_business_with_existing_token(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $token = $user->createToken('test-device');

        $user->update([
            'status' => 'suspended',
        ]);

        /*
         * لا نحتاج Payload صالحًا هنا.
         *
         * الـMiddleware يجب أن يوقف الطلب قبل
         * الوصول إلى CreateBusinessRequest.
         */
        $this
            ->withToken($token->plainTextToken)
            ->postJson('/api/v1/businesses', [])
            ->assertForbidden()
            ->assertJsonPath(
                'code',
                'ACCOUNT_INACTIVE',
            );

        $this->assertDatabaseCount('businesses', 0);
    }

    /**
     * logout يبقى متاحًا للحساب الموقوف.
     *
     * الهدف:
     * السماح بإلغاء Token الحالي بدل حبس المستخدم
     * داخل جلسة لا يستطيع إنهاءها.
     */
    public function test_suspended_user_can_logout_and_revoke_current_token(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $token = $user->createToken('test-device');

        $tokenId = $token->accessToken->id;

        $user->update([
            'status' => 'suspended',
        ]);

        $this
            ->withToken($token->plainTextToken)
            ->postJson('/api/v1/auth/logout')
            ->assertOk()
            ->assertJson([
                'message' => 'تم تسجيل الخروج بنجاح.',
            ]);

        /*
         * يجب حذف Token الذي استخدمه هذا الجهاز فقط.
         */
        $this->assertDatabaseMissing(
            'personal_access_tokens',
            [
                'id' => $tokenId,
            ],
        );
    }
}
