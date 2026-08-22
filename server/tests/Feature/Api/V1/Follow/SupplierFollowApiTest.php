<?php

namespace Tests\Feature\Api\V1\Follow;

use App\Models\Business;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SupplierFollowApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_cannot_read_follow_status(): void
    {
        $supplier = $this->supplier();

        $this->getJson(
            "/api/v1/businesses/{$supplier->id}/follow"
        )->assertUnauthorized();
    }

    public function test_suspended_user_cannot_follow_supplier(): void
    {
        $this->authenticatedUser('suspended');

        $supplier = $this->supplier();

        $response = $this->postJson(
            "/api/v1/businesses/{$supplier->id}/follow"
        );

        $this->assertContains(
            $response->status(),
            [401, 403],
        );

        $this->assertDatabaseMissing('business_follows', [
            'business_id' => $supplier->id,
        ]);
    }

    public function test_follow_status_is_false_before_following(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier();

        $this->getJson(
            "/api/v1/businesses/{$supplier->id}/follow"
        )
            ->assertOk()
            ->assertJsonPath('data.business_id', $supplier->id)
            ->assertJsonPath('data.is_following', false);
    }

    public function test_active_user_can_follow_supplier(): void
    {
        $user = $this->authenticatedUser();

        $supplier = $this->supplier();

        $this->postJson(
            "/api/v1/businesses/{$supplier->id}/follow"
        )
            ->assertOk()
            ->assertJsonPath('data.business_id', $supplier->id)
            ->assertJsonPath('data.is_following', true);

        $this->assertDatabaseHas('business_follows', [
            'user_id' => $user->id,
            'business_id' => $supplier->id,
        ]);
    }

    public function test_duplicate_follow_is_idempotent(): void
    {
        $user = $this->authenticatedUser();

        $supplier = $this->supplier();

        $url = "/api/v1/businesses/{$supplier->id}/follow";

        $this->postJson($url)
            ->assertOk()
            ->assertJsonPath('data.is_following', true);

        $this->postJson($url)
            ->assertOk()
            ->assertJsonPath('data.is_following', true);

        $this->assertSame(
            1,
            DB::table('business_follows')
                ->where('user_id', $user->id)
                ->where('business_id', $supplier->id)
                ->count(),
        );
    }

    public function test_active_user_can_unfollow_supplier(): void
    {
        $user = $this->authenticatedUser();

        $supplier = $this->supplier();

        $url = "/api/v1/businesses/{$supplier->id}/follow";

        $this->postJson($url)->assertOk();

        $this->deleteJson($url)
            ->assertOk()
            ->assertJsonPath('data.business_id', $supplier->id)
            ->assertJsonPath('data.is_following', false);

        $this->assertDatabaseMissing('business_follows', [
            'user_id' => $user->id,
            'business_id' => $supplier->id,
        ]);
    }

    public function test_duplicate_unfollow_is_idempotent(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier();

        $url = "/api/v1/businesses/{$supplier->id}/follow";

        $this->deleteJson($url)
            ->assertOk()
            ->assertJsonPath('data.is_following', false);

        $this->deleteJson($url)
            ->assertOk()
            ->assertJsonPath('data.is_following', false);
    }

    public function test_suspended_supplier_cannot_be_followed(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier(status: 'suspended');

        $this->postJson(
            "/api/v1/businesses/{$supplier->id}/follow"
        )
            ->assertUnprocessable()
            ->assertJsonValidationErrors('business_id');
    }

    public function test_closed_supplier_cannot_be_followed(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier(status: 'closed');

        $this->postJson(
            "/api/v1/businesses/{$supplier->id}/follow"
        )
            ->assertUnprocessable()
            ->assertJsonValidationErrors('business_id');
    }

    public function test_disabled_supplier_capability_cannot_be_followed(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier(disabled: true);

        $this->postJson(
            "/api/v1/businesses/{$supplier->id}/follow"
        )
            ->assertUnprocessable()
            ->assertJsonValidationErrors('business_id');
    }

    public function test_retired_supplier_capability_cannot_be_followed(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier(retired: true);

        $this->postJson(
            "/api/v1/businesses/{$supplier->id}/follow"
        )
            ->assertUnprocessable()
            ->assertJsonValidationErrors('business_id');
    }

    public function test_business_without_supplier_capability_cannot_be_followed(): void
    {
        $this->authenticatedUser();

        $business = Business::query()->create([
            'name' => 'Non Supplier Business',
            'status' => 'active',
        ]);

        $this->postJson(
            "/api/v1/businesses/{$business->id}/follow"
        )
            ->assertUnprocessable()
            ->assertJsonValidationErrors('business_id');
    }

    public function test_soft_deleted_business_returns_not_found(): void
    {
        $this->authenticatedUser();

        $supplier = $this->supplier();

        $supplier->delete();

        $this->postJson(
            "/api/v1/businesses/{$supplier->id}/follow"
        )->assertNotFound();
    }

    private function authenticatedUser(
        string $status = 'active',
    ): User {
        $user = User::factory()->create([
            'status' => $status,
        ]);

        Sanctum::actingAs($user);

        return $user;
    }

    /**
     * ينشئ Supplier مطابقًا لقواعد Product Discovery وFollow Service.
     */
    private function supplier(
        string $status = 'active',
        bool $disabled = false,
        bool $retired = false,
    ): Business {
        $business = Business::query()->create([
            'name' => 'Gate 2.3 Supplier',
            'status' => $status,
        ]);

        DB::table('business_capabilities')->updateOrInsert(
            ['code' => 'supplier'],
            [
                'retired_at' => $retired ? now() : null,
            ],
        );

        $enabledAt = now();

        DB::table('business_capability_assignments')->insert([
            'business_id' => $business->id,
            'capability_code' => 'supplier',
            'enabled_at' => $enabledAt,
            'disabled_at' => $disabled ? $enabledAt : null,
        ]);

        return $business;
    }
}
