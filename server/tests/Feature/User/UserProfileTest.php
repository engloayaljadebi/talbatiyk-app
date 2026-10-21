<?php

declare(strict_types=1);

namespace Tests\Feature\User;

use App\Models\User;
use App\Models\UserProfile;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

final class UserProfileTest extends TestCase
{
    use DatabaseTransactions;

    public function test_user_can_have_one_profile(): void
    {
        $user = User::factory()->create();

        $profile = $user->profile()->create([
            'nationality_country_code' => 'YE',
            'birth_date' => '2000-01-01',
        ]);

        $this->assertSame($user->id, $profile->user_id);
        $this->assertSame(
            'YE',
            $user->fresh()->profile->nationality_country_code
        );
        $this->assertSame(
            '2000-01-01',
            $user->fresh()->profile->birth_date->format('Y-m-d')
        );
    }

    public function test_database_prevents_duplicate_profiles(): void
    {
        $user = User::factory()->create();

        $user->profile()->create([
            'user_id' => $user->id,
            'nationality_country_code' => 'YE',
        ]);

        try {
            $user->profile()->create([
                'user_id' => $user->id,
                'nationality_country_code' => 'SA',
            ]);
        } catch (QueryException $exception) {
            $this->assertSame(
                '23505',
                $exception->errorInfo[0] ?? null
            );
            return;
        }

        $this->fail('Database allowed duplicate profiles.');
    }

    public function test_profile_is_accessible_from_user(): void
    {
        $user = User::factory()->create();

        $user->profile()->create([
            'nationality_country_code' => 'YE',
        ]);

        $this->assertInstanceOf(
            UserProfile::class,
            $user->fresh()->profile
        );

        $this->assertSame(
            1,
            UserProfile::query()
                ->where('user_id', $user->id)
                ->count()
        );
    }
}