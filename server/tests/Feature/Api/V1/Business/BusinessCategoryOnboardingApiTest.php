<?php

namespace Tests\Feature\Api\V1\Business;

use App\Models\Business;
use App\Models\BusinessCategory;
use App\Models\BusinessRole;
use App\Models\User;
use Database\Seeders\BusinessCapabilitySeeder;
use Database\Seeders\BusinessRoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use RuntimeException;
use Tests\TestCase;

class BusinessCategoryOnboardingApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessRoleSeeder::class);
        $this->seed(BusinessCapabilitySeeder::class);
    }

    private function category(
        string $code,
        ?BusinessCategory $parent = null,
        bool $active = true
    ): BusinessCategory {
        return BusinessCategory::query()->create([
            'code' => $code,
            'name_ar' => $code,
            'parent_id' => $parent?->id,
            'is_active' => $active,
            'sort_order' => 0,
        ]);
    }

    private function payload(array $categoryIds): array
    {
        return [
            'name' => 'Category API test business',
            'category_ids' => $categoryIds,
            'capabilities' => ['shop'],
            'location' => [
                'name' => 'Main branch',
                'type' => 'store',
                'timezone' => 'Asia/Aden',
                'country_code' => 'YE',
                'administrative_area' => 'Sanaa',
                'locality' => 'Sanaa',
                'district' => 'Center',
                'street_address' => 'Main street',
                'latitude' => 15.3694,
                'longitude' => 44.1910,
            ],
            'contact' => [
                'type' => 'phone',
                'value' => '+967777123456',
                'label' => 'Sales',
            ],
        ];
    }

    private function login(): void
    {
        Sanctum::actingAs(User::factory()->create());
    }

    private function assertNoBusinessCreated(): void
    {
        $this->assertDatabaseCount('businesses', 0);
        $this->assertDatabaseCount('business_category_assignments', 0);
        $this->assertDatabaseCount('business_locations', 0);
        $this->assertDatabaseCount('business_contacts', 0);
        $this->assertDatabaseCount('business_memberships', 0);
        $this->assertDatabaseCount('business_capability_assignments', 0);
    }

    public function test_active_leaf_is_persisted_once(): void
    {
        $parent = $this->category('api_parent');
        $leaf = $this->category('api_leaf', $parent);

        $this->login();

        $this->postJson('/api/v1/businesses', $this->payload([$leaf->id]))
            ->assertCreated();

        $business = Business::query()->sole();

        $this->assertDatabaseHas('business_category_assignments', [
            'business_id' => $business->id,
            'category_id' => $leaf->id,
        ]);

        $this->assertDatabaseCount('business_category_assignments', 1);

        $this->assertDatabaseMissing('business_category_assignments', [
            'business_id' => $business->id,
            'category_id' => $parent->id,
        ]);
    }

    public function test_multiple_active_leaves_are_persisted(): void
    {
        $first = $this->category('api_first');
        $second = $this->category('api_second');

        $this->login();

        $this->postJson(
            '/api/v1/businesses',
            $this->payload([$first->id, $second->id])
        )->assertCreated();

        $business = Business::query()->sole();

        $this->assertEqualsCanonicalizing(
            [$first->id, $second->id],
            $business->categories()->pluck('business_categories.id')->all()
        );

        $this->assertDatabaseCount('business_category_assignments', 2);
    }

    public function test_missing_categories_are_rejected(): void
    {
        $this->login();

        $payload = $this->payload([]);
        unset($payload['category_ids']);

        $this->postJson('/api/v1/businesses', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['category_ids']);

        $this->assertNoBusinessCreated();
    }

    public function test_empty_categories_are_rejected(): void
    {
        $this->login();

        $this->postJson('/api/v1/businesses', $this->payload([]))
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['category_ids']);

        $this->assertNoBusinessCreated();
    }

    public function test_parent_category_is_rejected(): void
    {
        $parent = $this->category('api_parent');
        $this->category('api_child', $parent);

        $this->login();

        $this->postJson('/api/v1/businesses', $this->payload([$parent->id]))
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['category_ids']);

        $this->assertNoBusinessCreated();
    }

    public function test_inactive_leaf_is_rejected(): void
    {
        $leaf = $this->category('api_inactive', null, false);

        $this->login();

        $this->postJson('/api/v1/businesses', $this->payload([$leaf->id]))
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['category_ids']);

        $this->assertNoBusinessCreated();
    }

    public function test_leaf_with_inactive_ancestor_is_rejected(): void
    {
        $parent = $this->category('api_inactive_parent', null, false);
        $leaf = $this->category('api_active_child', $parent);

        $this->login();

        $this->postJson('/api/v1/businesses', $this->payload([$leaf->id]))
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['category_ids']);

        $this->assertNoBusinessCreated();
    }

    public function test_duplicate_category_is_rejected(): void
    {
        $leaf = $this->category('api_duplicate');

        $this->login();

        $this->postJson(
            '/api/v1/businesses',
            $this->payload([$leaf->id, $leaf->id])
        )
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['category_ids.1']);

        $this->assertNoBusinessCreated();
    }

    public function test_unknown_category_is_rejected(): void
    {
        $this->login();

        $this->postJson(
            '/api/v1/businesses',
            $this->payload(['00000000-0000-4000-8000-000000000001'])
        )
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['category_ids']);

        $this->assertNoBusinessCreated();
    }

    public function test_non_uuid_category_is_rejected(): void
    {
        $this->login();

        $this->postJson(
            '/api/v1/businesses',
            $this->payload(['not-a-uuid'])
        )
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['category_ids.0']);

        $this->assertNoBusinessCreated();
    }

    public function test_category_assignment_rolls_back_on_owner_failure(): void
    {
        $leaf = $this->category('api_rollback');

        BusinessRole::query()->where('code', 'owner')->delete();

        $this->login();
        $this->withoutExceptionHandling();

        try {
            $this->postJson(
                '/api/v1/businesses',
                $this->payload([$leaf->id])
            );

            $this->fail('Expected owner role configuration failure.');
        } catch (RuntimeException $exception) {
            $this->assertSame(
                'The required business owner role is not configured.',
                $exception->getMessage()
            );
        }

        $this->assertNoBusinessCreated();
    }
}