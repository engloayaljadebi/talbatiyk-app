<?php

namespace Tests\Feature\Platform;

use App\Models\Business;
use App\Models\User;
use App\Models\Verification;
use App\Services\Business\SupplierApprovalReviewService;
use Database\Seeders\BusinessCapabilitySeeder;
use Database\Seeders\BusinessRoleSeeder;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Tests\TestCase;

class PlatformSupplierApprovalAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);
        $this->seed(BusinessRoleSeeder::class);
    }

    public function test_business_owner_has_no_platform_review_permission(): void
    {
        $owner = User::factory()->create(['status' => 'active']);

        $business = Business::query()->create([
            'name' => 'Ordinary owner business',
            'status' => 'active',
        ]);

        $membership = $business->memberships()->create([
            'user_id' => $owner->id,
            'status' => 'active',
        ]);

        $membership->roles()->attach('owner', [
            'assigned_by_membership_id' => null,
            'assigned_at' => now(),
        ]);

        $this->assertFalse(
            Gate::forUser($owner)->allows('reviewSupplierApprovals'),
        );
    }

    public function test_active_platform_admin_has_supplier_review_permission(): void
    {
        $admin = User::factory()->create(['status' => 'active']);
        $this->grantPlatformAdmin($admin);

        $this->assertTrue(
            Gate::forUser($admin)->allows('reviewSupplierApprovals'),
        );
    }

    public function test_suspended_platform_admin_loses_review_permission(): void
    {
        $admin = User::factory()->create(['status' => 'active']);
        $this->grantPlatformAdmin($admin);

        $admin->update(['status' => 'suspended']);

        $this->assertFalse(
            Gate::forUser($admin->fresh())->allows(
                'reviewSupplierApprovals',
            ),
        );
    }

    public function test_revoked_platform_admin_loses_review_permission(): void
    {
        $admin = User::factory()->create(['status' => 'active']);
        $this->grantPlatformAdmin($admin);

        DB::table('platform_role_assignments')
            ->where('user_id', $admin->id)
            ->where('role_code', 'platform_admin')
            ->update(['revoked_at' => now()]);

        $this->assertFalse(
            Gate::forUser($admin)->allows('reviewSupplierApprovals'),
        );
    }

    public function test_platform_admin_can_approve_another_users_supplier(): void
    {
        $admin = User::factory()->create(['status' => 'active']);
        $owner = User::factory()->create(['status' => 'active']);

        $this->grantPlatformAdmin($admin);

        $verification = $this->pendingRequest($owner);

        app(SupplierApprovalReviewService::class)->approve(
            $verification->id,
            $admin,
            'Approved by platform administrator',
        );

        $this->assertSame(
            'approved',
            $verification->fresh()->status,
        );

        $this->assertDatabaseHas('business_capability_assignments', [
            'business_id' => $verification->business_id,
            'capability_code' => 'supplier',
            'disabled_at' => null,
        ]);
    }

    public function test_platform_admin_cannot_approve_own_supplier_request(): void
    {
        $admin = User::factory()->create(['status' => 'active']);

        $this->grantPlatformAdmin($admin);

        $verification = $this->pendingRequest($admin);

        try {
            app(SupplierApprovalReviewService::class)->approve(
                $verification->id,
                $admin,
                'Attempted self-approval',
            );

            $this->fail('Platform admin must not self-approve.');
        } catch (AuthorizationException) {
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
    }

    /**
     * A platform reviewer must not approve a business in which
     * they have an active membership, even when another user applied.
     */
    public function test_platform_admin_cannot_review_business_with_active_membership(): void
    {
        foreach (['owner', 'staff'] as $roleCode) {
            $admin = User::factory()->create(['status' => 'active']);
            $requester = User::factory()->create(['status' => 'active']);

            $this->grantPlatformAdmin($admin);

            $verification = $this->pendingRequest($requester);

            $business = Business::query()
                ->findOrFail($verification->business_id);

            $membership = $business->memberships()->create([
                'user_id' => $admin->id,
                'status' => 'active',
                'joined_at' => now(),
            ]);

            $membership->roles()->attach($roleCode, [
                'assigned_by_membership_id' => null,
                'assigned_at' => now(),
            ]);

            try {
                app(SupplierApprovalReviewService::class)->approve(
                    $verification->id,
                    $admin,
                    'Conflict-of-interest attempt',
                );

                $this->fail(
                    'Platform reviewer with business membership was allowed: '.$roleCode,
                );
            } catch (AuthorizationException) {
                // Expected authorization denial.
            }

            $this->assertSame(
                'pending',
                $verification->fresh()->status,
            );

            $this->assertDatabaseMissing(
                'business_capability_assignments',
                [
                    'business_id' => $business->id,
                    'capability_code' => 'supplier',
                ],
            );
        }
    }

    public function test_platform_admin_cannot_reject_business_with_active_membership(): void
    {
        $admin = User::factory()->create(['status' => 'active']);
        $requester = User::factory()->create(['status' => 'active']);

        $this->grantPlatformAdmin($admin);

        $verification = $this->pendingRequest($requester);

        $business = Business::query()
            ->findOrFail($verification->business_id);

        $business->memberships()->create([
            'user_id' => $admin->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        try {
            app(SupplierApprovalReviewService::class)->reject(
                $verification->id,
                $admin,
                'Attempted conflicted rejection',
            );

            $this->fail('Conflicted reviewer was allowed to reject.');
        } catch (AuthorizationException) {
            // Expected.
        }

        $this->assertSame(
            'pending',
            $verification->fresh()->status,
        );

        $this->assertDatabaseMissing(
            'business_capability_assignments',
            [
                'business_id' => $business->id,
                'capability_code' => 'supplier',
            ],
        );
    }

    private function grantPlatformAdmin(User $user): void
    {
        // Direct test fixture only. There must be no public grant API.
        DB::table('platform_role_assignments')->insert([
            'user_id' => $user->id,
            'role_code' => 'platform_admin',
            'granted_by_user_id' => null,
            'granted_at' => now(),
            'revoked_at' => null,
        ]);
    }

    private function pendingRequest(User $owner): Verification
    {
        $business = Business::query()->create([
            'name' => 'Platform approval contract business',
            'status' => 'active',
        ]);

        return $business->verifications()->create([
            'verification_type_code' => 'supplier_approval',
            'requested_by_user_id' => $owner->id,
            'status' => 'pending',
            'requested_at' => now(),
        ]);
    }
}
