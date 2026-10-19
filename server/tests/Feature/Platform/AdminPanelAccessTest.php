<?php

namespace Tests\Feature\Platform;

use App\Filament\Pages\Auth\AdminLogin;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Livewire\Livewire;
use Tests\TestCase;

class AdminPanelAccessTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Filament::setCurrentPanel(Filament::getPanel('admin'));
    }

    public function test_guest_is_redirected_to_admin_login(): void
    {
        $this->get('/admin')
            ->assertRedirect('/admin/login');
    }

    public function test_login_page_is_accessible(): void
    {
        $this->get('/admin/login')->assertOk();
    }

    public function test_regular_user_cannot_access_panel(): void
    {
        $user = User::factory()->create(['status' => 'active']);

        $this->actingAs($user, 'web')
            ->get('/admin')
            ->assertForbidden();
    }

    public function test_platform_admin_can_access_panel(): void
    {
        $user = User::factory()->create(['status' => 'active']);
        $this->grantAdmin($user);

        $this->actingAs($user, 'web')
            ->get('/admin')
            ->assertOk();
    }

    public function test_revoked_admin_cannot_access_panel(): void
    {
        $user = User::factory()->create(['status' => 'active']);
        $this->grantAdmin($user);

        DB::table('platform_role_assignments')
            ->where('user_id', $user->id)
            ->update(['revoked_at' => now()]);

        $this->actingAs($user, 'web')
            ->get('/admin')
            ->assertForbidden();
    }

    public function test_admin_can_login_with_username(): void
    {
        $user = User::factory()->create([
            'username' => 'panel_admin',
            'password' => 'PanelTestPassword123!',
            'status' => 'active',
        ]);
        $this->grantAdmin($user);

        Livewire::test(AdminLogin::class)
            ->fillForm([
                'username' => 'panel_admin',
                'password' => 'PanelTestPassword123!',
                'remember' => false,
            ])
            ->call('authenticate')
            ->assertHasNoFormErrors();

        $this->assertAuthenticatedAs($user, 'web');
    }

    public function test_regular_user_cannot_login_to_panel(): void
    {
        User::factory()->create([
            'username' => 'regular_user',
            'password' => 'PanelTestPassword123!',
            'status' => 'active',
        ]);

        Livewire::test(AdminLogin::class)
            ->fillForm([
                'username' => 'regular_user',
                'password' => 'PanelTestPassword123!',
                'remember' => false,
            ])
            ->call('authenticate')
            ->assertHasFormErrors(['username']);

        $this->assertGuest('web');
    }

    private function grantAdmin(User $user): void
    {
        DB::table('platform_role_assignments')->insert([
            'user_id' => $user->id,
            'role_code' => 'platform_admin',
            'granted_at' => now()->subMinute(),
        ]);
    }
}
