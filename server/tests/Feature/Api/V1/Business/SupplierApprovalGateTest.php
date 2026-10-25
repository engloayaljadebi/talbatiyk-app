<?php

namespace Tests\Feature\Api\V1\Business;

use App\Models\Business;
use App\Models\BusinessCategory;
use App\Models\User;
use Database\Seeders\BusinessCapabilitySeeder;
use Database\Seeders\BusinessRoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SupplierApprovalGateTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessRoleSeeder::class);
        $this->seed(BusinessCapabilitySeeder::class);

        BusinessCategory::query()->firstOrCreate(
            ['code' => 'test_business_leaf'],
            [
                'name_ar' => 'Test activity category',
                'is_active' => true,
                'sort_order' => 0,
            ],
        );
    }

    public function test_new_supplier_requires_pending_approval_and_has_no_active_supplier_capability(): void
    {
        $business = $this->createBusiness(['supplier', 'shop']);

        $this->assertDatabaseHas('verifications', [
            'business_id' => $business->id,
            'verification_type_code' => 'supplier_approval',
            'status' => 'pending',
        ]);

        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $business->id,
            'capability_code' => 'supplier',
            'disabled_at' => null,
        ]);

        $this->assertDatabaseHas('verifications', [
            'business_id' => $business->id,
            'verification_type_code' => 'shop_approval',
            'status' => 'pending',
        ]);

        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $business->id,
            'capability_code' => 'shop',
            'disabled_at' => null,
        ]);
    }

    public function test_pending_supplier_is_not_listed_in_supplier_discovery(): void
    {
        $business = $this->createBusiness(['supplier']);

        $this->getJson('/api/v1/suppliers')
            ->assertOk()
            ->assertJsonMissing(['id' => $business->id]);
    }

    public function test_pending_supplier_cannot_read_supplier_received_orders(): void
    {
        $business = $this->createBusiness(['supplier']);

        $this->getJson('/api/v1/businesses/'.$business->id.'/received-orders')
            ->assertForbidden();
    }

    public function test_pending_supplier_cannot_open_product_management_list(): void
    {
        $business = $this->createBusiness(['supplier']);

        // Supplier management APIs must not be available
        // before the supplier capability has been approved.
        $this->getJson(
            "/api/v1/businesses/{$business->id}/products",
        )->assertForbidden();
    }

    public function test_shop_only_registration_requires_pending_approval(): void
    {
        $business = $this->createBusiness(['shop']);

        $this->assertSame('active', $business->status);

        $this->assertDatabaseHas('verifications', [
            'business_id' => $business->id,
            'verification_type_code' => 'shop_approval',
            'status' => 'pending',
        ]);

        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $business->id,
            'capability_code' => 'shop',
            'disabled_at' => null,
        ]);
    }

    /** @param list<string> $capabilities */
    private function createBusiness(array $capabilities): Business
    {
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/v1/businesses', [
            'name' => 'Supplier approval test business',
            'category_ids' => [
                BusinessCategory::query()
                    ->where('code', 'test_business_leaf')
                    ->value('id'),
            ],
            'capabilities' => $capabilities,
            'location' => [
                'name' => 'Main branch',
                'type' => 'store',
                'timezone' => 'Asia/Aden',
                'country_code' => 'YE',
            ],
            'contact' => [
                'type' => 'phone',
                'value' => '+967777123456',
            ],
        ])->assertCreated();

        return Business::query()->sole();
    }
}
