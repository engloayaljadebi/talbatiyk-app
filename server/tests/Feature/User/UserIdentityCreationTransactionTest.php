<?php

declare(strict_types=1);

namespace Tests\Feature\User;

use App\Models\User;
use App\Services\User\UserIdentityCreationService;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;
use Throwable;

final class UserIdentityCreationTransactionTest extends TestCase
{
    use DatabaseTransactions;

    public function test_creates_user_and_primary_contact(): void
    {
        $user = app(UserIdentityCreationService::class)
            ->create($this->payload());

        $this->assertInstanceOf(User::class, $user);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'username' => 'identity_test_user',
            'display_name' => 'مستخدم تجريبي',
            'status' => 'active',
        ]);

        $this->assertDatabaseHas('user_contacts', [
            'user_id' => $user->id,
            'type' => 'email',
            'value' => 'identity@example.com',
            'is_primary' => true,
        ]);

        $this->assertCount(1, $user->contacts);
    }

    public function test_password_is_hashed(): void
    {
        $user = app(UserIdentityCreationService::class)
            ->create($this->payload());

        $this->assertNotSame(
            'StrongPass123!',
            $user->password,
        );

        $this->assertTrue(
            Hash::check('StrongPass123!', $user->password),
        );
    }

    public function test_rolls_back_user_if_contact_creation_fails(): void
    {
        $payload = $this->payload();

        // An invalid contact type should violate the DB constraint.
        $payload['contact_type'] = 'invalid_contact_type';

        $failed = false;

        try {
            app(UserIdentityCreationService::class)
                ->create($payload);
        } catch (Throwable $exception) {
            $failed = true;
        }

        $this->assertTrue(
            $failed,
            'Expected contact creation to fail.',
        );

        $this->assertDatabaseMissing('users', [
            'username' => 'identity_test_user',
        ]);

        $this->assertDatabaseCount('user_contacts', 0);
    }

    private function payload(): array
    {
        return [
            'username' => 'identity_test_user',
            'display_name' => 'مستخدم تجريبي',
            'password' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'identity@example.com',
        ];
    }
}
