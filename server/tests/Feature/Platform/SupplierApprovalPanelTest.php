<?php

namespace Tests\Feature\Platform;

use App\Filament\Resources\Verifications\Pages\ManageVerifications;
use App\Filament\Resources\Verifications\VerificationResource;
use App\Models\Business;
use App\Models\User;
use App\Models\Verification;
use App\Models\VerificationType;
use App\Services\Business\SupplierApprovalReviewService;
use Database\Seeders\BusinessCapabilitySeeder;
use Filament\Actions\Testing\TestAction;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Livewire\Livewire;
use Tests\TestCase;

class SupplierApprovalPanelTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Filament::setCurrentPanel(Filament::getPanel('admin'));
        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_regular_user_cannot_open_review_screen(): void
    {
        $user = User::factory()->create(['status' => 'active']);

        $this->actingAs($user, 'web')
            ->get(VerificationResource::getUrl())
            ->assertForbidden();
    }

    public function test_screen_only_lists_supplier_approval_requests(): void
    {
        $this->loginAdmin();
        $application = $this->application();

        VerificationType::query()->firstOrCreate([
            'code' => 'identity',
        ], [
            'subject_kind' => 'user',
        ]);

        $other = Verification::create([
            'verification_type_code' => 'identity',
            'user_id' => User::factory()->create()->id,
            'status' => 'pending',
            'requested_at' => now(),
        ]);

        Livewire::test(ManageVerifications::class)
            ->assertSuccessful()
            ->assertCanSeeTableRecords([$application])
            ->assertCanNotSeeTableRecords([$other])
            ->assertActionDoesNotExist('create')
            ->assertActionDoesNotExist(TestAction::make('edit')->table($application))
            ->assertActionDoesNotExist(TestAction::make('delete')->table($application))
            ->mountAction(TestAction::make('view')->table($application))
            ->assertSee('Panel test business');
    }

    public function test_approval_activates_supplier_and_records_reviewer(): void
    {
        $admin = $this->loginAdmin();
        $application = $this->application();

        Livewire::test(ManageVerifications::class)
            ->callAction(
                TestAction::make('approve')->table($application),
                data: ['review_note' => 'Checked'],
            )
            ->assertHasNoActionErrors();

        $this->assertDatabaseHas('verifications', [
            'id' => $application->id,
            'status' => 'approved',
            'reviewed_by_user_id' => $admin->id,
            'review_note' => 'Checked',
        ]);
        $this->assertNotNull($application->refresh()->reviewed_at);
        $this->assertDatabaseHas('business_capability_assignments', [
            'business_id' => $application->business_id,
            'capability_code' => 'supplier',
            'disabled_at' => null,
        ]);
    }

    public function test_rejection_requires_a_reason(): void
    {
        $this->loginAdmin();
        $application = $this->application();

        Livewire::test(ManageVerifications::class)
            ->callAction(
                TestAction::make('reject')->table($application),
                data: ['review_note' => ''],
            )
            ->assertHasActionErrors(['review_note' => 'required']);

        $this->assertSame('pending', $application->refresh()->status);
    }

    public function test_rejection_does_not_activate_supplier(): void
    {
        $admin = $this->loginAdmin();
        $application = $this->application();

        Livewire::test(ManageVerifications::class)
            ->callAction(
                TestAction::make('reject')->table($application),
                data: ['review_note' => 'Incomplete business details'],
            )
            ->assertHasNoActionErrors();

        $this->assertDatabaseHas('verifications', [
            'id' => $application->id,
            'status' => 'rejected',
            'reviewed_by_user_id' => $admin->id,
            'review_note' => 'Incomplete business details',
        ]);
        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $application->business_id,
            'capability_code' => 'supplier',
        ]);
    }

    public function test_reviewed_request_has_no_decision_buttons(): void
    {
        $admin = $this->loginAdmin();
        $application = $this->application();
        $application->update([
            'status' => 'rejected',
            'reviewed_by_user_id' => $admin->id,
            'reviewed_at' => now(),
            'review_note' => 'Already reviewed',
        ]);

        Livewire::test(ManageVerifications::class)
            ->assertActionHidden(TestAction::make('approve')->table($application))
            ->assertActionHidden(TestAction::make('reject')->table($application));
    }

    public function test_admin_cannot_approve_own_application(): void
    {
        $admin = $this->loginAdmin();
        $application = $this->application();
        $application->update(['requested_by_user_id' => $admin->id]);

        Livewire::test(ManageVerifications::class)
            ->callAction(
                TestAction::make('approve')->table($application),
                data: ['review_note' => 'Self review attempt'],
            )
            ->assertForbidden();

        $this->assertSame('pending', $application->refresh()->status);
        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $application->business_id,
            'capability_code' => 'supplier',
        ]);
    }

    public function test_revoked_admin_cannot_submit_an_open_decision(): void
    {
        $admin = $this->loginAdmin();
        $application = $this->application();

        $component = Livewire::test(ManageVerifications::class)
            ->mountAction(TestAction::make('approve')->table($application));

        DB::table('platform_role_assignments')
            ->where('user_id', $admin->id)
            ->update(['revoked_at' => now()]);

        $component->callMountedAction()->assertForbidden();

        $this->assertSame('pending', $application->refresh()->status);
        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $application->business_id,
            'capability_code' => 'supplier',
        ]);
    }

    public function test_stale_approval_cannot_overwrite_another_review(): void
    {
        $this->loginAdmin();
        $application = $this->application();

        $component = Livewire::test(ManageVerifications::class)
            ->mountAction(TestAction::make('approve')->table($application));

        $otherAdmin = User::factory()->create(['status' => 'active']);
        DB::table('platform_role_assignments')->insert([
            'user_id' => $otherAdmin->id,
            'role_code' => 'platform_admin',
            'granted_at' => now()->subMinute(),
        ]);

        app(SupplierApprovalReviewService::class)
            ->reject($application->id, $otherAdmin, 'Reviewed elsewhere');

        $component->callMountedAction();

        $this->assertDatabaseHas('verifications', [
            'id' => $application->id,
            'status' => 'rejected',
            'reviewed_by_user_id' => $otherAdmin->id,
            'review_note' => 'Reviewed elsewhere',
        ]);
        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $application->business_id,
            'capability_code' => 'supplier',
        ]);
    }

    private function loginAdmin(): User
    {
        $admin = User::factory()->create(['status' => 'active']);

        DB::table('platform_role_assignments')->insert([
            'user_id' => $admin->id,
            'role_code' => 'platform_admin',
            'granted_at' => now()->subMinute(),
        ]);

        $this->actingAs($admin, 'web');

        return $admin;
    }

    private function application(): Verification
    {
        $business = Business::create([
            'name' => 'Panel test business',
            'status' => 'active',
        ]);

        return Verification::create([
            'verification_type_code' => 'supplier_approval',
            'business_id' => $business->id,
            'requested_by_user_id' => User::factory()->create([
                'status' => 'active',
            ])->id,
            'status' => 'pending',
            'requested_at' => now(),
        ]);
    }
}
