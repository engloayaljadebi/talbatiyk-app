<?php

declare(strict_types=1);

namespace Tests\Feature\User;

use App\Models\User;
use App\Services\User\UserProfileService;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class UserProfileValidationTest extends TestCase
{
    use DatabaseTransactions;

    public function test_rejects_invalid_nationality_code(): void
    {
        $user = User::factory()->create();

        try {
            app(UserProfileService::class)->savePersonalDetails(
                $user,
                ['nationality_country_code' => 'YEM']
            );

            $this->fail('Expected validation error.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey(
                'nationality_country_code',
                $exception->errors()
            );
        }

        $this->assertFalse($user->profile()->exists());
    }

    public function test_rejects_future_birth_date(): void
    {
        $user = User::factory()->create();

        try {
            app(UserProfileService::class)->savePersonalDetails(
                $user,
                ['birth_date' => now()->addDay()->format('Y-m-d')]
            );

            $this->fail('Expected validation error.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey(
                'birth_date',
                $exception->errors()
            );
        }

        $this->assertFalse($user->profile()->exists());
    }

    public function test_accepts_nullable_personal_details(): void
    {
        $user = User::factory()->create();

        $profile = app(UserProfileService::class)->savePersonalDetails(
            $user,
            [
                'nationality_country_code' => null,
                'birth_date' => null,
            ]
        );

        $this->assertNull($profile->nationality_country_code);
        $this->assertNull($profile->birth_date);
    }

    public function test_partial_update_preserves_existing_values(): void
    {
        $user = User::factory()->create();
        $service = app(UserProfileService::class);

        $service->savePersonalDetails($user, [
            'nationality_country_code' => 'YE',
            'birth_date' => '2000-01-01',
        ]);

        $profile = $service->savePersonalDetails($user, [
            'nationality_country_code' => 'SA',
        ]);

        $this->assertSame('SA', $profile->nationality_country_code);
        $this->assertSame(
            '2000-01-01',
            $profile->birth_date->format('Y-m-d')
        );
    }
}