<?php

namespace Tests\Feature\Api\V1\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProfileUpdateApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_update_username_and_display_name(): void
    {
        $user = User::factory()->create([
            'username' => 'old_username',
            'display_name' => 'Old Name',
            'status' => 'active',
        ]);

        $contact = $user->contacts()->create([
            'type' => 'phone',
            'value' => '+967777123456',
            'is_primary' => true,
        ]);

        $token = $user
            ->createToken('Profile Test Device')
            ->plainTextToken;

        $response = $this
            ->withToken($token)
            ->patchJson('/api/v1/auth/me', [
                'username' => '  NEW_USERNAME  ',
                'display_name' => '  New Display Name  ',
            ]);

        $response
            ->assertOk()
            ->assertJsonPath('data.id', $user->id)
            ->assertJsonPath('data.username', 'new_username')
            ->assertJsonPath('data.display_name', 'New Display Name')
            ->assertJsonPath('data.contacts.0.id', $contact->id)
            ->assertJsonPath(
                'data.contacts.0.value',
                '+967777123456',
            );

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'username' => 'new_username',
            'display_name' => 'New Display Name',
        ]);

        $this->assertDatabaseHas('user_contacts', [
            'id' => $contact->id,
            'user_id' => $user->id,
            'value' => '+967777123456',
        ]);
    }

    public function test_profile_update_is_partial_and_preserves_omitted_fields(): void
    {
        $user = User::factory()->create([
            'username' => 'keep_username',
            'display_name' => 'Old Display Name',
            'status' => 'active',
        ]);

        $token = $user
            ->createToken('Profile Test Device')
            ->plainTextToken;

        $this
            ->withToken($token)
            ->patchJson('/api/v1/auth/me', [
                'display_name' => 'Updated Name',
            ])
            ->assertOk()
            ->assertJsonPath('data.username', 'keep_username')
            ->assertJsonPath('data.display_name', 'Updated Name');

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'username' => 'keep_username',
            'display_name' => 'Updated Name',
        ]);
    }

    public function test_profile_update_rejects_duplicate_username_case_insensitively(): void
    {
        User::factory()->create([
            'username' => 'existing_user',
            'status' => 'active',
        ]);

        $user = User::factory()->create([
            'username' => 'current_user',
            'display_name' => 'Current User',
            'status' => 'active',
        ]);

        $token = $user
            ->createToken('Profile Test Device')
            ->plainTextToken;

        $this
            ->withToken($token)
            ->patchJson('/api/v1/auth/me', [
                'username' => 'EXISTING_USER',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'username',
            ]);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'username' => 'current_user',
        ]);
    }

    public function test_profile_update_allows_current_username(): void
    {
        $user = User::factory()->create([
            'username' => 'same_username',
            'display_name' => 'Same User',
            'status' => 'active',
        ]);

        $token = $user
            ->createToken('Profile Test Device')
            ->plainTextToken;

        $this
            ->withToken($token)
            ->patchJson('/api/v1/auth/me', [
                'username' => ' SAME_USERNAME ',
            ])
            ->assertOk()
            ->assertJsonPath('data.username', 'same_username');
    }

    public function test_profile_update_validates_identity_fields(): void
    {
        $user = User::factory()->create([
            'username' => 'validation_user',
            'display_name' => 'Validation User',
            'status' => 'active',
        ]);

        $token = $user
            ->createToken('Profile Test Device')
            ->plainTextToken;

        $this
            ->withToken($token)
            ->patchJson('/api/v1/auth/me', [
                'username' => 'x',
                'display_name' => 'x',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'username',
                'display_name',
            ]);
    }

    public function test_guest_cannot_update_current_profile(): void
    {
        $this
            ->patchJson('/api/v1/auth/me', [
                'display_name' => 'Unauthorized Update',
            ])
            ->assertUnauthorized();
    }

    public function test_profile_update_rejects_username_owned_by_soft_deleted_user(): void
    {
        $deletedUser = User::factory()->create([
            'username' => 'reserved_username',
            'status' => 'active',
        ]);

        $deletedUser->delete();

        $user = User::factory()->create([
            'username' => 'current_username',
            'status' => 'active',
        ]);

        $token = $user->createToken('test-device')->plainTextToken;

        $this
            ->withToken($token)
            ->patchJson('/api/v1/auth/me', [
                'username' => 'RESERVED_USERNAME',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'username',
            ]);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'username' => 'current_username',
        ]);
    }

    public function test_profile_update_rejects_server_owned_fields(): void
    {
        $user = User::factory()->create([
            'username' => 'protected_profile_user',
            'display_name' => 'Protected User',
            'status' => 'active',
        ]);

        $token = $user->createToken('test-device')->plainTextToken;

        $this
            ->withToken($token)
            ->patchJson('/api/v1/auth/me', [
                'status' => 'disabled',
                'password' => 'changed-password',
                'contacts' => [],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'status',
                'password',
                'contacts',
            ]);

        $user->refresh();

        $this->assertSame('active', $user->status);
        $this->assertSame(
            'protected_profile_user',
            $user->username,
        );
    }

    public function test_inactive_user_cannot_update_current_profile(): void
    {
        $user = User::factory()->create([
            'username' => 'inactive_profile_user',
            'status' => 'active',
        ]);

        $token = $user->createToken('test-device')->plainTextToken;

        $user->forceFill([
            'status' => 'suspended',
        ])->save();

        $this
            ->withToken($token)
            ->patchJson('/api/v1/auth/me', [
                'display_name' => 'Should Not Change',
            ])
            ->assertForbidden();

        $user->refresh();

        $this->assertNotSame(
            'Should Not Change',
            $user->display_name,
        );
    }
}
