<?php

namespace Tests\Feature\Api\V1\Product;

use App\Models\Business;
use App\Models\BusinessMembership;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProductMutationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_owner_can_update_own_product(): void
    {
        [$owner, $business, $product] = $this->supplierProduct('owner');

        Sanctum::actingAs($owner);

        $this->putJson(
            "/api/v1/businesses/{$business->id}/products/{$product->id}",
            [
                'expected_version' => $product->version,
                'name' => 'Updated Product',
                'description' => 'Updated description',
                'category' => 'Updated Category',
                'brand' => 'Updated Brand',
                'price' => 2500.50,
                'quantity' => 1000000,
                'is_available' => false,
            ],
        )
            ->assertOk()
            ->assertJsonPath('data.name', 'Updated Product')
            ->assertJsonPath('data.quantity', 1000000)
            ->assertJsonPath('data.is_available', false);

        $this->assertDatabaseHas('products', [
            'id' => $product->id,
            'supplier_id' => $business->id,
            'name' => 'Updated Product',
            'quantity' => 1000000,
            'is_available' => false,
        ]);
    }

    public function test_same_update_replay_with_old_version_is_idempotent(): void
    {
        [$owner, $business, $product] = $this->supplierProduct('owner');

        Sanctum::actingAs($owner);

        $expected = $product->version;

        $payload = [
            'expected_version' => $expected,
            'name' => 'Replay Product',
            'description' => 'Replay',
            'category' => 'Electronics',
            'brand' => 'Talbatiyk',
            'price' => 900,
            'quantity' => 15,
            'is_available' => true,
        ];

        $url = "/api/v1/businesses/{$business->id}/products/{$product->id}";

        $this->putJson($url, $payload)->assertOk();

        $this->putJson($url, $payload)
            ->assertOk()
            ->assertJsonPath('data.name', 'Replay Product');
    }

    public function test_stale_different_update_is_conflict(): void
    {
        [$owner, $business, $product] = $this->supplierProduct('owner');

        $stale = $product->version;

        DB::table('products')
            ->where('id', $product->id)
            ->update([
                'name' => 'Changed Elsewhere',
                'updated_at' => now()->addSeconds(2),
                'version' => ((int) $product->version) + 1,
                'version' => ((int) $product->version) + 1,
                'version' => ((int) $product->version) + 1,
            ]);

        Sanctum::actingAs($owner);

        $this->putJson(
            "/api/v1/businesses/{$business->id}/products/{$product->id}",
            [
                'expected_version' => $stale,
                'name' => 'Client Change',
                'description' => null,
                'category' => 'Electronics',
                'brand' => 'Talbatiyk',
                'price' => 100,
                'quantity' => 1,
                'is_available' => true,
            ],
        )->assertConflict();

        $this->assertDatabaseHas('products', [
            'id' => $product->id,
            'name' => 'Changed Elsewhere',
        ]);
    }

    public function test_staff_cannot_update_product(): void
    {
        [$staff, $business, $product] = $this->supplierProduct('staff');

        Sanctum::actingAs($staff);

        $this->putJson(
            "/api/v1/businesses/{$business->id}/products/{$product->id}",
            [
                'expected_version' => $product->version,
                'name' => 'Forbidden',
                'description' => null,
                'category' => 'Electronics',
                'brand' => 'Talbatiyk',
                'price' => 100,
                'quantity' => 1,
                'is_available' => true,
            ],
        )->assertForbidden();
    }

    public function test_cannot_mutate_product_from_another_business(): void
    {
        [$ownerA, $businessA, $productA] = $this->supplierProduct('owner');

        [$ownerB, $businessB] = $this->supplierProduct('owner');

        Sanctum::actingAs($ownerB);

        $this->putJson(
            "/api/v1/businesses/{$businessB->id}/products/{$productA->id}",
            [
                'expected_version' => $productA->version,
                'name' => 'Cross Business',
                'description' => null,
                'category' => 'Electronics',
                'brand' => 'Talbatiyk',
                'price' => 100,
                'quantity' => 1,
                'is_available' => true,
            ],
        )->assertNotFound();
    }

    public function test_owner_can_replace_product_image(): void
    {
        Storage::fake('public');

        [$owner, $business, $product] = $this->supplierProduct('owner');

        Sanctum::actingAs($owner);

        $response = $this->post(
            "/api/v1/businesses/{$business->id}/products/{$product->id}/image",
            [
                'expected_version' => $product->version,
                'image' => UploadedFile::fake()->image(
                    'replacement.jpg',
                    800,
                    800,
                ),
            ],
            ['Accept' => 'application/json'],
        );

        $response->assertOk();

        $storedPath = DB::table('products')
            ->where('id', $product->id)
            ->value('image_url');

        $this->assertIsString($storedPath);

        $this->assertStringStartsWith(
            "products/{$business->id}/products/{$product->id}/",
            $storedPath,
        );

        Storage::disk('public')->assertExists($storedPath);

        $response->assertJsonPath(
            'data.image_url',
            Storage::disk('public')->url($storedPath),
        );
    }

    public function test_removing_current_image_preserves_historical_file(): void
    {
        Storage::fake('public');

        [$owner, $business, $product] = $this->supplierProduct('owner');

        $oldPath = "products/{$business->id}/historical/old.jpg";

        Storage::disk('public')->put(
            $oldPath,
            'historical',
        );

        $product->forceFill([
            'image_url' => $oldPath,
        ])->save();

        $product->refresh();

        Sanctum::actingAs($owner);

        $this->putJson(
            "/api/v1/businesses/{$business->id}/products/{$product->id}",
            [
                'expected_version' => $product->version,
                'name' => $product->name,
                'description' => $product->description,
                'category' => $product->category,
                'brand' => $product->brand,
                'price' => (float) $product->price,
                'quantity' => $product->quantity,
                'is_available' => $product->is_available,
                'remove_image' => true,
            ],
        )
            ->assertOk()
            ->assertJsonPath('data.image_url', null);

        Storage::disk('public')->assertExists($oldPath);
    }

    public function test_delete_is_soft_and_retry_is_idempotent(): void
    {
        [$owner, $business, $product] = $this->supplierProduct('owner');

        Sanctum::actingAs($owner);

        $expected = $product->version;

        $url = "/api/v1/businesses/{$business->id}/products/{$product->id}";

        $this->deleteJson(
            $url,
            ['expected_version' => $expected],
        )->assertNoContent();

        $this->assertSoftDeleted('products', [
            'id' => $product->id,
        ]);

        $this->deleteJson(
            $url,
            ['expected_version' => $expected],
        )->assertNoContent();
    }

    public function test_stale_delete_is_conflict(): void
    {
        [$owner, $business, $product] = $this->supplierProduct('owner');

        $stale = $product->version;

        DB::table('products')
            ->where('id', $product->id)
            ->update([
                'name' => 'Changed Before Delete',
                'updated_at' => now()->addSeconds(2),
                'version' => ((int) $product->version) + 1,
                'version' => ((int) $product->version) + 1,
                'version' => ((int) $product->version) + 1,
            ]);

        Sanctum::actingAs($owner);

        $this->deleteJson(
            "/api/v1/businesses/{$business->id}/products/{$product->id}",
            ['expected_version' => $stale],
        )->assertConflict();

        $this->assertDatabaseHas('products', [
            'id' => $product->id,
            'deleted_at' => null,
        ]);
    }

    public function test_update_validation_matches_product_contract(): void
    {
        [$owner, $business, $product] = $this->supplierProduct('owner');

        Sanctum::actingAs($owner);

        $this->putJson(
            "/api/v1/businesses/{$business->id}/products/{$product->id}",
            [
                'expected_version' => $product->version,
                'name' => 'Invalid',
                'description' => null,
                'category' => 'Electronics',
                'brand' => 'Talbatiyk',
                'price' => 0,
                'quantity' => 1,
                'is_available' => true,
                'supplier_id' => $business->id,
                'rating' => 5,
            ],
        )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'price',
                'supplier_id',
                'rating',
            ]);
    }

    private function supplierProduct(string $role): array
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        DB::table('business_roles')->updateOrInsert(
            ['code' => $role],
            ['is_active' => true],
        );

        DB::table('business_capabilities')->updateOrInsert(
            ['code' => 'supplier'],
            ['retired_at' => null],
        );

        $business = Business::query()->create([
            'name' => 'Mutation Supplier',
            'status' => 'active',
        ]);

        $membership = BusinessMembership::query()->create([
            'user_id' => $user->id,
            'business_id' => $business->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        $membership->roles()->attach(
            $role,
            ['assigned_at' => now()],
        );

        DB::table('business_capability_assignments')->insert([
            'business_id' => $business->id,
            'capability_code' => 'supplier',
            'enabled_by_membership_id' => $membership->id,
            'enabled_at' => now(),
            'disabled_at' => null,
        ]);

        $product = Product::query()->create([
            'supplier_id' => $business->id,
            'name' => 'Original Product',
            'description' => 'Original description',
            'category' => 'Electronics',
            'brand' => 'Talbatiyk',
            'price' => 100,
            'quantity' => 10,
            'is_available' => true,
            'image_url' => null,
            'colors' => [],
            'discount' => 0,
            'rating' => 0,
        ]);

        /*
         * Read DB defaults back before exposing the concurrency token.
         */
        $product->refresh();

        /*
         * Read DB defaults back before exposing the concurrency token.
         */
        $product->refresh();

        /*
         * Read DB defaults back before exposing the concurrency token.
         */
        $product->refresh();

        return [$user, $business, $product];
    }
}
