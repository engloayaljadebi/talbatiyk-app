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

use App\Models\Business;
use App\Models\BusinessCategory;
use App\Models\BusinessRole;
use App\Models\User;
use Database\Seeders\BusinessCapabilitySeeder;
use Database\Seeders\BusinessRoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Routing\Middleware\ThrottleRequests;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_registration_requires_account_type(): void
    {
        $payload = $this->registrationPayload([
            'username' => 'missingtype',
        ]);

        unset($payload['account_type']);

        $this->postJson('/api/v1/auth/register', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['account_type']);

        $this->assertDatabaseMissing('users', [
            'username' => 'missingtype',
        ]);
    }

    public function test_registration_rejects_customer_account_type(): void
    {
        $payload = $this->registrationPayload([
            'username' => 'customertype',
            'account_type' => 'customer',
        ]);

        $this->postJson('/api/v1/auth/register', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['account_type']);

        $this->assertDatabaseMissing('users', [
            'username' => 'customertype',
        ]);
    }

    /**
     * يمكن إنشاء حساب جديد وإصدار Sanctum Token.
     */
    public function test_user_can_register(): void
    {
        $response = $this->postJson('/api/v1/auth/register', $this->registrationPayload([
            'username' => 'newuser',
            'display_name' => 'مستخدم جديد',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'New.User@Example.COM',
            'device_name' => 'SM N975U',
        ]));

        $response
            ->assertCreated()
            ->assertJsonPath('data.user.username', 'newuser')
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
            'username' => 'newuser',
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
            'username' => 'merchantone',
        ]);

        $response = $this->postJson(
            '/api/v1/auth/register',
            $this->registrationPayload([
                'username' => 'MERCHANTONE',
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
     * طلب API بدون Accept: application/json يجب أن يعيد 401 JSON.
     *
     * هذا الاختبار يمنع رجوع مشكلة:
     * Route [login] not defined
     *
     * لأن تطبيق Flutter قد يرسل الطلب بدون Accept صريح،
     * ومسارات API يجب ألا تحاول التحويل إلى صفحة Login.
     */
    public function test_guest_request_without_json_accept_header_returns_401_json(): void
    {
        $response = $this->get('/api/v1/auth/me');

        $response
            ->assertUnauthorized()
            ->assertHeader('Content-Type', 'application/json')
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);
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

    public function test_register_rejects_password_over_bcrypt_byte_limit(): void
    {
        $password = str_repeat('ع', 37);

        $this
            ->postJson(
                '/api/v1/auth/register',
                $this->registrationPayload([
                    'password' => $password,
                    'password_confirmation' => $password,
                ]),
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'password',
            ]);

        $this->assertDatabaseCount('users', 0);
    }

    public function test_login_rejects_password_over_bcrypt_byte_limit(): void
    {
        $this->createUser(
            username: 'byte_limit_user',
        );

        $this
            ->postJson('/api/v1/auth/login', [
                'login' => 'byte_limit_user',
                'password' => str_repeat('ع', 37),
                'device_name' => 'Android Phone',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'password',
            ]);

        $this->assertDatabaseCount(
            'personal_access_tokens',
            0,
        );
    }

    /**
     *   * بيانات تسجيل افتراضية لتقليل التكرار داخل الاختبارات.
     */
    private function registrationPayload(
        array $overrides = [],
    ): array {
        // Every successful API registration must create a shop or supplier.
        // Seed only the reference data needed by commercial onboarding.
        $this->seed(BusinessRoleSeeder::class);
        $this->seed(BusinessCapabilitySeeder::class);

        $category = BusinessCategory::query()->firstOrCreate(
            ['code' => 'auth_registration_test_leaf'],
            [
                'name_ar' => 'فئة اختبار التسجيل',
                'is_active' => true,
                'sort_order' => 0,
            ],
        );

        return array_merge([
            'account_type' => 'shop',
            'username' => 'newaccount',
            'display_name' => 'مستخدم جديد',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'account@example.com',
            'device_name' => 'Android Phone',
            'name' => 'Test Shop',
            'category_id' => $category->id,
            'location_name' => 'Main Store',
            'administrative_area' => 'Sanaa',
            'locality' => 'Sanaa',
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

    public function test_username_accepts_english_letters_and_numbers(): void
    {
        $response = $this->postJson('/api/v1/auth/register', $this->registrationPayload([
            'username' => 'Ahmed2026',
            'display_name' => 'Test User',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'english@example.com',
            'device_name' => 'Android',
        ]));

        $response->assertCreated()
            ->assertJsonPath('data.user.username', 'ahmed2026');
    }

    public function test_username_accepts_digits_only(): void
    {
        $response = $this->postJson('/api/v1/auth/register', $this->registrationPayload([
            'username' => '077123456',
            'display_name' => 'Test User',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'digits@example.com',
            'device_name' => 'Android',
        ]));

        $response->assertCreated()
            ->assertJsonPath('data.user.username', '077123456');
    }

    public function test_username_rejects_arabic_and_symbols(): void
    {
        $this->withoutMiddleware(ThrottleRequests::class);
        foreach ([
            'احمد123',
            'Ahmed_123',
            'Ahmed.123',
            'Ahmed-123',
            'Ahmed@123',
            'Ahmed 123',
        ] as $username) {
            $response = $this->postJson(
                '/api/v1/auth/register',
                $this->registrationPayload([
                    'username' => $username,
                    'display_name' => 'Test User',
                    'password' => 'StrongPass123!',
                    'password_confirmation' => 'StrongPass123!',
                    'contact_type' => 'email',
                    'contact_value' => 'invalid@example.com',
                    'device_name' => 'Android',
                ])
            );

            $response->assertUnprocessable()
                ->assertJsonValidationErrors(['username']);
        }

        $this->assertDatabaseCount('users', 0);
    }

    public function test_mobile_phone_registration_and_login(): void
    {
        $response = $this->postJson('/api/v1/auth/register', $this->registrationPayload([
            'username' => 'phoneowner01',
            'display_name' => 'Phone Owner',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'phone',
            'contact_value' => '012345678',
            'device_name' => 'Android',
        ]));

        $response->assertCreated()
            ->assertJsonPath('data.user.username', 'phoneowner01')
            ->assertJsonPath(
                'data.user.contacts.0.value',
                '012345678'
            );

        $userId = $response->json('data.user.id');

        $this->postJson('/api/v1/auth/login', [
            'login' => '012345678',
            'password' => 'StrongPass123!',
            'device_name' => 'Android',
        ])->assertOk()
            ->assertJsonPath('data.user.id', $userId);
    }

    public function test_mobile_phone_may_equal_numeric_username(): void
    {
        $response = $this->postJson('/api/v1/auth/register', $this->registrationPayload([
            'username' => '077123456',
            'display_name' => 'Numeric User',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'phone',
            'contact_value' => '077123456',
            'device_name' => 'Android',
        ]));

        $response->assertCreated()
            ->assertJsonPath('data.user.username', '077123456')
            ->assertJsonPath(
                'data.user.contacts.0.value',
                '077123456'
            );
    }

    public function test_mobile_numeric_username_cannot_use_another_users_phone(): void
    {
        $existing = User::factory()->create([
            'username' => 'existingowner',
        ]);

        $existing->contacts()->create([
            'type' => 'phone',
            'value' => '071234567',
            'is_primary' => true,
        ]);

        $response = $this->postJson('/api/v1/auth/register', $this->registrationPayload([
            'username' => '071234567',
            'display_name' => 'Another User',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'another@example.com',
            'device_name' => 'Android',
        ]));

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['username']);
    }

    public function test_mobile_full_registration_creates_business_and_pending_approval(): void
    {
        $this->seed(BusinessRoleSeeder::class);
        $this->seed(BusinessCapabilitySeeder::class);

        $category = BusinessCategory::query()->create([
            'code' => 'mobile_full_registration_leaf',
            'name_ar' => 'فئة الاختبار',
            'is_active' => true,
            'sort_order' => 0,
        ]);

        foreach (['shop', 'supplier'] as $type) {
            $username = 'mobile'.$type;
            $phone = $type === 'shop' ? '077123456' : '077234567';
            $businessName = 'Business '.$type;

            $response = $this->postJson('/api/v1/auth/register', [
                'account_type' => $type,
                'username' => $username,
                'display_name' => 'Mobile Test User',
                'password' => 'StrongPass123!',
                'password_confirmation' => 'StrongPass123!',
                'contact_type' => 'phone',
                'contact_value' => $phone,
                'device_name' => 'Android',
                'nationality_country_code' => 'YE',
                'birth_date' => '2000-01-15',
                'name' => $businessName,
                'category_id' => $category->id,
                'location_name' => 'Main Location',
                'administrative_area' => 'Sanaa',
                'locality' => 'Sanaa',
                'business_contact_type' => 'email',
                'business_contact_value' => $username.'@example.com',
            ]);

            $response->assertCreated()
                ->assertJsonPath('data.user.username', $username);

            $user = User::query()
                ->where('username', $username)
                ->sole();

            $this->assertDatabaseHas('user_profiles', [
                'user_id' => $user->id,
                'nationality_country_code' => 'YE',
                'birth_date' => '2000-01-15',
            ]);

            $business = Business::query()
                ->where('name', $businessName)
                ->sole();

            $this->assertDatabaseHas('business_category_assignments', [
                'business_id' => $business->id,
                'category_id' => $category->id,
            ]);

            $this->assertDatabaseHas('business_locations', [
                'business_id' => $business->id,
                'name' => 'Main Location',
                'is_primary' => true,
            ]);

            $this->assertDatabaseHas('business_memberships', [
                'business_id' => $business->id,
                'user_id' => $user->id,
                'status' => 'active',
            ]);

            $this->assertDatabaseHas('verifications', [
                'business_id' => $business->id,
                'verification_type_code' => $type.'_approval',
                'status' => 'pending',
            ]);

            $this->assertDatabaseMissing('business_capability_assignments', [
                'business_id' => $business->id,
                'capability_code' => $type,
                'disabled_at' => null,
            ]);
        }
    }

    public function test_mobile_full_registration_rejects_inactive_category_without_creating_user(): void
    {
        $this->seed(BusinessRoleSeeder::class);
        $this->seed(BusinessCapabilitySeeder::class);

        $category = BusinessCategory::query()->create([
            'code' => 'mobile_inactive_registration_leaf',
            'name_ar' => 'فئة غير نشطة',
            'is_active' => false,
            'sort_order' => 0,
        ]);

        $this->postJson('/api/v1/auth/register', [
            'account_type' => 'shop',
            'username' => 'mobileinvalid',
            'display_name' => 'Invalid Mobile User',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'phone',
            'contact_value' => '077345678',
            'device_name' => 'Android',
            'name' => 'Invalid Business',
            'category_id' => $category->id,
            'location_name' => 'Main Location',
            'administrative_area' => 'Sanaa',
            'locality' => 'Sanaa',
        ])->assertUnprocessable();

        $this->assertDatabaseMissing('users', [
            'username' => 'mobileinvalid',
        ]);

        $this->assertDatabaseMissing('businesses', [
            'name' => 'Invalid Business',
        ]);
    }

    public function test_registration_categories_are_public_and_only_active_leaves(): void
    {
        $parent = BusinessCategory::query()->create([
            'code' => 'registration_parent',
            'name_ar' => 'القسم الرئيسي',
            'is_active' => true,
            'sort_order' => 0,
        ]);

        $leaf = BusinessCategory::query()->create([
            'code' => 'registration_active_leaf',
            'name_ar' => 'الفئة المتاحة',
            'parent_id' => $parent->id,
            'is_active' => true,
            'sort_order' => 0,
        ]);

        BusinessCategory::query()->create([
            'code' => 'registration_inactive_leaf',
            'name_ar' => 'الفئة المعطلة',
            'parent_id' => $parent->id,
            'is_active' => false,
            'sort_order' => 1,
        ]);

        $inactiveParent = BusinessCategory::query()->create([
            'code' => 'registration_inactive_parent',
            'name_ar' => 'قسم معطل',
            'is_active' => false,
            'sort_order' => 2,
        ]);

        BusinessCategory::query()->create([
            'code' => 'registration_hidden_leaf',
            'name_ar' => 'فئة تحت قسم معطل',
            'parent_id' => $inactiveParent->id,
            'is_active' => true,
            'sort_order' => 3,
        ]);

        $this->getJson('/api/v1/auth/registration-categories')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $leaf->id)
            ->assertJsonPath('data.0.name', 'الفئة المتاحة');
    }

    public function test_full_registration_rolls_back_when_owner_role_is_missing(): void
    {
        $this->seed(BusinessRoleSeeder::class);
        $this->seed(BusinessCapabilitySeeder::class);

        $category = BusinessCategory::query()->create([
            'code' => 'registration_rollback_leaf',
            'name_ar' => 'فئة التراجع',
            'is_active' => true,
            'sort_order' => 0,
        ]);

        BusinessRole::query()
            ->where('code', 'owner')
            ->delete();

        $this->withoutExceptionHandling();

        try {
            $this->postJson('/api/v1/auth/register', [
                'account_type' => 'shop',
                'username' => 'rollbackuser',
                'display_name' => 'Rollback User',
                'password' => 'StrongPass123!',
                'password_confirmation' => 'StrongPass123!',
                'contact_type' => 'phone',
                'contact_value' => '077456789',
                'device_name' => 'Android',
                'nationality_country_code' => 'YE',
                'birth_date' => '2000-01-15',
                'name' => 'Rollback Business',
                'category_id' => $category->id,
                'location_name' => 'Main Location',
                'administrative_area' => 'Sanaa',
                'locality' => 'Sanaa',
            ]);

            $this->fail('Expected onboarding failure.');
        } catch (\RuntimeException $exception) {
            $this->assertSame(
                'The required business owner role is not configured.',
                $exception->getMessage(),
            );
        }

        $this->assertDatabaseCount('users', 0);
        $this->assertDatabaseCount('user_contacts', 0);
        $this->assertDatabaseCount('user_profiles', 0);
        $this->assertDatabaseCount('businesses', 0);
        $this->assertDatabaseCount('business_locations', 0);
        $this->assertDatabaseCount('business_memberships', 0);
        $this->assertDatabaseCount('verifications', 0);
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }
}
