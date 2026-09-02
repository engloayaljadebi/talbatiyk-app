<?php

namespace Tests\Feature\Api\V1\Business;

use App\Models\Business;
use App\Models\BusinessCapability;
use App\Models\User;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SupplierDiscoveryApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_unauthenticated_user_cannot_list_suppliers(): void
    {
        $this
            ->getJson('/api/v1/suppliers')
            ->assertUnauthorized();
    }

    public function test_active_supplier_is_returned_without_requiring_membership(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Visible supplier',
        );

        /*
         * Supplier discovery is customer-facing RFQ discovery.
         * The authenticated user does not need a BusinessMembership
         * in the supplier Business.
         */
        $this->assertDatabaseMissing(
            'business_memberships',
            [
                'business_id' => $supplier->id,
                'user_id' => $user->id,
            ],
        );

        Sanctum::actingAs($user);

        $this
            ->getJson('/api/v1/suppliers')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath(
                'data.0.id',
                $supplier->id,
            )
            ->assertJsonPath(
                'data.0.name',
                'Visible supplier',
            );
    }

    public function test_ineligible_businesses_are_omitted(): void
    {
        $user = User::factory()->create();

        $visible = $this->createSupplier(
            name: 'Eligible supplier',
        );

        $suspended = $this->createSupplier(
            name: 'Suspended supplier',
            status: 'suspended',
        );

        $disabled = $this->createSupplier(
            name: 'Disabled supplier',
            disabled: true,
        );

        $withoutSupplierCapability = Business::query()->create([
            'name' => 'Ordinary business',
            'status' => 'active',
        ]);

        $withoutSupplierCapability
            ->capabilities()
            ->attach(
                'shop',
                [
                    'enabled_at' => now()->subMinute(),
                    'disabled_at' => null,
                ],
            );

        Sanctum::actingAs($user);

        $response = $this
            ->getJson('/api/v1/suppliers')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonFragment([
                'id' => $visible->id,
                'name' => $visible->name,
            ]);

        $response
            ->assertJsonMissing([
                'id' => $suspended->id,
            ])
            ->assertJsonMissing([
                'id' => $disabled->id,
            ])
            ->assertJsonMissing([
                'id' => $withoutSupplierCapability->id,
            ]);
    }

    public function test_retired_supplier_capability_is_omitted(): void
    {
        $user = User::factory()->create();

        $supplier = $this->createSupplier(
            name: 'Retired capability supplier',
        );

        BusinessCapability::query()
            ->whereKey('supplier')
            ->update([
                'retired_at' => now(),
            ]);

        Sanctum::actingAs($user);

        $this
            ->getJson('/api/v1/suppliers')
            ->assertOk()
            ->assertJsonCount(0, 'data')
            ->assertJsonMissing([
                'id' => $supplier->id,
            ]);
    }

    public function test_suppliers_are_ordered_by_name(): void
    {
        $user = User::factory()->create();

        $supplierZ = $this->createSupplier(
            name: 'Zulu supplier',
        );

        $supplierA = $this->createSupplier(
            name: 'Alpha supplier',
        );

        $supplierM = $this->createSupplier(
            name: 'Middle supplier',
        );

        Sanctum::actingAs($user);

        $this
            ->getJson('/api/v1/suppliers')
            ->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonPath(
                'data.0.id',
                $supplierA->id,
            )
            ->assertJsonPath(
                'data.1.id',
                $supplierM->id,
            )
            ->assertJsonPath(
                'data.2.id',
                $supplierZ->id,
            );
    }

    private function createSupplier(
        string $name,
        string $status = 'active',
        bool $disabled = false,
    ): Business {
        $supplier = Business::query()->create([
            'name' => $name,
            'status' => $status,
        ]);

        $supplier
            ->capabilities()
            ->attach(
                'supplier',
                [
                    'enabled_at' => now()->subMinute(),
                    'disabled_at' => $disabled
                        ? now()
                        : null,
                ],
            );

        return $supplier;
    }
}
