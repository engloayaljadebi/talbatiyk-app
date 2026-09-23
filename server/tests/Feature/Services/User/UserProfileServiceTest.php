<?php

namespace Tests\Feature\Services\User;

use App\Models\User;
use App\Services\User\UserProfileService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class UserProfileServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_database_unique_constraint_is_mapped_to_username_validation_error(): void
    {
        User::factory()->create([
            'username' => 'database_reserved',
            'status' => 'active',
        ]);

        $user = User::factory()->create([
            'username' => 'database_current',
            'status' => 'active',
        ]);

        try {
            app(UserProfileService::class)->update(
                $user,
                [
                    'username' => 'DATABASE_RESERVED',
                ],
            );

            $this->fail(
                'Expected username uniqueness validation failure.',
            );
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey(
                'username',
                $exception->errors(),
            );
        }

        $user->refresh();

        $this->assertSame(
            'database_current',
            $user->username,
        );
    }
}
