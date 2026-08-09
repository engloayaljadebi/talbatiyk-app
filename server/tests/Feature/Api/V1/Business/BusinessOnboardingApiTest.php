<?php

/*
|--------------------------------------------------------------------------
| اختبارات Business Onboarding API
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التأكد أن المستخدم المسجل يستطيع إنشاء نشاط كامل.
| - التأكد من إنشاء الموقع والاتصال والعضوية والدور والقدرات.
| - التأكد من توحيد البيانات قبل التخزين.
| - رفض الطلبات غير الصحيحة قبل الوصول إلى قاعدة البيانات.
| - التأكد أن المستخدم غير المسجل لا يستطيع إنشاء نشاط.
| - التأكد من Rollback الكامل عند فشل أي خطوة داخل Transaction.
|
*/

namespace Tests\Feature\Api\V1\Business;

use App\Models\Business;
use App\Models\BusinessCapability;
use App\Models\BusinessMembership;
use App\Models\BusinessRole;
use App\Models\User;
use Database\Seeders\BusinessCapabilitySeeder;
use Database\Seeders\BusinessRoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use RuntimeException;
use Tests\TestCase;

class BusinessOnboardingApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * تجهيز البيانات المرجعية المطلوبة لكل اختبار.
     */
    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessRoleSeeder::class);
        $this->seed(BusinessCapabilitySeeder::class);
    }

    /**
     * المستخدم المسجل يستطيع إنشاء نشاط تجاري كامل.
     */
    public function test_authenticated_user_can_create_complete_business(): void
    {
        $user = User::factory()->create();

        Sanctum::actingAs($user);

        $response = $this->postJson(
            '/api/v1/businesses',
            $this->validPayload(),
        );

        $response
            ->assertCreated()
            ->assertJsonPath('data.name', 'الجعدبي فون')
            ->assertJsonPath('data.status', 'active')
            ->assertJsonPath(
                'data.primary_location.name',
                'الفرع الرئيسي',
            )
            ->assertJsonPath(
                'data.primary_location.is_primary',
                true,
            )
            ->assertJsonPath(
                'data.primary_contact.value',
                '+967777123456',
            )
            ->assertJsonPath(
                'data.primary_contact.is_primary',
                true,
            )
            ->assertJsonPath(
                'data.membership.status',
                'active',
            )
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'name',
                    'legal_name',
                    'description',
                    'status',
                    'capabilities',
                    'primary_location',
                    'primary_contact',
                    'membership' => [
                        'id',
                        'status',
                        'roles',
                        'joined_at',
                    ],
                    'created_at',
                    'updated_at',
                ],
            ]);

        /*
         * النشاط الأساسي.
         */
        $business = Business::query()->sole();

        $this->assertSame(
            'الجعدبي فون',
            $business->name,
        );

        /*
         * الموقع الرئيسي.
         */
        $this->assertDatabaseHas('business_locations', [
            'business_id' => $business->id,
            'name' => 'الفرع الرئيسي',
            'type' => 'store',
            'country_code' => 'YE',
            'is_primary' => true,
            'status' => 'active',
        ]);

        /*
         * وسيلة الاتصال العامة.
         */
        $this->assertDatabaseHas('business_contacts', [
            'business_id' => $business->id,
            'business_location_id' => null,
            'type' => 'phone',
            'value' => '+967777123456',
            'is_primary' => true,
            'verified_at' => null,
        ]);

        /*
         * عضوية المستخدم المنشئ.
         */
        $membership = BusinessMembership::query()
            ->where('business_id', $business->id)
            ->where('user_id', $user->id)
            ->sole();

        $this->assertSame(
            'active',
            $membership->status,
        );

        /*
         * دور المالك.
         *
         * assigned_by_membership_id = null
         * لأن النظام منح أول مالك دوره.
         */
        $this->assertDatabaseHas('membership_roles', [
            'membership_id' => $membership->id,
            'role_code' => 'owner',
            'assigned_by_membership_id' => null,
        ]);

        /*
         * قدرات النشاط.
         *
         * العضوية المنشئة هي التي فعّلت القدرات.
         */
        $this->assertDatabaseHas(
            'business_capability_assignments',
            [
                'business_id' => $business->id,
                'capability_code' => 'supplier',
                'enabled_by_membership_id' => $membership->id,
                'disabled_at' => null,
            ],
        );

        $this->assertDatabaseHas(
            'business_capability_assignments',
            [
                'business_id' => $business->id,
                'capability_code' => 'shop',
                'enabled_by_membership_id' => $membership->id,
                'disabled_at' => null,
            ],
        );
    }

    /**
     * البيانات النصية المعروفة يتم توحيدها قبل التخزين.
     */
    public function test_business_input_is_normalized_before_storage(): void
    {
        $user = User::factory()->create();

        Sanctum::actingAs($user);

        $payload = $this->validPayload([
            'name' => '  متجر التقنية  ',

            'capabilities' => [
                ' SUPPLIER ',
                ' SHOP ',
            ],

            'location' => [
                ...$this->validPayload()['location'],

                'name' => '  الفرع الرئيسي  ',
                'type' => ' STORE ',
                'country_code' => 'ye',
            ],

            'contact' => [
                'type' => ' EMAIL ',
                'value' => ' SALES@EXAMPLE.COM ',
                'label' => '  المبيعات  ',
            ],
        ]);

        $response = $this->postJson(
            '/api/v1/businesses',
            $payload,
        );

        $response
            ->assertCreated()
            ->assertJsonPath(
                'data.name',
                'متجر التقنية',
            )
            ->assertJsonPath(
                'data.primary_location.type',
                'store',
            )
            ->assertJsonPath(
                'data.primary_location.address.country_code',
                'YE',
            )
            ->assertJsonPath(
                'data.primary_contact.type',
                'email',
            )
            ->assertJsonPath(
                'data.primary_contact.value',
                'sales@example.com',
            )
            ->assertJsonPath(
                'data.primary_contact.label',
                'المبيعات',
            );

        $business = Business::query()->sole();

        $this->assertDatabaseHas('business_contacts', [
            'business_id' => $business->id,
            'type' => 'email',
            'value' => 'sales@example.com',
        ]);

        $this->assertDatabaseHas('business_locations', [
            'business_id' => $business->id,
            'type' => 'store',
            'country_code' => 'YE',
        ]);
    }

    /**
     * إنشاء النشاط يتطلب تسجيل الدخول.
     */
    public function test_guest_cannot_create_business(): void
    {
        $this
            ->postJson(
                '/api/v1/businesses',
                $this->validPayload(),
            )
            ->assertUnauthorized();

        $this->assertDatabaseCount('businesses', 0);
        $this->assertDatabaseCount('business_locations', 0);
        $this->assertDatabaseCount('business_contacts', 0);
        $this->assertDatabaseCount('business_memberships', 0);
    }

    /**
     * لا يسمح باستخدام قدرة غير معرفة في النظام.
     */
    public function test_unknown_business_capability_is_rejected(): void
    {
        $user = User::factory()->create();

        Sanctum::actingAs($user);

        $payload = $this->validPayload([
            'capabilities' => [
                'unknown_capability',
            ],
        ]);

        $this
            ->postJson('/api/v1/businesses', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'capabilities.0',
            ]);

        $this->assertDatabaseCount('businesses', 0);
    }

    /**
     * لا يسمح باستخدام قدرة تم إيقافها.
     */
    public function test_retired_business_capability_is_rejected(): void
    {
        BusinessCapability::query()
            ->where('code', 'supplier')
            ->update([
                'retired_at' => now(),
            ]);

        $user = User::factory()->create();

        Sanctum::actingAs($user);

        $payload = $this->validPayload([
            'capabilities' => [
                'supplier',
            ],
        ]);

        $this
            ->postJson('/api/v1/businesses', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'capabilities.0',
            ]);

        $this->assertDatabaseCount('businesses', 0);
    }

    /**
     * إحداثيات الموقع يجب أن تكون صحيحة.
     */
    public function test_invalid_location_coordinates_are_rejected(): void
    {
        $user = User::factory()->create();

        Sanctum::actingAs($user);

        $payload = $this->validPayload([
            'location' => [
                ...$this->validPayload()['location'],

                'latitude' => 100,
                'longitude' => 200,
            ],
        ]);

        $this
            ->postJson('/api/v1/businesses', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'location.latitude',
                'location.longitude',
            ]);

        $this->assertDatabaseCount('businesses', 0);
    }

    /**
     * الهاتف وواتساب يجب أن يكونا بصيغة E.164.
     */
    public function test_invalid_phone_contact_is_rejected(): void
    {
        $user = User::factory()->create();

        Sanctum::actingAs($user);

        $payload = $this->validPayload([
            'contact' => [
                'type' => 'phone',
                'value' => '0777123456',
                'label' => 'المبيعات',
            ],
        ]);

        $this
            ->postJson('/api/v1/businesses', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'contact.value',
            ]);

        $this->assertDatabaseCount('businesses', 0);
    }

    /**
     * فشل أي خطوة داخل الخدمة يجب أن يلغي العملية كاملة.
     */
    public function test_onboarding_rolls_back_completely_when_owner_role_is_missing(): void
    {
        /*
         * نحذف owner عمدًا.
         *
         * الخدمة ستصل إلى هذه النقطة بعد إنشاء:
         * - Business
         * - Location
         * - Contact
         * - Membership
         *
         * ثم يجب أن تفشل ويعيد PostgreSQL كل شيء.
         */
        BusinessRole::query()
            ->where('code', 'owner')
            ->delete();

        $user = User::factory()->create();

        Sanctum::actingAs($user);

        $this->withoutExceptionHandling();

        try {
            $this->postJson(
                '/api/v1/businesses',
                $this->validPayload(),
            );

            $this->fail(
                'Expected BusinessOnboardingService to fail without owner role.',
            );
        } catch (RuntimeException $exception) {
            $this->assertSame(
                'The required business owner role is not configured.',
                $exception->getMessage(),
            );
        }

        /*
         * أهم جزء في الاختبار:
         *
         * يجب ألا يبقى أي جزء من النشاط بعد الفشل.
         */
        $this->assertDatabaseCount('businesses', 0);
        $this->assertDatabaseCount('business_locations', 0);
        $this->assertDatabaseCount('business_contacts', 0);
        $this->assertDatabaseCount('business_memberships', 0);
        $this->assertDatabaseCount('membership_roles', 0);
        $this->assertDatabaseCount(
            'business_capability_assignments',
            0,
        );
    }

    /**
     * إنشاء بيانات طلب صحيحة قابلة للتخصيص في الاختبارات.
     *
     * @param  array<string, mixed>  $overrides
     * @return array<string, mixed>
     */
    private function validPayload(array $overrides = []): array
    {
        return array_replace_recursive([
            'name' => 'الجعدبي فون',

            'legal_name' => null,

            'description' => 'تجارة وتوزيع الهواتف والإكسسوارات.',

            'capabilities' => [
                'supplier',
                'shop',
            ],

            'location' => [
                'name' => 'الفرع الرئيسي',
                'type' => 'store',
                'timezone' => 'Asia/Aden',
                'country_code' => 'YE',
                'administrative_area' => 'صنعاء',
                'locality' => 'صنعاء',
                'district' => 'التحرير',
                'street_address' => 'شارع التحرير',
                'address_notes' => null,
                'latitude' => 15.3694,
                'longitude' => 44.1910,
            ],

            'contact' => [
                'type' => 'phone',
                'value' => '+967777123456',
                'label' => 'المبيعات',
            ],
        ], $overrides);
    }
}
