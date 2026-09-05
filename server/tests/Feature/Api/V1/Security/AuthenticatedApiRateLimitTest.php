<?php

namespace Tests\Feature\Api\V1\Security;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class AuthenticatedApiRateLimitTest extends TestCase
{
    use RefreshDatabase;

    public function test_active_authenticated_api_is_rate_limited_per_user(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $otherUser = User::factory()->create([
            'status' => 'active',
        ]);

        $token = $user
            ->createToken('rate-limit-test')
            ->plainTextToken;

        $otherToken = $otherUser
            ->createToken('rate-limit-other-user')
            ->plainTextToken;

        for ($attempt = 0; $attempt < 120; $attempt++) {
            $this
                ->withToken($token)
                ->getJson('/api/v1/auth/me')
                ->assertOk();
        }

        $this
            ->withToken($token)
            ->getJson('/api/v1/auth/me')
            ->assertStatus(429);

        /*
         * The authenticated throttle key must isolate users.
         * Exhausting one user's allowance must not block another user.
         */
        Auth::forgetGuards();

        $this
            ->withToken($otherToken)
            ->getJson('/api/v1/auth/me')
            ->assertOk();
    }
}
