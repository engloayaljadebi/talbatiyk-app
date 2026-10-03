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

    public function test_product_image_is_persisted_as_relative_public_disk_path_and_serialized_as_public_url(): void
    {
        config([
            'filesystems.disks.public.url' => 'http://127.0.0.1:8000/storage',
        ]);

        Storage::fake('public');

        $supplierUser = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            user: $supplierUser,
            roleCode: 'owner',
        );

        Sanctum::actingAs($supplierUser);

        $idempotencyKey =
            '71000000-0000-4000-8000-000000000010';

        $response = $this->post(
            "/api/v1/businesses/{$business->id}/products",
            [
                'name' => 'Relative Image Product',
                'category' => 'Electronics',
                'brand' => 'Talbatiyk Test',
                'price' => '250.00',
                'quantity' => '3',
                'description' => 'Relative image path verification.',
                'is_available' => '1',
                'image' => UploadedFile::fake()->image(
                    'relative-product.jpg',
                    640,
                    640,
                ),
            ],
            [
                'Accept' => 'application/json',
                'Idempotency-Key' => $idempotencyKey,
            ],
        );

        $response->assertCreated();

        $productId = $response->json('data.id');

        $storedImagePath = DB::table('products')
            ->where('id', $productId)
            ->value('image_url');

        $this->assertIsString($storedImagePath);
        $this->assertNotSame('', trim($storedImagePath));

        $expectedPrefix =
            "products/{$business->id}/idempotency/{$idempotencyKey}/";

        $this->assertStringStartsWith(
            $expectedPrefix,
            $storedImagePath,
        );

        $this->assertStringNotContainsString(
            'http://',
            $storedImagePath,
        );

        $this->assertStringNotContainsString(
            'https://',
            $storedImagePath,
        );

        $this->assertStringNotContainsString(
            'localhost',
            $storedImagePath,
        );

        $this->assertStringNotContainsString(
            'storage/app/public',
            $storedImagePath,
        );

        Storage::disk('public')->assertExists(
            $storedImagePath,
        );

        $response->assertJsonPath(
            'data.image_url',
            Storage::disk('public')->url(
                $storedImagePath,
            ),
        );
    }

    public function test_product_without_image_returns_null_image_url(): void
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
                'name' => 'Product Without Image',
                'category' => 'Electronics',
                'brand' => 'Talbatiyk Test',
                'price' => '100.00',
                'quantity' => '1',
                'description' => '',
                'is_available' => '1',
            ],
            [
                'Accept' => 'application/json',
                'Idempotency-Key' => '71000000-0000-4000-8000-000000000011',
            ],
        );

        $response
            ->assertCreated()
            ->assertJsonPath('data.image_url', null);

        $productId = $response->json('data.id');

        $this->assertNull(
            DB::table('products')
                ->where('id', $productId)
                ->value('image_url'),
        );
    }

    public function test_legacy_absolute_product_image_url_is_preserved(): void
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
                'name' => 'Legacy Image Product',
                'category' => 'Electronics',
                'brand' => 'Talbatiyk Test',
                'price' => '150.00',
                'quantity' => '2',
                'description' => '',
                'is_available' => '1',
            ],
            [
                'Accept' => 'application/json',
                'Idempotency-Key' => '71000000-0000-4000-8000-000000000012',
            ],
        );

        $response->assertCreated();

        $productId = $response->json('data.id');

        $legacyUrl =
            'https://legacy.example.test/storage/products/legacy.jpg';

        DB::table('products')
            ->where('id', $productId)
            ->update([
                'image_url' => $legacyUrl,
            ]);

        $this->getJson('/api/v1/products?per_page=100')
            ->assertOk()
            ->assertJsonFragment([
                'id' => $productId,
                'image_url' => $legacyUrl,
            ]);
    }

    public function test_relative_storage_prefixed_image_url_does_not_duplicate_storage_segment(): void
    {
        config([
            'filesystems.disks.public.url' => 'http://127.0.0.1:8000/storage',
        ]);

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
                'name' => 'Storage Prefix Product',
                'category' => 'Electronics',
                'brand' => 'Talbatiyk Test',
                'price' => '175.00',
                'quantity' => '2',
                'description' => '',
                'is_available' => '1',
            ],
            [
                'Accept' => 'application/json',
                'Idempotency-Key' => '71000000-0000-4000-8000-000000000013',
            ],
        );

        $response->assertCreated();

        $productId = $response->json('data.id');

        DB::table('products')
            ->where('id', $productId)
            ->update([
                'image_url' => 'storage/products/example.jpg',
            ]);

        $this->getJson('/api/v1/products?per_page=100')
            ->assertOk()
            ->assertJsonFragment([
                'id' => $productId,
                'image_url' => Storage::disk('public')->url(
                    'products/example.jpg',
                ),
            ]);
    }

    public function test_generated_multipart_boolean_strings_are_normalized_before_validation(): void
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

        $cases = [
            [
                'wire_value' => 'true',
                'expected' => true,
                'name' => 'Multipart Boolean True',
                'key' => '71000000-0000-4000-8000-000000000014',
            ],
            [
                'wire_value' => 'false',
                'expected' => false,
                'name' => 'Multipart Boolean False',
                'key' => '71000000-0000-4000-8000-000000000015',
            ],
        ];

        foreach ($cases as $case) {
            $response = $this->post(
                "/api/v1/businesses/{$business->id}/products",
                [
                    'name' => $case['name'],
                    'category' => 'Electronics',
                    'brand' => 'Talbatiyk Test',
                    'price' => '100.50',
                    'quantity' => '2',
                    'description' => 'Generated-client multipart boolean compatibility.',
                    'is_available' => $case['wire_value'],
                    'image' => UploadedFile::fake()->image(
                        $case['wire_value'].'.jpg',
                        100,
                        100,
                    ),
                ],
                [
                    'Accept' => 'application/json',
                    'Idempotency-Key' => $case['key'],
                ],
            );

            $response
                ->assertCreated()
                ->assertJsonPath(
                    'data.is_available',
                    $case['expected'],
                );

            $productId = $response->json('data.id');

            $this->assertSame(
                $case['expected'],
                (bool) DB::table('products')
                    ->where('id', $productId)
                    ->value('is_available'),
            );
        }
    }

    public function test_invalid_multipart_boolean_string_remains_validation_error(): void
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

        $this->post(
            "/api/v1/businesses/{$business->id}/products",
            [
                'name' => 'Invalid Multipart Boolean',
                'category' => 'Electronics',
                'brand' => 'Talbatiyk Test',
                'price' => '100.50',
                'quantity' => '2',
                'description' => 'Invalid boolean must remain invalid.',
                'is_available' => 'banana',
                'image' => UploadedFile::fake()->image(
                    'invalid-boolean.jpg',
                    100,
                    100,
                ),
            ],
            [
                'Accept' => 'application/json',
                'Idempotency-Key' => '71000000-0000-4000-8000-000000000016',
            ],
        )
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['is_available']);

        $this->assertDatabaseMissing('products', [
            'name' => 'Invalid Multipart Boolean',
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
