<?php

declare(strict_types=1);

namespace Tests\Feature\Platform;

use App\Filament\Resources\Users\Pages\ManageUsers;
use App\Models\User;
use App\Services\Platform\AdminUserUpdateService;
use Filament\Actions\Testing\TestAction;
use Filament\Facades\Filament;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Livewire\Livewire;
use Tests\TestCase;

final class AdminUserUpdateTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();

        $database = DB::selectOne(
            'SELECT current_database() AS name'
        )->name;

        if (
            DB::connection()->getDatabaseName() !== 'talbatiyk_testing'
            || $database !== 'talbatiyk_testing'
        ) {
            throw new \RuntimeException('Unsafe test database.');
        }

        Filament::setCurrentPanel(Filament::getPanel('admin'));
    }

    public function test_admin_can_edit_user_from_filament(): void
    {
        $this->loginAdmin();

        $target = User::factory()->create([
            'username' => 'oldedituser',
            'display_name' => 'Old Name',
            'status' => 'active',
        ]);

        $oldPassword = $target->password;

        Livewire::test(ManageUsers::class)
            ->assertSuccessful()
            ->callAction(
                TestAction::make('editAccount')->table($target),
                data: $this->payload()
            )
            ->assertHasNoActionErrors();

        $target->refresh();

        $this->assertSame('newedituser', $target->username);
        $this->assertSame('Updated Name', $target->display_name);
        $this->assertSame('active', $target->status);
        $this->assertSame($oldPassword, $target->password);

        $this->assertDatabaseHas('user_profiles', [
            'user_id' => $target->id,
            'nationality_country_code' => 'YE',
            'birth_date' => '2000-01-15',
        ]);

        $this->assertDatabaseMissing('platform_role_assignments', [
            'user_id' => $target->id,
        ]);
    }

    public function test_duplicate_username_is_rejected(): void
    {
        $admin = $this->loginAdmin();

        User::factory()->create([
            'username' => 'newedituser',
        ]);

        $target = User::factory()->create([
            'username' => 'oldedituser',
        ]);

        try {
            app(AdminUserUpdateService::class)->update(
                $admin,
                $target,
                $this->payload()
            );

            $this->fail('Duplicate username accepted.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey(
                'username',
                $exception->errors()
            );
        }

        $this->assertSame(
            'oldedituser',
            $target->fresh()->username
        );

        $this->assertDatabaseMissing('user_profiles', [
            'user_id' => $target->id,
        ]);
    }

    public function test_revoked_admin_cannot_edit_user(): void
    {
        $admin = $this->loginAdmin();
        $target = User::factory()->create();

        DB::table('platform_role_assignments')
            ->where('user_id', $admin->id)
            ->update(['revoked_at' => now()]);

        $this->expectException(AuthorizationException::class);

        app(AdminUserUpdateService::class)->update(
            $admin,
            $target,
            $this->payload()
        );
    }

    public function test_empty_personal_details_do_not_create_profile(): void
    {
        $admin = $this->loginAdmin();

        $target = User::factory()->create([
            'username' => 'oldedituser',
        ]);

        $input = $this->payload();
        $input['nationality_country_code'] = null;
        $input['birth_date'] = null;

        app(AdminUserUpdateService::class)->update(
            $admin,
            $target,
            $input
        );

        $this->assertSame(
            'newedituser',
            $target->fresh()->username
        );

        $this->assertDatabaseMissing('user_profiles', [
            'user_id' => $target->id,
        ]);
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

    private function payload(): array
    {
        return [
            'username' => 'newedituser',
            'display_name' => 'Updated Name',
            'nationality_country_code' => 'YE',
            'birth_date' => '2000-01-15',
        ];
    }
}
