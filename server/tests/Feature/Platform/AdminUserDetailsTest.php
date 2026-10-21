<?php

declare(strict_types=1);

namespace Tests\Feature\Platform;

use App\Filament\Resources\Users\Pages\ManageUsers;
use App\Filament\Resources\Users\UserResource;
use App\Models\User;
use Filament\Actions\Testing\TestAction;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Livewire\Livewire;
use Tests\TestCase;

final class AdminUserDetailsTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();

        $actual = DB::selectOne(
            'SELECT current_database() AS name'
        )->name;

        if (
            DB::connection()->getDatabaseName() !== 'talbatiyk_testing'
            || $actual !== 'talbatiyk_testing'
        ) {
            throw new \RuntimeException('Unsafe test database.');
        }

        Filament::setCurrentPanel(
            Filament::getPanel('admin')
        );
    }

    public function test_admin_can_view_user_details(): void
    {
        $this->loginAdmin();

        $target = User::factory()->create([
            'username' => 'user_details_target',
            'display_name' => 'User Details Target',
            'status' => 'active',
        ]);

        $target->contacts()->create([
            'type' => 'email',
            'value' => 'details-target@example.com',
            'is_primary' => true,
            'verified_at' => null,
        ]);

        $target->profile()->create([
            'nationality_country_code' => 'YE',
            'birth_date' => '2001-01-15',
        ]);

        Livewire::test(ManageUsers::class)
            ->assertSuccessful()
            ->assertCanSeeTableRecords([$target])
            ->assertActionExists(
                TestAction::make('view')->table($target)
            )
            ->mountAction(
                TestAction::make('view')->table($target)
            )
            ->assertMountedActionModalSee('details-target@example.com')
            ->assertMountedActionModalSee('YE')
            ->assertMountedActionModalSee('2001-01-15')
            ->assertMountedActionModalDontSee($target->password);

        $this->assertDatabaseHas('user_profiles', [
            'user_id' => $target->id,
            'nationality_country_code' => 'YE',
        ]);
    }

    public function test_user_without_profile_can_be_viewed(): void
    {
        $this->loginAdmin();

        $target = User::factory()->create([
            'username' => 'user_without_profile_test',
            'display_name' => 'User Without Profile',
        ]);

        Livewire::test(ManageUsers::class)
            ->assertSuccessful()
            ->mountAction(
                TestAction::make('view')->table($target)
            )
            ->assertMountedActionModalSee('غير مسجل');
    }

    public function test_revoked_admin_cannot_access_user_management(): void
    {
        $admin = $this->loginAdmin();

        DB::table('platform_role_assignments')
            ->where('user_id', $admin->id)
            ->where('role_code', 'platform_admin')
            ->update(['revoked_at' => now()]);

        $this->get(UserResource::getUrl())
            ->assertForbidden();
    }

    private function loginAdmin(): User
    {
        $admin = User::factory()->create([
            'status' => 'active',
        ]);

        DB::table('platform_role_assignments')->insert([
            'user_id' => $admin->id,
            'role_code' => 'platform_admin',
            'granted_by_user_id' => null,
            'granted_at' => now(),
            'revoked_at' => null,
        ]);

        $this->actingAs($admin, 'web');

        return $admin;
    }
}