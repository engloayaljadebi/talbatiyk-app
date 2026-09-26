<?php

namespace Tests\Feature\Api\V1\Product;

use App\Models\Business;
use App\Models\BusinessMembership;
use App\Models\Product;
use App\Models\User;
use App\Services\Product\ProductPublishingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProductPublishingIdempotencyApiTest extends TestCase
{
    use RefreshDatabase;

    private const IDEMPOTENCY_KEY =
        '72000000-0000-4000-8000-000000000001';

    public function test_idempotency_key_is_required(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            $user,
        );

        Sanctum::actingAs($user);

        $this->postJson(
            "/api/v1/businesses/{$business->id}/products",
            $this->productPayload(),
        )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'Idempotency-Key',
            ]);

        $this->assertDatabaseCount(
            'products',
            0,
        );
    }

    public function test_idempotency_key_must_be_valid_uuid(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            $user,
        );

        Sanctum::actingAs($user);

        $this
            ->withHeader(
                'Idempotency-Key',
                'not-a-valid-uuid',
            )
            ->postJson(
                "/api/v1/businesses/{$business->id}/products",
                $this->productPayload(),
            )
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'Idempotency-Key',
            ]);

        $this->assertDatabaseCount(
            'products',
            0,
        );
    }

    public function test_same_key_and_payload_returns_same_product(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            $user,
        );

        Sanctum::actingAs($user);

        $payload = $this->productPayload();

        $first = $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                "/api/v1/businesses/{$business->id}/products",
                $payload,
            )
            ->assertCreated();

        $second = $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                "/api/v1/businesses/{$business->id}/products",
                $payload,
            )
            ->assertCreated();

        $this->assertSame(
            $first->json('data.id'),
            $second->json('data.id'),
        );

        $this->assertDatabaseCount(
            'products',
            1,
        );

        $product = Product::query()->firstOrFail();

        $this->assertSame(
            self::IDEMPOTENCY_KEY,
            $product->idempotency_key,
        );

        $this->assertIsString(
            $product->idempotency_payload_hash,
        );

        $this->assertSame(
            64,
            strlen(
                $product->idempotency_payload_hash,
            ),
        );
    }

    public function test_same_key_different_payload_returns_409(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            $user,
        );

        Sanctum::actingAs($user);

        $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                "/api/v1/businesses/{$business->id}/products",
                $this->productPayload(),
            )
            ->assertCreated();

        $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                "/api/v1/businesses/{$business->id}/products",
                $this->productPayload([
                    'quantity' => 999,
                ]),
            )
            ->assertStatus(409);

        $this->assertDatabaseCount(
            'products',
            1,
        );

        $this->assertDatabaseHas(
            'products',
            [
                'supplier_id' => $business->id,
                'idempotency_key' => self::IDEMPOTENCY_KEY,
                'quantity' => 8,
            ],
        );
    }

    public function test_same_key_is_scoped_per_supplier(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $supplierA = $this->supplierBusinessFor(
            $user,
            'Supplier A',
        );

        $supplierB = $this->supplierBusinessFor(
            $user,
            'Supplier B',
        );

        Sanctum::actingAs($user);

        $first = $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                "/api/v1/businesses/{$supplierA->id}/products",
                $this->productPayload(),
            )
            ->assertCreated();

        $second = $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                "/api/v1/businesses/{$supplierB->id}/products",
                $this->productPayload(),
            )
            ->assertCreated();

        $this->assertNotSame(
            $first->json('data.id'),
            $second->json('data.id'),
        );

        $this->assertDatabaseCount(
            'products',
            2,
        );
    }

    public function test_image_content_is_part_of_payload_fingerprint(): void
    {
        Storage::fake('public');

        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            $user,
        );

        Sanctum::actingAs($user);

        $firstPayload = $this->productPayload([
            'image' => UploadedFile::fake()->image(
                'first.jpg',
                600,
                600,
            ),
        ]);

        $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->post(
                "/api/v1/businesses/{$business->id}/products",
                $firstPayload,
                [
                    'Accept' => 'application/json',
                ],
            )
            ->assertCreated();

        $secondPayload = $this->productPayload([
            'image' => UploadedFile::fake()->image(
                'second.jpg',
                900,
                900,
            ),
        ]);

        $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->post(
                "/api/v1/businesses/{$business->id}/products",
                $secondPayload,
                [
                    'Accept' => 'application/json',
                ],
            )
            ->assertStatus(409);

        $this->assertDatabaseCount(
            'products',
            1,
        );

        /*
         * Conflicting retry is rejected before it can store another image.
         */
        $files = Storage::disk('public')->allFiles(
            "products/{$business->id}/idempotency/".
            self::IDEMPOTENCY_KEY,
        );

        $this->assertCount(
            1,
            $files,
        );
    }

    public function test_idempotent_replay_requires_current_supplier_capability(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            $user,
        );

        Sanctum::actingAs($user);

        $payload = $this->productPayload();

        $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                "/api/v1/businesses/{$business->id}/products",
                $payload,
            )
            ->assertCreated();

        DB::table(
            'business_capability_assignments',
        )
            ->where(
                'business_id',
                $business->id,
            )
            ->where(
                'capability_code',
                'supplier',
            )
            ->update([
                'disabled_at' => now(),
            ]);

        $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                "/api/v1/businesses/{$business->id}/products",
                $payload,
            )
            ->assertForbidden();

        $this->assertDatabaseCount(
            'products',
            1,
        );
    }

    public function test_image_is_cleaned_when_storage_writes_then_publish_fails(): void
    {
        Storage::fake('public');

        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            $user,
        );

        $baseImage = UploadedFile::fake()->image(
            'post-write-failure.jpg',
            600,
            600,
        );

        $image =
            new ProductPublishingPostWriteFailureUploadedFile(
                $baseImage->getPathname(),
                $baseImage->getClientOriginalName(),
                $baseImage->getClientMimeType(),
                $baseImage->getError(),
                true,
            );

        $caught = null;

        try {
            app(
                ProductPublishingService::class,
            )->publish(
                $user,
                (string) $business->id,
                $this->productPayload([
                    'image' => $image,
                ]),
                self::IDEMPOTENCY_KEY,
            );
        } catch (\RuntimeException $exception) {
            $caught = $exception;
        }

        $this->assertNotNull(
            $caught,
            'Expected the simulated post-write storage failure.',
        );

        $this->assertSame(
            'تعذر حفظ صورة المنتج.',
            $caught->getMessage(),
        );

        /*
         * DB transaction must be rolled back.
         */
        $this->assertDatabaseCount(
            'products',
            0,
        );

        /*
         * The physical file was written before the simulated error,
         * so the compensating cleanup must remove it.
         */
        $files = Storage::disk('public')->allFiles(
            "products/{$business->id}/idempotency/".
            self::IDEMPOTENCY_KEY,
        );

        $this->assertCount(
            0,
            $files,
        );
    }

    public function test_soft_deleted_product_key_returns_conflict_without_duplicate(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->supplierBusinessFor(
            $user,
        );

        Sanctum::actingAs($user);

        $first = $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                "/api/v1/businesses/{$business->id}/products",
                $this->productPayload(),
            )
            ->assertCreated();

        $productId = $first->json(
            'data.id',
        );

        Product::query()
            ->findOrFail($productId)
            ->delete();

        $this
            ->withHeader(
                'Idempotency-Key',
                self::IDEMPOTENCY_KEY,
            )
            ->postJson(
                "/api/v1/businesses/{$business->id}/products",
                $this->productPayload(),
            )
            ->assertStatus(409);

        $this->assertSame(
            1,
            Product::query()
                ->withTrashed()
                ->count(),
        );
    }

    private function productPayload(
        array $overrides = [],
    ): array {
        return array_merge(
            [
                'name' => 'Idempotent Product',
                'category' => 'Electronics',
                'brand' => 'Talbatiyk',
                'price' => 1250.50,
                'quantity' => 8,
                'description' => 'Stable logical product publication.',
                'is_available' => true,
            ],
            $overrides,
        );
    }

    private function supplierBusinessFor(
        User $user,
        string $name = 'Idempotency Supplier',
    ): Business {
        DB::table(
            'business_roles',
        )->updateOrInsert(
            [
                'code' => 'owner',
            ],
            [
                'is_active' => true,
            ],
        );

        DB::table(
            'business_capabilities',
        )->updateOrInsert(
            [
                'code' => 'supplier',
            ],
            [
                'retired_at' => null,
            ],
        );

        $business = Business::query()->create([
            'name' => $name,
            'status' => 'active',
        ]);

        $membership =
            BusinessMembership::query()->create([
                'user_id' => $user->id,
                'business_id' => $business->id,
                'status' => 'active',
                'joined_at' => now(),
            ]);

        $membership->roles()->attach(
            'owner',
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

final class ProductPublishingPostWriteFailureUploadedFile extends UploadedFile
{
    public function storePubliclyAs(
        $path,
        $name = null,
        $options = [],
    ) {
        parent::storePubliclyAs(
            $path,
            $name,
            $options,
        );

        throw new \RuntimeException(
            'Simulated failure after physical image write.',
        );
    }
}
