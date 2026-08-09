<?php

/*
|--------------------------------------------------------------------------
| اختبارات تعديل النشاط التجاري - Business Update API
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التأكد أن owner يستطيع تعديل النشاط.
| - التأكد أن manager يستطيع تعديل النشاط.
| - منع staff من تعديل البيانات الأساسية.
| - منع العضويات suspended و left من الوصول.
| - إخفاء النشاط عن المستخدم الذي لا يملك عضوية فيه.
| - منع الحساب غير النشط بواسطة active.user.
| - التحقق من قواعد UpdateBusinessRequest.
| - منع تعديل status و capabilities والمواقع والاتصالات.
| - التأكد من أن PATCH لا يمسح الحقول غير المرسلة.
| - التأكد من إعادة عضوية المستخدم الحالي فقط.
|
*/

namespace Tests\Feature\Api\V1\Business;

use App\Models\Business;
use App\Models\BusinessMembership;
use App\Models\BusinessRole;
use App\Models\User;
use Database\Seeders\BusinessRoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class BusinessUpdateApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * تجهيز الأدوار المرجعية قبل كل اختبار.
     */
    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessRoleSeeder::class);
    }

    /**
     * owner يستطيع تعديل البيانات الأساسية للنشاط.
     */
    public function test_owner_can_update_business_basic_data(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'owner',
        );

        Sanctum::actingAs($user);

        $response = $this->patchJson(
            "/api/v1/businesses/{$business->id}",
            [
                'name' => '  الجعدبي فون الجديد  ',
                'legal_name' => '  مؤسسة الجعدبي للتجارة  ',
                'description' => '  وصف النشاط بعد التعديل  ',
            ],
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.id',
                $business->id,
            )
            ->assertJsonPath(
                'data.name',
                'الجعدبي فون الجديد',
            )
            ->assertJsonPath(
                'data.legal_name',
                'مؤسسة الجعدبي للتجارة',
            )
            ->assertJsonPath(
                'data.description',
                'وصف النشاط بعد التعديل',
            )
            ->assertJsonPath(
                'data.membership.status',
                'active',
            )
            ->assertJsonPath(
                'data.membership.roles.0',
                'owner',
            );

        $this->assertDatabaseHas('businesses', [
            'id' => $business->id,
            'name' => 'الجعدبي فون الجديد',
            'legal_name' => 'مؤسسة الجعدبي للتجارة',
            'description' => 'وصف النشاط بعد التعديل',
            'status' => 'active',
        ]);
    }

    /**
     * manager يستطيع تعديل النشاط.
     *
     * كما نتأكد أن PATCH لا يغير الحقول
     * التي لم يرسلها المستخدم.
     */
    public function test_manager_can_partially_update_business(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'manager',
        );

        Sanctum::actingAs($user);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'name' => 'اسم جديد بواسطة المدير',
                ],
            )
            ->assertOk()
            ->assertJsonPath(
                'data.name',
                'اسم جديد بواسطة المدير',
            )
            ->assertJsonPath(
                'data.legal_name',
                'الاسم القانوني الأصلي',
            )
            ->assertJsonPath(
                'data.description',
                'الوصف الأصلي',
            );

        $this->assertDatabaseHas('businesses', [
            'id' => $business->id,
            'name' => 'اسم جديد بواسطة المدير',
            'legal_name' => 'الاسم القانوني الأصلي',
            'description' => 'الوصف الأصلي',
        ]);
    }

    /**
     * staff لديه عضوية نشطة لكنه لا يملك
     * صلاحية تعديل بيانات النشاط الأساسية.
     */
    public function test_staff_cannot_update_business(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'staff',
        );

        Sanctum::actingAs($user);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'name' => 'اسم غير مسموح',
                ],
            )
            ->assertForbidden();

        $this->assertDatabaseHas('businesses', [
            'id' => $business->id,
            'name' => 'النشاط الأصلي',
        ]);
    }

    /**
     * الدور المعطل عالميًا لا يمنح صلاحية
     * حتى لو كان مربوطًا بالعضوية.
     */
    public function test_inactive_business_role_does_not_grant_update_permission(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'manager',
        );

        BusinessRole::query()
            ->whereKey('manager')
            ->update([
                'is_active' => false,
            ]);

        Sanctum::actingAs($user);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'name' => 'اسم غير مسموح',
                ],
            )
            ->assertForbidden();

        $this->assertDatabaseHas('businesses', [
            'id' => $business->id,
            'name' => 'النشاط الأصلي',
        ]);
    }

    /**
     * المستخدم غير العضو يحصل على 404
     * بدل 403 حتى لا نكشف وجود النشاط.
     */
    public function test_user_without_membership_receives_not_found(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $otherUser = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        Sanctum::actingAs($otherUser);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'name' => 'محاولة غير مصرح بها',
                ],
            )
            ->assertNotFound();

        $this->assertDatabaseHas('businesses', [
            'id' => $business->id,
            'name' => 'النشاط الأصلي',
        ]);
    }

    /**
     * suspended membership لا تمنح
     * الوصول إلى Endpoint التعديل.
     */
    public function test_suspended_membership_cannot_update_business(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'owner',
            membershipStatus: 'suspended',
        );

        Sanctum::actingAs($user);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'name' => 'اسم جديد',
                ],
            )
            ->assertNotFound();
    }

    /**
     * العضوية التي غادرت النشاط لا تستطيع
     * تعديل بياناته.
     */
    public function test_left_membership_cannot_update_business(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'owner',
            membershipStatus: 'left',
        );

        Sanctum::actingAs($user);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'name' => 'اسم جديد',
                ],
            )
            ->assertNotFound();
    }

    /**
     * الزائر غير المسجل لا يستطيع
     * الوصول إلى Endpoint التعديل.
     */
    public function test_guest_cannot_update_business(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'owner',
        );

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'name' => 'اسم جديد',
                ],
            )
            ->assertUnauthorized();
    }

    /**
     * الحساب غير النشط يمنعه active.user
     * حتى لو كان owner داخل النشاط.
     */
    public function test_inactive_user_cannot_update_business(): void
    {
        $user = User::factory()->create([
            'status' => 'suspended',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'owner',
        );

        Sanctum::actingAs($user);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'name' => 'اسم جديد',
                ],
            )
            ->assertForbidden()
            ->assertJsonPath(
                'code',
                'ACCOUNT_INACTIVE',
            );

        $this->assertDatabaseHas('businesses', [
            'id' => $business->id,
            'name' => 'النشاط الأصلي',
        ]);
    }

    /**
     * الحقول التي لها إدارة مستقلة يجب
     * ألا تقبلها عملية تعديل البيانات الأساسية.
     */
    public function test_update_rejects_prohibited_business_fields(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'owner',
        );

        Sanctum::actingAs($user);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'status' => 'suspended',

                    'capabilities' => [
                        'supplier',
                    ],

                    'location' => [
                        'name' => 'فرع غير مسموح',
                    ],

                    'contact' => [
                        'type' => 'phone',
                        'value' => '+967777123456',
                    ],
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'status',
                'capabilities',
                'location',
                'contact',
            ]);

        $this->assertDatabaseHas('businesses', [
            'id' => $business->id,
            'status' => 'active',
            'name' => 'النشاط الأصلي',
        ]);
    }

    /**
     * قواعد الأطوال المستخدمة في التعديل
     * يجب أن تطابق قواعد إنشاء النشاط.
     */
    public function test_update_validates_business_field_limits(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'owner',
        );

        Sanctum::actingAs($user);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'name' => 'أ',
                    'legal_name' => str_repeat('A', 251),
                    'description' => str_repeat('B', 5001),
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'name',
                'legal_name',
                'description',
            ]);

        $this->assertDatabaseHas('businesses', [
            'id' => $business->id,
            'name' => 'النشاط الأصلي',
        ]);
    }

    /**
     * legal_name و description الاختياريان
     * يتحول النص الفارغ فيهما إلى null.
     */
    public function test_optional_text_fields_can_be_cleared(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'owner',
        );

        Sanctum::actingAs($user);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'legal_name' => '   ',
                    'description' => '   ',
                ],
            )
            ->assertOk()
            ->assertJsonPath(
                'data.legal_name',
                null,
            )
            ->assertJsonPath(
                'data.description',
                null,
            );

        $this->assertDatabaseHas('businesses', [
            'id' => $business->id,
            'legal_name' => null,
            'description' => null,
        ]);
    }

    /**
     * BusinessResource بعد التعديل يجب
     * أن يعرض عضوية المستخدم الحالي فقط.
     */
    public function test_update_response_contains_current_user_membership_only(): void
    {
        $manager = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $manager,
            roleCode: 'manager',
        );

        $managerMembership = BusinessMembership::query()
            ->where('business_id', $business->id)
            ->where('user_id', $manager->id)
            ->sole();

        Sanctum::actingAs($manager);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}",
                [
                    'name' => 'النشاط بعد تعديل المدير',
                ],
            )
            ->assertOk()
            ->assertJsonPath(
                'data.membership.id',
                $managerMembership->id,
            )
            ->assertJsonPath(
                'data.membership.roles.0',
                'manager',
            );
    }

    /**
     * إنشاء نشاط مع عضوية ودور صالحين
     * لاستخدامهما داخل اختبارات التعديل.
     *
     * owner:
     * - يتم إنشاء عضويته مباشرة.
     *
     * manager / staff:
     * - يتم إنشاء مالك حقيقي أولًا.
     * - ثم إنشاء عضوية المستخدم المستهدف.
     * - المالك هو من يمنح الدور.
     */
    private function createBusinessWithRole(
        User $user,
        string $roleCode,
        string $membershipStatus = 'active',
    ): Business {
        $business = Business::create([
            'name' => 'النشاط الأصلي',
            'legal_name' => 'الاسم القانوني الأصلي',
            'description' => 'الوصف الأصلي',
            'status' => 'active',
        ]);

        /*
         * إذا كان المستخدم نفسه هو owner
         * فلا نحتاج مالكًا إضافيًا.
         */
        if ($roleCode === 'owner') {
            $membership = $this->createMembership(
                business: $business,
                user: $user,
                status: $membershipStatus,
            );

            $membership->roles()->attach(
                'owner',
                [
                    'assigned_by_membership_id' => null,
                    'assigned_at' => now(),
                ],
            );

            return $business;
        }

        /*
         * manager و staff يجب أن يكون هناك
         * owner للنشاط منحهم الدور.
         */
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $ownerMembership = $this->createMembership(
            business: $business,
            user: $owner,
            status: 'active',
        );

        $ownerMembership->roles()->attach(
            'owner',
            [
                'assigned_by_membership_id' => null,
                'assigned_at' => now(),
            ],
        );

        $membership = $this->createMembership(
            business: $business,
            user: $user,
            status: $membershipStatus,
        );

        $membership->roles()->attach(
            $roleCode,
            [
                'assigned_by_membership_id' => $ownerMembership->id,
                'assigned_at' => now(),
            ],
        );

        return $business;
    }

    /**
     * إنشاء عضوية واحدة مع احترام
     * قاعدة left_at الخاصة بحالة left.
     */
    private function createMembership(
        Business $business,
        User $user,
        string $status,
    ): BusinessMembership {
        return $business->memberships()->create([
            'user_id' => $user->id,
            'status' => $status,
            'joined_at' => now(),

            'left_at' => $status === 'left'
                ? now()
                : null,
        ]);
    }
}
