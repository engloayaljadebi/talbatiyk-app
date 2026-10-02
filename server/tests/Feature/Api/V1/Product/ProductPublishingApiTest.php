<?php

namespace Tests\Feature\Api\V1\Product;

use App\Models\Business;
use App\Models\BusinessMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProductPublishingApiTest extends TestCase
{
    use RefreshDatabase;

    private const PUBLISH_IDEMPOTENCY_KEY =
        '71000000-0000-4000-8000-000000000001';

    private const FORBIDDEN_IDEMPOTENCY_KEY =
        '71000000-0000-4000-8000-000000000002';

    public function test_supplier_owner_can_publish_product_and_another_user_can_discover_it(): void
    {
        Storage::fake('public');

        $supplierUser = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            user: $supplierUser,
            roleCode: 'owner',
        );

        Sanctum::actingAs($supplierUser);

        $response = $this->post(
            "/api/v1/businesses/{$business->id}/products",
            [
                'name' => 'Online Published Product',
                'category' => 'Electronics',
                'brand' => 'Talbatiyk Test',
                'price' => '1250.50',
                'quantity' => '8',
                'description' => 'Published directly through the server.',
                'is_available' => '1',

                // يجب أن يتجاهل السيرفر أي محاولة لتحديد المورد من الهاتف.
                'supplier_id' => '00000000-0000-4000-8000-000000000000',

                'image' => UploadedFile::fake()->image(
                    'product.jpg',
                    800,
                    800,
                ),
            ],
            [
                'Accept' => 'application/json',
                'Idempotency-Key' => self::PUBLISH_IDEMPOTENCY_KEY,
            ],
        );

        $response
            ->assertCreated()
            ->assertJsonPath('data.name', 'Online Published Product')
            ->assertJsonPath('data.supplier_id', $business->id)
            ->assertJsonPath('data.supplier_name', $business->name);

        $productId = $response->json('data.id');

        $this->assertNotEmpty($productId);

        $this->assertDatabaseHas('products', [
            'id' => $productId,
            'supplier_id' => $business->id,
            'name' => 'Online Published Product',
            'quantity' => 8,
            'is_available' => true,
        ]);

        $storedImageUrl = $response->json('data.image_url');

        $this->assertIsString($storedImageUrl);
        $this->assertNotSame('', trim($storedImageUrl));

        // مستخدم آخر مستقل يجب أن يرى المنتج المنشور.
        $customer = User::factory()->create([
            'status' => 'active',
        ]);

        Sanctum::actingAs($customer);

        $this->getJson('/api/v1/products?per_page=100')
            ->assertOk()
            ->assertJsonFragment([
                'id' => $productId,
                'supplier_id' => $business->id,
                'name' => 'Online Published Product',
            ]);
    }

    public function test_non_member_cannot_publish_product_for_another_business(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            user: $owner,
            roleCode: 'owner',
        );

        $intruder = User::factory()->create([
            'status' => 'active',
        ]);

        Sanctum::actingAs($intruder);

        $this
            ->withHeader(
                'Idempotency-Key',
                self::FORBIDDEN_IDEMPOTENCY_KEY,
            )
            ->postJson(
                "/api/v1/businesses/{$business->id}/products",
                [
                    'name' => 'Forbidden Product',
                    'category' => 'Electronics',
                    'brand' => 'Test',
                    'price' => 100,
                    'quantity' => 1,
                    'description' => '',
                    'is_available' => true,
                ],
            )->assertNotFound();

        $this->assertDatabaseMissing('products', [
            'name' => 'Forbidden Product',
        ]);
    }

    private function supplierBusinessFor(
        User $user,
        string $roleCode,
    ): Business {
        DB::table('business_roles')->updateOrInsert(
            ['code' => $roleCode],
            ['is_active' => true],
        );

        DB::table('business_capabilities')->updateOrInsert(
            ['code' => 'supplier'],
            ['retired_at' => null],
        );

        $business = Business::query()->create([
            'name' => 'Online Supplier Business',
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

        DB::table(
            'business_capability_assignments',
        )->insert([
            'business_id' => $business->id,
            'capability_code' => 'supplier',
            'enabled_by_membership_id' => $membership->id,
            'enabled_at' => now(),
            'disabled_at' => null,
        ]);

        return $business;
    }
}
