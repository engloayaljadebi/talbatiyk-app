<?php

namespace Tests\Feature\Api\V1\Product;

use App\Models\Business;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProductDiscoveryApiTest extends TestCase
{
    use RefreshDatabase;

    private function authenticatedUser(
        string $status = 'active'
    ): User {
        $user = User::factory()->create([
            'status' => $status,
        ]);

        Sanctum::actingAs($user);

        return $user;
    }

    private function supplier(
        string $status = 'active',
        bool $disabled = false,
        bool $retired = false
    ): Business {
        $business = Business::query()->create([
            'name' => 'Gate 2.1 Supplier',
            'status' => $status,
        ]);

        DB::table('business_capabilities')->updateOrInsert(
            ['code' => 'supplier'],
            [
                'retired_at' => $retired ? now() : null,
            ],
        );

        $enabledAt = now();

        DB::table(
            'business_capability_assignments'
        )->insert([
            'business_id' => $business->id,
            'capability_code' => 'supplier',
            'enabled_at' => $enabledAt,
            'disabled_at' => $disabled ? $enabledAt : null,
        ]);

        return $business;
    }

    private function product(
        Business $supplier,
        array $attributes = []
    ): Product {
        return Product::query()->create(array_merge([
            'supplier_id' => $supplier->id,
            'name' => 'Gate 2.1 Product',
            'description' => null,
            'category' => 'test',
            'brand' => 'test',
            'price' => 10,
            'quantity' => 10,
            'is_available' => true,
            'image_url' => null,
            'colors' => [],
            'discount' => 0,
            'rating' => 0,
        ], $attributes));
    }

    public function test_guest_cannot_discover_products(): void
    {
        $this->getJson('/api/v1/products')
            ->assertUnauthorized();
    }

    public function test_active_authenticated_user_can_discover_products_without_follow(): void
    {
        $this->authenticatedUser();

        $supplierA = $this->supplier();
        $supplierB = $this->supplier();

        $productA = $this->product($supplierA, [
            'name' => 'Supplier A Product',
        ]);

        $productB = $this->product($supplierB, [
            'name' => 'Supplier B Product',
        ]);

        $this->getJson('/api/v1/products')
            ->assertOk()
            ->assertJsonFragment(['id' => $productA->id])
            ->assertJsonFragment(['id' => $productB->id]);
    }

    public function test_suspended_user_cannot_discover_products(): void
    {
        $this->authenticatedUser('suspended');

        $response = $this->getJson('/api/v1/products');

        $this->assertContains(
            $response->status(),
            [401, 403],
        );
    }

    public function test_unavailable_product_remains_discoverable(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier();

        $product = $this->product($supplier, [
            'is_available' => false,
            'quantity' => 0,
        ]);

        $this->getJson('/api/v1/products')
            ->assertOk()
            ->assertJsonFragment([
                'id' => $product->id,
                'is_available' => false,
            ]);
    }

    public function test_suspended_supplier_is_excluded(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier('suspended');
        $product = $this->product($supplier);

        $this->getJson('/api/v1/products')
            ->assertOk()
            ->assertJsonMissing(['id' => $product->id]);
    }

    public function test_closed_supplier_is_excluded(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier('closed');
        $product = $this->product($supplier);

        $this->getJson('/api/v1/products')
            ->assertOk()
            ->assertJsonMissing(['id' => $product->id]);
    }

    public function test_disabled_supplier_capability_is_excluded(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier('active', true);
        $product = $this->product($supplier);

        $this->getJson('/api/v1/products')
            ->assertOk()
            ->assertJsonMissing(['id' => $product->id]);
    }

    public function test_retired_supplier_capability_is_excluded(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier(
            status: 'active',
            retired: true,
        );

        $product = $this->product($supplier);

        $this->getJson('/api/v1/products')
            ->assertOk()
            ->assertJsonMissing(['id' => $product->id]);
    }

    public function test_soft_deleted_product_is_excluded(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier();
        $product = $this->product($supplier);

        $product->delete();

        $this->getJson('/api/v1/products')
            ->assertOk()
            ->assertJsonMissing(['id' => $product->id]);
    }

    public function test_products_are_paginated_without_duplicates(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier();

        for ($i = 0; $i < 25; $i++) {
            $this->product($supplier, [
                'name' => 'Product '.$i,
            ]);
        }

        $page1 = $this->getJson(
            '/api/v1/products?per_page=20&page=1'
        )
            ->assertOk()
            ->assertJsonCount(20, 'data')
            ->assertJsonPath('meta.per_page', 20)
            ->json('data');

        $page2 = $this->getJson(
            '/api/v1/products?per_page=20&page=2'
        )
            ->assertOk()
            ->assertJsonCount(5, 'data')
            ->json('data');

        $page1Ids = array_column($page1, 'id');
        $page2Ids = array_column($page2, 'id');

        $this->assertSame(
            [],
            array_values(
                array_intersect($page1Ids, $page2Ids)
            ),
        );
    }

    public function test_page_below_one_is_rejected(): void
    {
        $this->authenticatedUser();

        $this->getJson('/api/v1/products?page=0')
            ->assertUnprocessable();
    }

    public function test_per_page_above_limit_is_rejected(): void
    {
        $this->authenticatedUser();

        $this->getJson('/api/v1/products?per_page=101')
            ->assertUnprocessable();
    }
}
