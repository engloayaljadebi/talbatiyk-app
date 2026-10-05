<?php

namespace Tests\Feature\Api\V1\Product;

use App\Models\Business;
use App\Models\BusinessMembership;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProductManagementApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_owner_lists_only_products_from_requested_business(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->businessFor(
            $owner,
            'Managed Supplier',
            'owner',
        );

        $otherOwner = User::factory()->create([
            'status' => 'active',
        ]);

        $otherBusiness = $this->businessFor(
            $otherOwner,
            'Other Supplier',
            'owner',
        );

        $this->productFor(
            $business,
            'Own Product A',
        );

        $this->productFor(
            $business,
            'Own Product B',
        );

        $this->productFor(
            $otherBusiness,
            'Other Supplier Product',
        );

        Sanctum::actingAs($owner);

        $response = $this->getJson(
            "/api/v1/businesses/{$business->id}/products?per_page=100",
        );

        $response
            ->assertOk()
            ->assertJsonCount(
                2,
                'data',
            )
            ->assertJsonFragment([
                'name' => 'Own Product A',
                'version' => 1,
            ])
            ->assertJsonFragment([
                'name' => 'Own Product B',
                'version' => 1,
            ])
            ->assertJsonMissing([
                'name' => 'Other Supplier Product',
            ]);
    }

    public function test_staff_cannot_open_product_management_list(): void
    {
        $staff = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->businessFor(
            $staff,
            'Staff Supplier',
            'staff',
        );

        Sanctum::actingAs($staff);

        $this->getJson(
            "/api/v1/businesses/{$business->id}/products",
        )->assertForbidden();
    }

    public function test_user_outside_business_receives_not_found(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->businessFor(
            $owner,
            'Private Supplier',
            'owner',
        );

        $outsider = User::factory()->create([
            'status' => 'active',
        ]);

        Sanctum::actingAs($outsider);

        $this->getJson(
            "/api/v1/businesses/{$business->id}/products",
        )->assertNotFound();
    }

    private function businessFor(
        User $user,
        string $name,
        string $roleCode,
    ): Business {
        DB::table('business_roles')->updateOrInsert(
            [
                'code' => $roleCode,
            ],
            [
                'is_active' => true,
            ],
        );

        $business = Business::query()->create([
            'name' => $name,
            'status' => 'active',
        ]);

        $membership = BusinessMembership::query()->create([
            'user_id' => $user->id,
            'business_id' => $business->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        $membership->roles()->attach(
            $roleCode,
            [
                'assigned_at' => now(),
            ],
        );

        return $business;
    }

    private function productFor(
        Business $business,
        string $name,
    ): Product {
        return Product::query()->create([
            'supplier_id' => $business->id,
            'name' => $name,
            'description' => null,
            'category' => 'Test',
            'brand' => 'Test',
            'price' => 100,
            'quantity' => 5,
            'is_available' => true,
            'image_url' => null,
            'colors' => [],
            'discount' => 0,
            'rating' => 0,
        ]);
    }
}
