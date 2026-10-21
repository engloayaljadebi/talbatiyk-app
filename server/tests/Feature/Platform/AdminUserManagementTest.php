<?php

declare(strict_types=1);

namespace Tests\Feature\Platform;

use App\Filament\Resources\Users\Pages\ManageUsers;
use App\Filament\Resources\Users\UserResource;
use App\Models\User;
use App\Services\Platform\AdminUserCreationService;
use Filament\Facades\Filament;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Livewire\Livewire;
use Tests\TestCase;

final class AdminUserManagementTest extends TestCase
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
            throw new \RuntimeException('Unsafe database.');
        }

        Filament::setCurrentPanel(
            Filament::getPanel('admin')
        );
    }

    public function test_admin_can_create_general_user(): void
    {
        $this->loginAdmin();

        Livewire::test(ManageUsers::class)
            ->assertSuccessful()
            ->assertActionExists('createUser')
            ->callAction(
                'createUser',
                data: $this->payload()
            )
            ->assertHasNoActionErrors();

        $created = User::query()
            ->where('username', 'general_user_test')
            ->firstOrFail();

        $this->assertSame('active', $created->status);

        $this->assertTrue(
            Hash::check('StrongPass123!', $created->password)
        );

        $this->assertDatabaseHas('user_contacts', [
            'user_id' => $created->id,
            'type' => 'email',
            'value' => 'general-user@example.com',
            'is_primary' => true,
        ]);

        $this->assertDatabaseMissing('platform_role_assignments', [
            'user_id' => $created->id,
        ]);

        $this->assertDatabaseMissing('business_memberships', [
            'user_id' => $created->id,
        ]);

        $this->assertDatabaseMissing('verifications', [
            'requested_by_user_id' => $created->id,
        ]);
    }

    public function test_regular_user_cannot_open_user_management(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $this->actingAs($user, 'web')
            ->get(UserResource::getUrl())
            ->assertForbidden();
    }

    public function test_duplicate_username_is_rejected(): void
    {
        $admin = $this->loginAdmin();

        User::factory()->create([
            'username' => 'general_user_test',
        ]);

        try {
            app(AdminUserCreationService::class)
                ->create($admin, $this->payload());

            $this->fail('Duplicate username was accepted.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey(
                'username',
                $exception->errors()
            );
        }

        $this->assertDatabaseMissing('user_contacts', [
            'value' => 'general-user@example.com',
        ]);
    }

    public function test_duplicate_contact_is_rejected(): void
    {
        $admin = $this->loginAdmin();

        $admin->contacts()->create([
            'type' => 'email',
            'value' => 'general-user@example.com',
            'is_primary' => true,
        ]);

        try {
            app(AdminUserCreationService::class)
                ->create($admin, $this->payload());

            $this->fail('Duplicate contact was accepted.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey(
                'contact_value',
                $exception->errors()
            );
        }

        $this->assertDatabaseMissing('users', [
            'username' => 'general_user_test',
        ]);
    }

    public function test_revoked_admin_cannot_create_user(): void
    {
        $admin = $this->loginAdmin();

        DB::table('platform_role_assignments')
            ->where('user_id', $admin->id)
            ->where('role_code', 'platform_admin')
            ->update([
                'revoked_at' => now(),
            ]);

        $this->expectException(
            AuthorizationException::class
        );

        app(AdminUserCreationService::class)
            ->create($admin, $this->payload());
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
            'username' => 'general_user_test',
            'display_name' => 'General Test User',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'general-user@example.com',
        ];
    }
}
