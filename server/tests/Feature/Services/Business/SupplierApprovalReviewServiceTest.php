<?php

namespace Tests\Feature\Services\Business;

use App\Models\Business;
use App\Models\User;
use App\Models\Verification;
use App\Services\Business\SupplierApprovalReviewService;
use Database\Seeders\BusinessCapabilitySeeder;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Gate;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Tests\TestCase;

class SupplierApprovalReviewServiceTest extends TestCase
{
    use RefreshDatabase;

    private User $reviewer;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(BusinessCapabilitySeeder::class);

        $this->reviewer = User::factory()->create([
            'status' => 'active',
        ]);

        // Test-only authorization fixture.
        // Production administrator assignment must be independent.
        Gate::define(
            'reviewSupplierApprovals',
            fn (User $user): bool => $user->is($this->reviewer),
        );
    }

    public function test_authorized_approval_activates_supplier_and_records_reviewer(): void
    {
        $request = $this->pendingRequest();

        $this->service()->approve(
            $request->id,
            $this->reviewer,
            'Business documents verified',
        );

        $request->refresh();

        $this->assertSame('approved', $request->status);
        $this->assertSame(
            $this->reviewer->id,
            $request->reviewed_by_user_id,
        );
        $this->assertNotNull($request->reviewed_at);

        $this->assertDatabaseHas('business_capability_assignments', [
            'business_id' => $request->business_id,
            'capability_code' => 'supplier',
            'disabled_at' => null,
        ]);
    }

    public function test_rejection_records_decision_without_supplier_activation(): void
    {
        $request = $this->pendingRequest();

        $this->service()->reject(
            $request->id,
            $this->reviewer,
            'Required information is incomplete',
        );

        $request->refresh();

        $this->assertSame('rejected', $request->status);
        $this->assertSame(
            $this->reviewer->id,
            $request->reviewed_by_user_id,
        );
        $this->assertNotNull($request->reviewed_at);
        $this->assertSame(
            'Required information is incomplete',
            $request->review_note,
        );

        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $request->business_id,
            'capability_code' => 'supplier',
        ]);
    }

    public function test_rejecting_supplier_does_not_disable_existing_shop_capability(): void
    {
        $request = $this->pendingRequest(withShop: true);

        $this->service()->reject(
            $request->id,
            $this->reviewer,
            'Supplier application rejected',
        );

        $this->assertDatabaseHas('business_capability_assignments', [
            'business_id' => $request->business_id,
            'capability_code' => 'shop',
            'disabled_at' => null,
        ]);

        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $request->business_id,
            'capability_code' => 'supplier',
        ]);
    }

    public function test_business_owner_cannot_approve_own_request(): void
    {
        $owner = User::factory()->create();
        $request = $this->pendingRequest($owner);

        try {
            $this->service()->approve(
                $request->id,
                $owner,
                'Self-approval attempt',
            );

            $this->fail('Business owner must not self-approve.');
        } catch (AuthorizationException) {
            // Expected: platform review permission is absent.
        }

        $this->assertSame('pending', $request->fresh()->status);

        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $request->business_id,
            'capability_code' => 'supplier',
        ]);
    }

    public function test_suspended_reviewer_cannot_approve_even_with_review_gate(): void
    {
        $request = $this->pendingRequest();

        $this->reviewer->update([
            'status' => 'suspended',
        ]);

        try {
            $this->service()->approve(
                $request->id,
                $this->reviewer,
                'Suspended reviewer attempt',
            );

            $this->fail('Suspended reviewer must be denied.');
        } catch (AuthorizationException) {
            // Expected.
        }

        $this->assertSame('pending', $request->fresh()->status);
    }

    public function test_approved_request_cannot_be_approved_twice(): void
    {
        $request = $this->pendingRequest();

        $this->service()->approve(
            $request->id,
            $this->reviewer,
            'Approved',
        );

        $this->expectException(ConflictHttpException::class);

        $this->service()->approve(
            $request->id,
            $this->reviewer,
            'Second approval',
        );
    }

    private function service(): SupplierApprovalReviewService
    {
        return app(SupplierApprovalReviewService::class);
    }

    private function pendingRequest(
        ?User $owner = null,
        bool $withShop = false,
    ): Verification {
        $owner ??= User::factory()->create();

        $business = Business::query()->create([
            'name' => 'Review contract business',
            'status' => 'active',
        ]);

        if ($withShop) {
            $business->capabilities()->attach('shop', [
                'enabled_at' => now(),
                'disabled_at' => null,
            ]);
        }

        return $business->verifications()->create([
            'verification_type_code' => 'supplier_approval',
            'requested_by_user_id' => $owner->id,
            'status' => 'pending',
            'requested_at' => now(),
        ]);
    }
}
