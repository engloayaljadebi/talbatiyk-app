<?php

/*
|--------------------------------------------------------------------------
| اختبارات مواقع النشاط التجاري - Business Location API
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - اختبار عرض مواقع النشاط.
| - اختبار عرض موقع واحد.
| - اختبار إنشاء المواقع بواسطة owner و manager.
| - منع staff من إدارة المواقع مع السماح له بالقراءة.
| - اختبار تعديل الموقع.
| - اختبار الحذف المنطقي.
| - منع حذف الموقع الرئيسي.
| - اختبار تغيير الموقع الرئيسي.
| - منع الوصول عبر نشاط آخر.
| - اختبار العضويات غير النشطة.
| - اختبار الحسابات غير النشطة والضيوف.
| - اختبار قواعد التحقق من البيانات.
|
*/

namespace Tests\Feature\Api\V1\Business;

use App\Models\Business;
use App\Models\BusinessLocation;
use App\Models\BusinessMembership;
use App\Models\User;
use Database\Seeders\BusinessRoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class BusinessLocationApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessRoleSeeder::class);
    }

    public function test_active_staff_can_read_business_locations(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'staff',
        );

        $primary = $this->createLocation(
            business: $business,
            name: 'الفرع الرئيسي',
            isPrimary: true,
        );

        $secondary = $this->createLocation(
            business: $business,
            name: 'فرع حدة',
        );

        Sanctum::actingAs($user);

        $response = $this->getJson(
            "/api/v1/businesses/{$business->id}/locations",
        );

        $response
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.id', $primary->id)
            ->assertJsonPath('data.0.is_primary', true)
            ->assertJsonPath('data.1.id', $secondary->id);
    }

    public function test_active_member_can_read_single_business_location(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'staff',
        );

        $location = $this->createLocation(
            business: $business,
            name: 'مخزن حدة',
            type: 'warehouse',
        );

        Sanctum::actingAs($user);

        $this
            ->getJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}",
            )
            ->assertOk()
            ->assertJsonPath('data.id', $location->id)
            ->assertJsonPath('data.name', 'مخزن حدة')
            ->assertJsonPath('data.type', 'warehouse');
    }

    public function test_owner_can_create_business_location(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'owner',
        );

        Sanctum::actingAs($user);

        $response = $this->postJson(
            "/api/v1/businesses/{$business->id}/locations",
            [
                'name' => '  فرع التحرير  ',
                'type' => 'branch',
                'timezone' => 'Asia/Aden',
                'country_code' => 'ye',
                'administrative_area' => 'صنعاء',
                'locality' => 'صنعاء',
                'district' => 'التحرير',
                'street_address' => 'شارع التحرير',
                'address_notes' => 'بجوار البنك',
                'latitude' => 15.3694,
                'longitude' => 44.1910,
            ],
        );

        $response
            ->assertCreated()
            ->assertJsonPath('data.name', 'فرع التحرير')
            ->assertJsonPath('data.type', 'branch')
            ->assertJsonPath('data.timezone', 'Asia/Aden')
            ->assertJsonPath('data.address.country_code', 'YE')
            ->assertJsonPath('data.is_primary', false)
            ->assertJsonPath('data.status', 'active');

        $this->assertDatabaseHas('business_locations', [
            'business_id' => $business->id,
            'name' => 'فرع التحرير',
            'type' => 'branch',
            'country_code' => 'YE',
            'is_primary' => false,
            'status' => 'active',
        ]);
    }

    public function test_manager_can_create_business_location(): void
    {
        $manager = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $manager,
            roleCode: 'manager',
        );

        Sanctum::actingAs($manager);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/locations",
                [
                    'name' => 'المخزن الثاني',
                    'type' => 'warehouse',
                    'timezone' => 'Asia/Aden',
                    'country_code' => 'YE',
                ],
            )
            ->assertCreated()
            ->assertJsonPath('data.name', 'المخزن الثاني')
            ->assertJsonPath('data.type', 'warehouse');

        $this->assertDatabaseHas('business_locations', [
            'business_id' => $business->id,
            'name' => 'المخزن الثاني',
        ]);
    }

    public function test_staff_cannot_create_business_location(): void
    {
        $staff = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $staff,
            roleCode: 'staff',
        );

        Sanctum::actingAs($staff);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/locations",
                [
                    'name' => 'فرع غير مسموح',
                    'type' => 'branch',
                    'timezone' => 'Asia/Aden',
                    'country_code' => 'YE',
                ],
            )
            ->assertForbidden();

        $this->assertDatabaseMissing('business_locations', [
            'business_id' => $business->id,
            'name' => 'فرع غير مسموح',
        ]);
    }

    public function test_owner_can_partially_update_business_location(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $location = $this->createLocation(
            business: $business,
            name: 'فرع قديم',
            type: 'branch',
        );

        Sanctum::actingAs($owner);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}",
                [
                    'name' => '  فرع جديد  ',
                    'status' => 'temporarily_closed',
                ],
            )
            ->assertOk()
            ->assertJsonPath('data.name', 'فرع جديد')
            ->assertJsonPath('data.status', 'temporarily_closed')
            ->assertJsonPath('data.type', 'branch')
            ->assertJsonPath('data.timezone', 'Asia/Aden');

        $this->assertDatabaseHas('business_locations', [
            'id' => $location->id,
            'name' => 'فرع جديد',
            'type' => 'branch',
            'status' => 'temporarily_closed',
        ]);
    }

    public function test_staff_cannot_update_business_location(): void
    {
        $staff = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $staff,
            roleCode: 'staff',
        );

        $location = $this->createLocation(
            business: $business,
        );

        Sanctum::actingAs($staff);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}",
                [
                    'name' => 'اسم غير مسموح',
                ],
            )
            ->assertForbidden();

        $this->assertDatabaseHas('business_locations', [
            'id' => $location->id,
            'name' => 'الفرع',
        ]);
    }

    public function test_location_from_another_business_is_not_visible(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'owner',
        );

        $otherBusiness = Business::create([
            'name' => 'نشاط آخر',
            'status' => 'active',
        ]);

        $otherLocation = $this->createLocation(
            business: $otherBusiness,
        );

        Sanctum::actingAs($user);

        $this
            ->getJson(
                "/api/v1/businesses/{$business->id}/locations/{$otherLocation->id}",
            )
            ->assertNotFound();

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/locations/{$otherLocation->id}",
                [
                    'name' => 'محاولة اختراق',
                ],
            )
            ->assertNotFound();
    }

    public function test_user_without_membership_cannot_read_business_locations(): void
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
            ->getJson(
                "/api/v1/businesses/{$business->id}/locations",
            )
            ->assertNotFound();
    }

    public function test_suspended_membership_cannot_access_business_locations(): void
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
            ->getJson(
                "/api/v1/businesses/{$business->id}/locations",
            )
            ->assertNotFound();
    }

    public function test_left_membership_cannot_access_business_locations(): void
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
            ->getJson(
                "/api/v1/businesses/{$business->id}/locations",
            )
            ->assertNotFound();
    }

    public function test_owner_can_set_primary_business_location(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $oldPrimary = $this->createLocation(
            business: $business,
            name: 'الرئيسي القديم',
            isPrimary: true,
        );

        $newPrimary = $this->createLocation(
            business: $business,
            name: 'الرئيسي الجديد',
        );

        Sanctum::actingAs($owner);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/locations/{$newPrimary->id}/primary",
            )
            ->assertOk()
            ->assertJsonPath('data.id', $newPrimary->id)
            ->assertJsonPath('data.is_primary', true);

        $this->assertDatabaseHas('business_locations', [
            'id' => $oldPrimary->id,
            'is_primary' => false,
        ]);

        $this->assertDatabaseHas('business_locations', [
            'id' => $newPrimary->id,
            'is_primary' => true,
        ]);

        $this->assertSame(
            1,
            BusinessLocation::query()
                ->where('business_id', $business->id)
                ->where('is_primary', true)
                ->count(),
        );
    }

    public function test_staff_cannot_set_primary_business_location(): void
    {
        $staff = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $staff,
            roleCode: 'staff',
        );

        $location = $this->createLocation(
            business: $business,
        );

        Sanctum::actingAs($staff);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}/primary",
            )
            ->assertForbidden();

        $this->assertDatabaseHas('business_locations', [
            'id' => $location->id,
            'is_primary' => false,
        ]);
    }

    public function test_owner_can_soft_delete_non_primary_location(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $location = $this->createLocation(
            business: $business,
            name: 'فرع للحذف',
        );

        Sanctum::actingAs($owner);

        $this
            ->deleteJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}",
            )
            ->assertNoContent();

        $this->assertSoftDeleted('business_locations', [
            'id' => $location->id,
        ]);

        $this
            ->getJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}",
            )
            ->assertNotFound();
    }

    public function test_primary_location_cannot_be_deleted(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $location = $this->createLocation(
            business: $business,
            isPrimary: true,
        );

        Sanctum::actingAs($owner);

        $this
            ->deleteJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}",
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'location',
            ]);

        $this->assertDatabaseHas('business_locations', [
            'id' => $location->id,
            'deleted_at' => null,
            'is_primary' => true,
        ]);
    }

    public function test_create_location_validates_required_fields(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        Sanctum::actingAs($owner);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/locations",
                [],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'name',
                'type',
                'timezone',
                'country_code',
            ]);
    }

    public function test_create_location_validates_type_status_and_coordinates(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        Sanctum::actingAs($owner);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/locations",
                [
                    'name' => 'فرع اختبار',
                    'type' => 'invalid',
                    'timezone' => 'Invalid/Timezone',
                    'country_code' => 'YEM',
                    'status' => 'invalid',
                    'latitude' => 100,
                    'longitude' => 200,
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'type',
                'timezone',
                'country_code',
                'status',
                'latitude',
                'longitude',
            ]);
    }

    public function test_coordinates_must_be_supplied_together(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        Sanctum::actingAs($owner);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/locations",
                [
                    'name' => 'فرع اختبار',
                    'type' => 'branch',
                    'timezone' => 'Asia/Aden',
                    'country_code' => 'YE',
                    'latitude' => 15.3694,
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'longitude',
            ]);
    }

    public function test_business_id_and_is_primary_cannot_be_sent_directly(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        Sanctum::actingAs($owner);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/locations",
                [
                    'name' => 'فرع اختبار',
                    'type' => 'branch',
                    'timezone' => 'Asia/Aden',
                    'country_code' => 'YE',
                    'business_id' => $business->id,
                    'is_primary' => true,
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'business_id',
                'is_primary',
            ]);
    }

    public function test_guest_cannot_access_business_locations(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $this
            ->getJson(
                "/api/v1/businesses/{$business->id}/locations",
            )
            ->assertUnauthorized();
    }

    public function test_inactive_user_cannot_access_business_locations(): void
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
            ->getJson(
                "/api/v1/businesses/{$business->id}/locations",
            )
            ->assertForbidden()
            ->assertJsonPath(
                'code',
                'ACCOUNT_INACTIVE',
            );
    }

    private function createBusinessWithRole(
        User $user,
        string $roleCode,
        string $membershipStatus = 'active',
    ): Business {
        $business = Business::create([
            'name' => 'النشاط',
            'legal_name' => 'الاسم القانوني',
            'description' => 'وصف النشاط',
            'status' => 'active',
        ]);

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

    private function createLocation(
        Business $business,
        string $name = 'الفرع',
        string $type = 'branch',
        bool $isPrimary = false,
    ): BusinessLocation {
        return $business->locations()->create([
            'name' => $name,
            'type' => $type,
            'timezone' => 'Asia/Aden',
            'country_code' => 'YE',
            'administrative_area' => 'صنعاء',
            'locality' => 'صنعاء',
            'district' => null,
            'street_address' => null,
            'address_notes' => null,
            'latitude' => null,
            'longitude' => null,
            'is_primary' => $isPrimary,
            'status' => 'active',
        ]);
    }

    public function test_location_api_rejects_non_string_text_fields(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $location = $this->createLocation(
            business: $business,
        );

        Sanctum::actingAs($owner);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/locations",
                [
                    'name' => 123,
                    'type' => ['branch'],
                    'timezone' => ['Asia/Aden'],
                    'country_code' => 123,
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'name',
                'type',
                'timezone',
                'country_code',
            ]);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}",
                [
                    'name' => 123,
                    'administrative_area' => ['invalid'],
                    'address_notes' => 123,
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'name',
                'administrative_area',
                'address_notes',
            ]);

        $this->assertDatabaseHas('business_locations', [
            'id' => $location->id,
            'name' => 'الفرع',
        ]);
    }
}
