<?php

/*
|--------------------------------------------------------------------------
| اختبارات Auth API
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - اختبار إنشاء حساب جديد.
| - منع تكرار username بدون اعتبار حالة الأحرف.
| - منع تكرار البريد الإلكتروني.
| - تسجيل الدخول بواسطة username.
| - تسجيل الدخول بواسطة email.
| - تسجيل الدخول بواسطة phone.
| - رفض كلمة المرور الخاطئة.
| - منع الحساب الموقوف من الدخول.
| - اختبار المستخدم الحالي /me.
| - منع الوصول بدون Token.
| - التأكد أن logout يلغي Token الجهاز الحالي فعلًا.
|
*/

namespace Tests\Feature\Api\V1\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * يمكن إنشاء حساب جديد وإصدار Sanctum Token.
     */
    public function test_user_can_register(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'username' => 'new_user',
            'display_name' => 'مستخدم جديد',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'New.User@Example.COM',
            'device_name' => 'SM N975U',
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.user.username', 'new_user')
            ->assertJsonPath('data.user.display_name', 'مستخدم جديد')
            ->assertJsonPath('data.user.status', 'active')
            ->assertJsonPath(
                'data.user.contacts.0.value',
                'new.user@example.com',
            )
            ->assertJsonPath('data.token_type', 'Bearer')
            ->assertJsonStructure([
                'data' => [
                    'user' => [
                        'id',
                        'username',
                        'display_name',
                        'status',
                        'last_login_at',
                        'contacts',
                    ],
                    'access_token',
                    'token_type',
                ],
            ]);

        $this->assertNotEmpty(
            $response->json('data.access_token'),
        );

        $this->assertDatabaseHas('users', [
            'username' => 'new_user',
            'display_name' => 'مستخدم جديد',
            'status' => 'active',
        ]);

        $this->assertDatabaseHas('user_contacts', [
            'type' => 'email',
            'value' => 'new.user@example.com',
            'is_primary' => true,
        ]);

        $this->assertDatabaseCount(
            'personal_access_tokens',
            1,
        );
    }

    /**
     * username غير حساس لحالة الأحرف.
     */
    public function test_duplicate_username_is_rejected_case_insensitively(): void
    {
        User::factory()->create([
            'username' => 'merchant_one',
        ]);

        $response = $this->postJson(
            '/api/v1/auth/register',
            $this->registrationPayload([
                'username' => 'MERCHANT_ONE',
            ]),
        );

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'username',
            ]);
    }

    /**
     * البريد المستخدم في حساب آخر لا يمكن استخدامه مجددًا.
     */
    public function test_duplicate_email_is_rejected_case_insensitively(): void
    {
        $user = User::factory()->create();

        $user->contacts()->create([
            'type' => 'email',
            'value' => 'Owner@Example.com',
            'is_primary' => true,
        ]);

        $response = $this->postJson(
            '/api/v1/auth/register',
            $this->registrationPayload([
                'contact_value' => 'OWNER@EXAMPLE.COM',
            ]),
        );

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'contact_value',
            ]);
    }

    /**
     * تسجيل الدخول بواسطة اسم المستخدم.
     */
    public function test_user_can_login_with_username(): void
    {
        $user = $this->createUser(
            username: 'supplier_one',
        );

        $response = $this->postJson('/api/v1/auth/login', [
            'login' => 'SUPPLIER_ONE',
            'password' => 'Secret123!',
            'device_name' => 'Android Phone',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.user.id',
                $user->id,
            )
            ->assertJsonPath(
                'data.user.username',
                'supplier_one',
            )
            ->assertJsonPath(
                'data.token_type',
                'Bearer',
            );

        $this->assertNotEmpty(
            $response->json('data.access_token'),
        );

        $this->assertDatabaseCount(
            'personal_access_tokens',
            1,
        );

        $this->assertNotNull(
            $user->fresh()->last_login_at,
        );
    }

    /**
     * تسجيل الدخول بواسطة البريد الإلكتروني.
     */
    public function test_user_can_login_with_email(): void
    {
        $user = $this->createUser();

        $user->contacts()->create([
            'type' => 'email',
            'value' => 'seller@example.com',
            'is_primary' => true,
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'login' => 'SELLER@EXAMPLE.COM',
            'password' => 'Secret123!',
            'device_name' => 'Android Phone',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.user.id',
                $user->id,
            );

        $this->assertNotEmpty(
            $response->json('data.access_token'),
        );
    }

    /**
     * تسجيل الدخول بواسطة رقم الهاتف.
     */
    public function test_user_can_login_with_phone(): void
    {
        $user = $this->createUser();

        $user->contacts()->create([
            'type' => 'phone',
            'value' => '+967777123456',
            'is_primary' => true,
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'login' => '+967777123456',
            'password' => 'Secret123!',
            'device_name' => 'Android Phone',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.user.id',
                $user->id,
            );
    }

    /**
     * كلمة المرور الخاطئة لا تصدر Token.
     */
    public function test_login_fails_with_invalid_password(): void
    {
        $this->createUser(
            username: 'shop_owner',
        );

        $response = $this->postJson('/api/v1/auth/login', [
            'login' => 'shop_owner',
            'password' => 'WrongPassword!',
            'device_name' => 'Android Phone',
        ]);

        $response->assertUnauthorized();

        $this->assertDatabaseCount(
            'personal_access_tokens',
            0,
        );
    }

    /**
     * الحساب الموقوف لا يستطيع تسجيل الدخول.
     */
    public function test_suspended_user_cannot_login(): void
    {
        User::factory()->create([
            'username' => 'suspended_user',
            'password' => 'Secret123!',
            'status' => 'suspended',
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'login' => 'suspended_user',
            'password' => 'Secret123!',
            'device_name' => 'Android Phone',
        ]);

        $response->assertForbidden();

        $this->assertDatabaseCount(
            'personal_access_tokens',
            0,
        );
    }

    /**
     * المستخدم الموثق يستطيع قراءة بياناته.
     */
    public function test_authenticated_user_can_get_current_profile(): void
    {
        $user = $this->createUser(
            username: 'profile_user',
        );

        $user->contacts()->create([
            'type' => 'phone',
            'value' => '+967777999999',
            'is_primary' => true,
        ]);

        $token = $user
            ->createToken('Test Device')
            ->plainTextToken;

        $response = $this
            ->withToken($token)
            ->getJson('/api/v1/auth/me');

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.id',
                $user->id,
            )
            ->assertJsonPath(
                'data.username',
                'profile_user',
            )
            ->assertJsonPath(
                'data.contacts.0.value',
                '+967777999999',
            );
    }

    /**
     * /me محمي بواسطة Sanctum.
     */
    public function test_guest_cannot_access_current_profile(): void
    {
        $this
            ->getJson('/api/v1/auth/me')
            ->assertUnauthorized();
    }

    /**
     * logout يلغي Token الحالي فقط.
     */
    public function test_logout_revokes_current_access_token(): void
    {
        $user = $this->createUser();

        $newToken = $user->createToken(
            'Android Phone',
        );

        $plainTextToken = $newToken->plainTextToken;
        $tokenId = $newToken->accessToken->id;

        $this
            ->withToken($plainTextToken)
            ->postJson('/api/v1/auth/logout')
            ->assertOk()
            ->assertJsonPath(
                'message',
                'تم تسجيل الخروج بنجاح.',
            );

        $this->assertDatabaseMissing(
            'personal_access_tokens',
            [
                'id' => $tokenId,
            ],
        );

        /*
         * الاختبار ينفذ عدة طلبات داخل نفس عملية PHP.
         *
         * لذلك نصفر Auth Guard حتى يكون الطلب التالي
         * مشابهًا لطلب HTTP جديد حقيقي من تطبيق Flutter.
         *
         * بعدها يجب على Sanctum البحث عن Token مرة أخرى
         * في قاعدة البيانات، ولن يجده لأنه تم حذفه.
         */
        Auth::forgetGuards();

        /*
         * بعد logout يجب ألا يعمل نفس Token مرة أخرى.
         */
        $this
            ->withToken($plainTextToken)
            ->getJson('/api/v1/auth/me')
            ->assertUnauthorized();
    }

    /**
     *   * بيانات تسجيل افتراضية لتقليل التكرار داخل الاختبارات.
     */
    private function registrationPayload(
        array $overrides = [],
    ): array {
        return array_merge([
            'username' => 'new_account',
            'display_name' => 'مستخدم جديد',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'account@example.com',
            'device_name' => 'Android Phone',
        ], $overrides);
    }

    /**
     * إنشاء مستخدم نشط جاهز لاختبارات تسجيل الدخول.
     */
    private function createUser(
        string $username = 'merchant_user',
    ): User {
        return User::factory()->create([
            'username' => $username,
            'password' => 'Secret123!',
            'status' => 'active',
        ]);
    }
}
