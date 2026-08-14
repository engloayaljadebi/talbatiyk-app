<?php

/*
|--------------------------------------------------------------------------
| اختبارات وسائل اتصال النشاط - BusinessContactApiTest
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - اختبار وسائل الاتصال العامة للنشاط.
| - اختبار وسائل الاتصال الخاصة بالفروع.
| - اختبار صلاحيات owner و manager و staff.
| - اختبار منع الوصول بين الأنشطة والفروع.
| - اختبار الهاتف وواتساب والبريد والموقع الإلكتروني.
| - اختبار منع التكرار.
| - اختبار تعيين الوسيلة الرئيسية لكل نوع.
| - اختبار الحذف المنطقي.
| - اختبار إلغاء التوثيق عند تغيير القيمة.
| - اختبار العضويات والحسابات غير النشطة.
|
*/

namespace Tests\Feature\Api\V1\Business;

use App\Models\Business;
use App\Models\BusinessContact;
use App\Models\BusinessLocation;
use App\Models\BusinessMembership;
use App\Models\User;
use Database\Seeders\BusinessRoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class BusinessContactApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessRoleSeeder::class);
    }

    public function test_active_staff_can_read_business_contacts(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'staff',
        );

        $primary = $this->createBusinessContact(
            business: $business,
            type: 'phone',
            value: '+967777111111',
            label: 'الرئيسي',
            isPrimary: true,
        );

        $secondary = $this->createBusinessContact(
            business: $business,
            type: 'phone',
            value: '+967777222222',
            label: 'المبيعات',
        );

        Sanctum::actingAs($user);

        $response = $this->getJson(
            "/api/v1/businesses/{$business->id}/contacts",
        );

        $response
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.id', $primary->id)
            ->assertJsonPath('data.0.is_primary', true)
            ->assertJsonPath('data.1.id', $secondary->id);
    }

    public function test_active_member_can_read_single_business_contact(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'staff',
        );

        $contact = $this->createBusinessContact(
            business: $business,
            type: 'email',
            value: 'sales@example.com',
            label: 'المبيعات',
        );

        Sanctum::actingAs($user);

        $this
            ->getJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}",
            )
            ->assertOk()
            ->assertJsonPath('data.id', $contact->id)
            ->assertJsonPath('data.type', 'email')
            ->assertJsonPath('data.value', 'sales@example.com')
            ->assertJsonPath('data.label', 'المبيعات');
    }

    public function test_owner_can_create_business_contact(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        Sanctum::actingAs($owner);

        $response = $this->postJson(
            "/api/v1/businesses/{$business->id}/contacts",
            [
                'type' => ' EMAIL ',
                'value' => ' Sales@Example.COM ',
                'label' => '  المبيعات  ',
            ],
        );

        $response
            ->assertCreated()
            ->assertJsonPath('data.type', 'email')
            ->assertJsonPath('data.value', 'sales@example.com')
            ->assertJsonPath('data.label', 'المبيعات')
            ->assertJsonPath('data.is_primary', false)
            ->assertJsonPath('data.is_verified', false)
            ->assertJsonPath('data.verified_at', null);

        $this->assertDatabaseHas('business_contacts', [
            'business_id' => $business->id,
            'business_location_id' => null,
            'type' => 'email',
            'value' => 'sales@example.com',
            'label' => 'المبيعات',
            'is_primary' => false,
            'verified_at' => null,
        ]);
    }

    public function test_manager_can_create_business_contact(): void
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
                "/api/v1/businesses/{$business->id}/contacts",
                [
                    'type' => 'phone',
                    'value' => '+967777123456',
                    'label' => 'الإدارة',
                ],
            )
            ->assertCreated()
            ->assertJsonPath(
                'data.value',
                '+967777123456',
            );
    }

    public function test_staff_cannot_create_business_contact(): void
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
                "/api/v1/businesses/{$business->id}/contacts",
                [
                    'type' => 'phone',
                    'value' => '+967777123456',
                ],
            )
            ->assertForbidden();

        $this->assertDatabaseMissing('business_contacts', [
            'business_id' => $business->id,
            'value' => '+967777123456',
        ]);
    }

    public function test_owner_can_create_location_contact(): void
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
                "/api/v1/businesses/{$business->id}/locations/{$location->id}/contacts",
                [
                    'type' => 'whatsapp',
                    'value' => '+967777654321',
                    'label' => 'واتساب الفرع',
                ],
            )
            ->assertCreated()
            ->assertJsonPath('data.type', 'whatsapp')
            ->assertJsonPath(
                'data.value',
                '+967777654321',
            );

        $this->assertDatabaseHas('business_contacts', [
            'business_id' => null,
            'business_location_id' => $location->id,
            'type' => 'whatsapp',
            'value' => '+967777654321',
        ]);
    }

    public function test_staff_can_read_location_contacts(): void
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

        $contact = $this->createLocationContact(
            location: $location,
            type: 'phone',
            value: '+967733111111',
        );

        Sanctum::actingAs($staff);

        $this
            ->getJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}/contacts",
            )
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath(
                'data.0.id',
                $contact->id,
            );
    }

    public function test_staff_cannot_create_location_contact(): void
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
                "/api/v1/businesses/{$business->id}/locations/{$location->id}/contacts",
                [
                    'type' => 'phone',
                    'value' => '+967777555555',
                ],
            )
            ->assertForbidden();
    }

    public function test_location_from_another_business_cannot_receive_contact(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $otherBusiness = Business::query()->create([
            'name' => 'نشاط آخر',
            'status' => 'active',
        ]);

        $otherLocation = $this->createLocation(
            business: $otherBusiness,
        );

        Sanctum::actingAs($owner);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/locations/{$otherLocation->id}/contacts",
                [
                    'type' => 'phone',
                    'value' => '+967777999999',
                ],
            )
            ->assertNotFound();
    }

    public function test_business_contact_from_another_business_is_not_visible(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $user,
            roleCode: 'owner',
        );

        $otherBusiness = Business::query()->create([
            'name' => 'النشاط الآخر',
            'status' => 'active',
        ]);

        $contact = $this->createBusinessContact(
            business: $otherBusiness,
            type: 'phone',
            value: '+967700000001',
        );

        Sanctum::actingAs($user);

        $this
            ->getJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}",
            )
            ->assertNotFound();

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}",
                [
                    'label' => 'اختراق',
                ],
            )
            ->assertNotFound();
    }

    public function test_location_contact_from_another_location_is_not_visible(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $locationA = $this->createLocation(
            business: $business,
            name: 'فرع أ',
        );

        $locationB = $this->createLocation(
            business: $business,
            name: 'فرع ب',
        );

        $contact = $this->createLocationContact(
            location: $locationB,
            value: '+967700000002',
        );

        Sanctum::actingAs($owner);

        $this
            ->getJson(
                "/api/v1/businesses/{$business->id}/locations/{$locationA->id}/contacts/{$contact->id}",
            )
            ->assertNotFound();
    }

    public function test_owner_can_partially_update_business_contact(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $contact = $this->createBusinessContact(
            business: $business,
            type: 'email',
            value: 'old@example.com',
            label: 'قديم',
        );

        Sanctum::actingAs($owner);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}",
                [
                    'label' => '  المبيعات  ',
                ],
            )
            ->assertOk()
            ->assertJsonPath(
                'data.value',
                'old@example.com',
            )
            ->assertJsonPath(
                'data.label',
                'المبيعات',
            );
    }

    public function test_updating_email_normalizes_value_and_clears_verification(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $contact = $this->createBusinessContact(
            business: $business,
            type: 'email',
            value: 'old@example.com',
            verifiedAt: now(),
        );

        Sanctum::actingAs($owner);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}",
                [
                    'value' => ' New@Example.COM ',
                ],
            )
            ->assertOk()
            ->assertJsonPath(
                'data.value',
                'new@example.com',
            )
            ->assertJsonPath(
                'data.is_verified',
                false,
            )
            ->assertJsonPath(
                'data.verified_at',
                null,
            );

        $this->assertDatabaseHas('business_contacts', [
            'id' => $contact->id,
            'value' => 'new@example.com',
            'verified_at' => null,
        ]);
    }

    public function test_changing_only_label_does_not_clear_verification(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $verifiedAt = now()->startOfSecond();

        $contact = $this->createBusinessContact(
            business: $business,
            type: 'phone',
            value: '+967711111111',
            verifiedAt: $verifiedAt,
        );

        Sanctum::actingAs($owner);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}",
                [
                    'label' => 'خدمة العملاء',
                ],
            )
            ->assertOk()
            ->assertJsonPath(
                'data.is_verified',
                true,
            );

        $contact->refresh();

        $this->assertNotNull(
            $contact->verified_at,
        );
    }

    public function test_owner_can_update_location_contact(): void
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

        $contact = $this->createLocationContact(
            location: $location,
            type: 'phone',
            value: '+967722222222',
        );

        Sanctum::actingAs($owner);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}/contacts/{$contact->id}",
                [
                    'value' => '+967733333333',
                    'label' => 'الفرع',
                ],
            )
            ->assertOk()
            ->assertJsonPath(
                'data.value',
                '+967733333333',
            )
            ->assertJsonPath(
                'data.label',
                'الفرع',
            );
    }

    public function test_staff_cannot_update_business_contact(): void
    {
        $staff = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $staff,
            roleCode: 'staff',
        );

        $contact = $this->createBusinessContact(
            business: $business,
        );

        Sanctum::actingAs($staff);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}",
                [
                    'label' => 'غير مسموح',
                ],
            )
            ->assertForbidden();
    }

    public function test_duplicate_business_email_is_rejected_case_insensitively(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $this->createBusinessContact(
            business: $business,
            type: 'email',
            value: 'sales@example.com',
        );

        Sanctum::actingAs($owner);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/contacts",
                [
                    'type' => 'email',
                    'value' => 'SALES@EXAMPLE.COM',
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'value',
            ]);
    }

    public function test_same_contact_value_is_allowed_for_different_businesses(): void
    {
        $ownerA = User::factory()->create([
            'status' => 'active',
        ]);

        $ownerB = User::factory()->create([
            'status' => 'active',
        ]);

        $businessA = $this->createBusinessWithRole(
            user: $ownerA,
            roleCode: 'owner',
        );

        $businessB = $this->createBusinessWithRole(
            user: $ownerB,
            roleCode: 'owner',
        );

        $this->createBusinessContact(
            business: $businessA,
            type: 'phone',
            value: '+967744444444',
        );

        Sanctum::actingAs($ownerB);

        $this
            ->postJson(
                "/api/v1/businesses/{$businessB->id}/contacts",
                [
                    'type' => 'phone',
                    'value' => '+967744444444',
                ],
            )
            ->assertCreated();
    }

    public function test_update_cannot_create_duplicate_contact(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $this->createBusinessContact(
            business: $business,
            type: 'phone',
            value: '+967755555551',
        );

        $contact = $this->createBusinessContact(
            business: $business,
            type: 'phone',
            value: '+967755555552',
        );

        Sanctum::actingAs($owner);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}",
                [
                    'value' => '+967755555551',
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'value',
            ]);
    }

    public function test_owner_can_set_primary_business_contact(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $oldPrimary = $this->createBusinessContact(
            business: $business,
            type: 'phone',
            value: '+967766666661',
            isPrimary: true,
        );

        $newPrimary = $this->createBusinessContact(
            business: $business,
            type: 'phone',
            value: '+967766666662',
        );

        Sanctum::actingAs($owner);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/contacts/{$newPrimary->id}/primary",
            )
            ->assertOk()
            ->assertJsonPath(
                'data.id',
                $newPrimary->id,
            )
            ->assertJsonPath(
                'data.is_primary',
                true,
            );

        $this->assertDatabaseHas('business_contacts', [
            'id' => $oldPrimary->id,
            'is_primary' => false,
        ]);

        $this->assertDatabaseHas('business_contacts', [
            'id' => $newPrimary->id,
            'is_primary' => true,
        ]);
    }

    public function test_primary_is_independent_for_each_contact_type(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $phone = $this->createBusinessContact(
            business: $business,
            type: 'phone',
            value: '+967777000001',
            isPrimary: true,
        );

        $email = $this->createBusinessContact(
            business: $business,
            type: 'email',
            value: 'primary@example.com',
        );

        Sanctum::actingAs($owner);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/contacts/{$email->id}/primary",
            )
            ->assertOk()
            ->assertJsonPath(
                'data.is_primary',
                true,
            );

        $this->assertDatabaseHas('business_contacts', [
            'id' => $phone->id,
            'is_primary' => true,
        ]);

        $this->assertDatabaseHas('business_contacts', [
            'id' => $email->id,
            'is_primary' => true,
        ]);
    }

    public function test_owner_can_set_primary_location_contact(): void
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

        $oldPrimary = $this->createLocationContact(
            location: $location,
            value: '+967788888881',
            isPrimary: true,
        );

        $newPrimary = $this->createLocationContact(
            location: $location,
            value: '+967788888882',
        );

        Sanctum::actingAs($owner);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}/contacts/{$newPrimary->id}/primary",
            )
            ->assertOk()
            ->assertJsonPath(
                'data.id',
                $newPrimary->id,
            )
            ->assertJsonPath(
                'data.is_primary',
                true,
            );

        $this->assertDatabaseHas('business_contacts', [
            'id' => $oldPrimary->id,
            'is_primary' => false,
        ]);
    }

    public function test_staff_cannot_set_primary_contact(): void
    {
        $staff = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $staff,
            roleCode: 'staff',
        );

        $contact = $this->createBusinessContact(
            business: $business,
        );

        Sanctum::actingAs($staff);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}/primary",
            )
            ->assertForbidden();
    }

    public function test_owner_can_soft_delete_business_contact(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $contact = $this->createBusinessContact(
            business: $business,
        );

        Sanctum::actingAs($owner);

        $this
            ->deleteJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}",
            )
            ->assertNoContent();

        $this->assertSoftDeleted('business_contacts', [
            'id' => $contact->id,
        ]);

        $this
            ->getJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}",
            )
            ->assertNotFound();
    }

    public function test_owner_can_soft_delete_location_contact(): void
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

        $contact = $this->createLocationContact(
            location: $location,
        );

        Sanctum::actingAs($owner);

        $this
            ->deleteJson(
                "/api/v1/businesses/{$business->id}/locations/{$location->id}/contacts/{$contact->id}",
            )
            ->assertNoContent();

        $this->assertSoftDeleted('business_contacts', [
            'id' => $contact->id,
        ]);
    }

    public function test_invalid_contact_types_and_values_are_rejected(): void
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
                "/api/v1/businesses/{$business->id}/contacts",
                [
                    'type' => 'telegram',
                    'value' => 'invalid',
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'type',
            ]);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/contacts",
                [
                    'type' => 'phone',
                    'value' => '777123456',
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'value',
            ]);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/contacts",
                [
                    'type' => 'email',
                    'value' => 'not-an-email',
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'value',
            ]);

        $this
            ->postJson(
                "/api/v1/businesses/{$business->id}/contacts",
                [
                    'type' => 'website',
                    'value' => 'not-a-url',
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'value',
            ]);
    }

    public function test_valid_website_contact_can_be_created(): void
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
                "/api/v1/businesses/{$business->id}/contacts",
                [
                    'type' => 'website',
                    'value' => 'https://example.com',
                ],
            )
            ->assertCreated()
            ->assertJsonPath(
                'data.value',
                'https://example.com',
            );
    }

    public function test_protected_fields_cannot_be_sent_on_create(): void
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
                "/api/v1/businesses/{$business->id}/contacts",
                [
                    'type' => 'phone',
                    'value' => '+967799999991',
                    'business_id' => $business->id,
                    'business_location_id' => fake()->uuid(),
                    'is_primary' => true,
                    'verified_at' => now()->toISOString(),
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'business_id',
                'business_location_id',
                'is_primary',
                'verified_at',
            ]);
    }

    public function test_protected_fields_cannot_be_changed_on_update(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithRole(
            user: $owner,
            roleCode: 'owner',
        );

        $contact = $this->createBusinessContact(
            business: $business,
        );

        Sanctum::actingAs($owner);

        $this
            ->patchJson(
                "/api/v1/businesses/{$business->id}/contacts/{$contact->id}",
                [
                    'type' => 'email',
                    'business_id' => fake()->uuid(),
                    'is_primary' => true,
                    'verified_at' => now()->toISOString(),
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'type',
                'business_id',
                'is_primary',
                'verified_at',
            ]);
    }

    public function test_non_string_contact_fields_are_rejected(): void
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
                "/api/v1/businesses/{$business->id}/contacts",
                [
                    'type' => ['phone'],
                    'value' => ['+967777123456'],
                    'label' => ['المبيعات'],
                ],
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'type',
                'value',
                'label',
            ]);
    }

    public function test_user_without_membership_cannot_read_contacts(): void
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
                "/api/v1/businesses/{$business->id}/contacts",
            )
            ->assertNotFound();
    }

    public function test_suspended_membership_cannot_access_contacts(): void
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
                "/api/v1/businesses/{$business->id}/contacts",
            )
            ->assertNotFound();
    }

    public function test_left_membership_cannot_access_contacts(): void
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
                "/api/v1/businesses/{$business->id}/contacts",
            )
            ->assertNotFound();
    }

    public function test_guest_cannot_access_contacts(): void
    {
        $business = Business::query()->create([
            'name' => 'النشاط',
            'status' => 'active',
        ]);

        $this
            ->getJson(
                "/api/v1/businesses/{$business->id}/contacts",
            )
            ->assertUnauthorized();
    }

    public function test_inactive_user_cannot_access_contacts(): void
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
                "/api/v1/businesses/{$business->id}/contacts",
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
        $business = Business::query()->create([
            'name' => 'النشاط',
            'legal_name' => 'النشاط القانوني',
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
        string $name = 'الفرع الرئيسي',
    ): BusinessLocation {
        return $business->locations()->create([
            'name' => $name,
            'type' => 'branch',
            'timezone' => 'Asia/Aden',
            'country_code' => 'YE',
            'administrative_area' => 'صنعاء',
            'locality' => 'صنعاء',
            'district' => null,
            'street_address' => null,
            'address_notes' => null,
            'latitude' => null,
            'longitude' => null,
            'is_primary' => false,
            'status' => 'active',
        ]);
    }

    private function createBusinessContact(
        Business $business,
        string $type = 'phone',
        string $value = '+967700000000',
        ?string $label = null,
        bool $isPrimary = false,
        mixed $verifiedAt = null,
    ): BusinessContact {
        return $business->contacts()->create([
            'type' => $type,
            'value' => $value,
            'label' => $label,
            'is_primary' => $isPrimary,
            'verified_at' => $verifiedAt,
        ]);
    }

    private function createLocationContact(
        BusinessLocation $location,
        string $type = 'phone',
        string $value = '+967711000000',
        ?string $label = null,
        bool $isPrimary = false,
        mixed $verifiedAt = null,
    ): BusinessContact {
        return $location->contacts()->create([
            'type' => $type,
            'value' => $value,
            'label' => $label,
            'is_primary' => $isPrimary,
            'verified_at' => $verifiedAt,
        ]);
    }
}
