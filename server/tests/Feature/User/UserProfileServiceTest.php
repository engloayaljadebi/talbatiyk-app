<?php

declare(strict_types=1);

namespace Tests\Feature\User;

use App\Models\User;
use App\Models\UserProfile;
use App\Services\User\UserProfileService;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

final class UserProfileServiceTest extends TestCase
{
    use DatabaseTransactions;

    public function test_creates_personal_profile(): void
    {
        $user = User::factory()->create();

        $profile = app(UserProfileService::class)->savePersonalDetails(
            $user,
            [
                'nationality_country_code' => 'YE',
                'birth_date' => '2000-01-01',
            ]
        );

        $this->assertSame($user->id, $profile->user_id);
        $this->assertSame('YE', $profile->nationality_country_code);
        $this->assertSame(
            1,
            UserProfile::query()->where('user_id', $user->id)->count()
        );
    }

    public function test_updates_existing_profile_without_duplication(): void
    {
        $user = User::factory()->create();
        $service = app(UserProfileService::class);

        $first = $service->savePersonalDetails($user, [
            'nationality_country_code' => 'YE',
        ]);

        $second = $service->savePersonalDetails($user, [
            'nationality_country_code' => 'SA',
        ]);

        $this->assertSame($first->user_id, $second->user_id);
        $this->assertSame('SA', $second->nationality_country_code);
        $this->assertSame(
            1,
            UserProfile::query()->where('user_id', $user->id)->count()
        );
    }

    public function test_partial_update_preserves_existing_birth_date(): void
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

    public function test_cannot_change_profile_owner_through_input(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();

        $profile = app(UserProfileService::class)->savePersonalDetails(
            $user,
            [
                'user_id' => $otherUser->id,
                'nationality_country_code' => 'YE',
            ]
        );

        $this->assertSame($user->id, $profile->user_id);
        $this->assertNull($otherUser->fresh()->profile);
    }
}
