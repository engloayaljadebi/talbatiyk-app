<?php

namespace Tests\Feature\Api\V1\Platform;

use App\Models\Business;
use App\Models\User;
use App\Models\Verification;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class SupplierApprovalAdminApiTest extends TestCase
{
    use RefreshDatabase;

    private const BASE = '/api/v1/platform/supplier-approvals';

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_guest_cannot_read_supplier_approval_queue(): void
    {
        $this->getJson(self::BASE)
            ->assertUnauthorized();
    }

    public function test_ordinary_user_cannot_read_supplier_approval_queue(): void
    {
        Sanctum::actingAs(
            User::factory()->create(['status' => 'active']),
        );

        $this->getJson(self::BASE)
            ->assertForbidden();
    }

    public function test_platform_admin_sees_only_pending_supplier_requests(): void
    {
        $admin = User::factory()->create(['status' => 'active']);
        $requester = User::factory()->create(['status' => 'active']);

        $this->grantPlatformAdmin($admin);

        $pending = $this->pendingSupplierRequest($requester);
        $rejected = $this->pendingSupplierRequest($requester);

        $rejected->update([
            'status' => 'rejected',
            'reviewed_by_user_id' => $admin->id,
            'reviewed_at' => now(),
            'review_note' => 'Previously rejected',
        ]);

        Sanctum::actingAs($admin);

        $this->getJson(self::BASE)
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $pending->id)
            ->assertJsonPath('data.0.status', 'pending')
            ->assertJsonMissing([
                'id' => $rejected->id,
            ]);
    }

    public function test_suspended_platform_admin_cannot_read_queue(): void
    {
        $admin = User::factory()->create(['status' => 'active']);

        $this->grantPlatformAdmin($admin);
        $admin->update(['status' => 'suspended']);

        Sanctum::actingAs($admin->fresh());

        $this->getJson(self::BASE)
            ->assertForbidden();
    }

    public function test_ordinary_user_cannot_approve_supplier_request(): void
    {
        $requester = User::factory()->create(['status' => 'active']);
        $ordinary = User::factory()->create(['status' => 'active']);

        $verification = $this->pendingSupplierRequest($requester);

        Sanctum::actingAs($ordinary);

        $this->postJson(
            self::BASE."/{$verification->id}/approve",
            ['review_note' => 'Unauthorized decision'],
        )->assertForbidden();

        $this->assertSame(
            'pending',
            $verification->fresh()->status,
        );
    }

    public function test_platform_admin_can_approve_pending_supplier_request(): void
    {
        $admin = User::factory()->create(['status' => 'active']);
        $requester = User::factory()->create(['status' => 'active']);

        $this->grantPlatformAdmin($admin);

        $verification = $this->pendingSupplierRequest($requester);

        Sanctum::actingAs($admin);

        $this->postJson(
            self::BASE."/{$verification->id}/approve",
            ['review_note' => 'Supplier approved by platform'],
        )
            ->assertOk()
            ->assertJsonPath('data.id', $verification->id)
            ->assertJsonPath('data.status', 'approved');

        $this->assertDatabaseHas('verifications', [
            'id' => $verification->id,
            'status' => 'approved',
            'reviewed_by_user_id' => $admin->id,
            'review_note' => 'Supplier approved by platform',
        ]);

        $this->assertDatabaseHas('business_capability_assignments', [
            'business_id' => $verification->business_id,
            'capability_code' => 'supplier',
            'disabled_at' => null,
        ]);
    }

    public function test_platform_admin_can_reject_supplier_request(): void
    {
        $admin = User::factory()->create(['status' => 'active']);
        $requester = User::factory()->create(['status' => 'active']);

        $this->grantPlatformAdmin($admin);

        $verification = $this->pendingSupplierRequest($requester);

        Sanctum::actingAs($admin);

        $this->postJson(
            self::BASE."/{$verification->id}/reject",
            ['review_note' => 'Submitted documents are incomplete'],
        )
            ->assertOk()
            ->assertJsonPath('data.id', $verification->id)
            ->assertJsonPath('data.status', 'rejected');

        $this->assertDatabaseHas('verifications', [
            'id' => $verification->id,
            'status' => 'rejected',
            'reviewed_by_user_id' => $admin->id,
            'review_note' => 'Submitted documents are incomplete',
        ]);

        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $verification->business_id,
            'capability_code' => 'supplier',
        ]);
    }

    public function test_reviewing_the_same_request_twice_returns_conflict(): void
    {
        $admin = User::factory()->create(['status' => 'active']);
        $requester = User::factory()->create(['status' => 'active']);

        $this->grantPlatformAdmin($admin);

        $verification = $this->pendingSupplierRequest($requester);

        Sanctum::actingAs($admin);

        $this->postJson(
            self::BASE."/{$verification->id}/approve",
            ['review_note' => 'First approval'],
        )->assertOk();

        $this->postJson(
            self::BASE."/{$verification->id}/approve",
            ['review_note' => 'Repeated approval'],
        )->assertStatus(409);

        $this->assertDatabaseHas('verifications', [
            'id' => $verification->id,
            'status' => 'approved',
            'review_note' => 'First approval',
        ]);
    }

    public function test_rejection_without_reason_is_validation_error(): void
    {
        $admin = User::factory()->create(['status' => 'active']);
        $requester = User::factory()->create(['status' => 'active']);

        $this->grantPlatformAdmin($admin);

        $verification = $this->pendingSupplierRequest($requester);

        Sanctum::actingAs($admin);

        $this->postJson(
            self::BASE."/{$verification->id}/reject",
            ['review_note' => ''],
        )->assertUnprocessable();

        $this->assertSame(
            'pending',
            $verification->fresh()->status,
        );
    }

    public function test_admin_cannot_approve_request_from_own_business(): void
    {
        $admin = User::factory()->create(['status' => 'active']);
        $requester = User::factory()->create(['status' => 'active']);

        $this->grantPlatformAdmin($admin);

        $verification = $this->pendingSupplierRequest($requester);

        Business::query()
            ->findOrFail($verification->business_id)
            ->memberships()
            ->create([
                'user_id' => $admin->id,
                'status' => 'active',
                'joined_at' => now(),
            ]);

        Sanctum::actingAs($admin);

        $this->postJson(
            self::BASE."/{$verification->id}/approve",
            ['review_note' => 'Conflicted approval'],
        )->assertForbidden();

        $this->assertSame(
            'pending',
            $verification->fresh()->status,
        );

        $this->assertDatabaseMissing(
            'business_capability_assignments',
            [
                'business_id' => $verification->business_id,
                'capability_code' => 'supplier',
            ],
        );
    }

    private function grantPlatformAdmin(User $user): void
    {
        // Test-only role fixture; not a public API.
        DB::table('platform_role_assignments')->insert([
            'user_id' => $user->id,
            'role_code' => 'platform_admin',
            'granted_by_user_id' => null,
            'granted_at' => now(),
            'revoked_at' => null,
        ]);
    }

    private function pendingSupplierRequest(User $requester): Verification
    {
        $business = Business::query()->create([
            'name' => 'Supplier approval contract business',
            'status' => 'active',
        ]);

        return $business->verifications()->create([
            'verification_type_code' => 'supplier_approval',
            'requested_by_user_id' => $requester->id,
            'status' => 'pending',
            'requested_at' => now(),
        ]);
    }
}
