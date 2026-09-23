<?php

namespace Tests\Feature\Api\V1\Notification;

use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class NotificationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_unauthenticated_user_cannot_list_notifications(): void
    {
        $this
            ->getJson('/api/v1/notifications')
            ->assertUnauthorized();
    }

    public function test_inactive_user_cannot_list_notifications(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $token = $this->tokenFor($user);

        $user->update([
            'status' => 'suspended',
        ]);

        $this
            ->withToken($token)
            ->getJson('/api/v1/notifications')
            ->assertForbidden()
            ->assertJsonPath('code', 'ACCOUNT_INACTIVE');
    }

    public function test_user_only_sees_own_notifications_newest_first(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();

        $olderId = $this->insertNotification(
            user: $user,
            title: 'Older notification',
            createdAt: CarbonImmutable::parse('2026-09-19 10:00:00'),
        );

        $newerId = $this->insertNotification(
            user: $user,
            title: 'Newer notification',
            createdAt: CarbonImmutable::parse('2026-09-19 11:00:00'),
        );

        $this->insertNotification(
            user: $otherUser,
            title: 'Other user notification',
            createdAt: CarbonImmutable::parse('2026-09-19 12:00:00'),
        );

        $this
            ->withToken($this->tokenFor($user))
            ->getJson('/api/v1/notifications')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.id', $newerId)
            ->assertJsonPath('data.1.id', $olderId);
    }

    public function test_notification_resource_exposes_stable_app_contract(): void
    {
        $user = User::factory()->create();

        $id = $this->insertNotification(
            user: $user,
            type: 'order_response_received',
            title: 'وصل رد جديد على طلبك',
            body: 'قام أحد الموردين بالرد على الطلب.',
            metadata: [
                'order_id' => '00000000-0000-4000-8000-000000000111',
                'target_route' => '/orders/00000000-0000-4000-8000-000000000111',
            ],
        );

        $this
            ->withToken($this->tokenFor($user))
            ->getJson('/api/v1/notifications')
            ->assertOk()
            ->assertJsonPath('data.0.id', $id)
            ->assertJsonPath(
                'data.0.type',
                'order_response_received',
            )
            ->assertJsonPath(
                'data.0.title',
                'وصل رد جديد على طلبك',
            )
            ->assertJsonPath('data.0.is_read', false)
            ->assertJsonPath('data.0.read_at', null)
            ->assertJsonPath(
                'data.0.data.order_id',
                '00000000-0000-4000-8000-000000000111',
            );
    }

    public function test_notifications_are_paginated(): void
    {
        $user = User::factory()->create();

        foreach (range(1, 25) as $index) {
            $this->insertNotification(
                user: $user,
                title: "Notification $index",
                createdAt: CarbonImmutable::parse(
                    '2026-09-19 10:00:00',
                )->addMinutes($index),
            );
        }

        $this
            ->withToken($this->tokenFor($user))
            ->getJson('/api/v1/notifications?per_page=10&page=1')
            ->assertOk()
            ->assertJsonCount(10, 'data')
            ->assertJsonPath('meta.current_page', 1)
            ->assertJsonPath('meta.per_page', 10)
            ->assertJsonPath('meta.total', 25);
    }

    public function test_per_page_is_bounded(): void
    {
        $user = User::factory()->create();

        $this
            ->withToken($this->tokenFor($user))
            ->getJson('/api/v1/notifications?per_page=101')
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'per_page',
            ]);
    }

    public function test_unread_count_is_scoped_to_current_user(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();

        $this->insertNotification(user: $user);
        $this->insertNotification(user: $user);

        $this->insertNotification(
            user: $user,
            readAt: CarbonImmutable::parse('2026-09-19 12:00:00'),
        );

        $this->insertNotification(user: $otherUser);

        $this
            ->withToken($this->tokenFor($user))
            ->getJson('/api/v1/notifications/unread-count')
            ->assertOk()
            ->assertJsonPath('data.unread_count', 2);
    }

    public function test_user_can_mark_own_notification_as_read(): void
    {
        $user = User::factory()->create();

        $id = $this->insertNotification(user: $user);

        $this
            ->withToken($this->tokenFor($user))
            ->patchJson("/api/v1/notifications/$id/read")
            ->assertOk()
            ->assertJsonPath('data.id', $id)
            ->assertJsonPath('data.is_read', true);

        $this->assertDatabaseMissing('notifications', [
            'id' => $id,
            'read_at' => null,
        ]);
    }

    public function test_mark_read_is_idempotent(): void
    {
        $user = User::factory()->create();
        $id = $this->insertNotification(user: $user);
        $token = $this->tokenFor($user);

        $this
            ->withToken($token)
            ->patchJson("/api/v1/notifications/$id/read")
            ->assertOk();

        $first = DB::table('notifications')
            ->where('id', $id)
            ->value('read_at');

        $this
            ->withToken($token)
            ->patchJson("/api/v1/notifications/$id/read")
            ->assertOk();

        $second = DB::table('notifications')
            ->where('id', $id)
            ->value('read_at');

        $this->assertSame(
            (string) $first,
            (string) $second,
        );
    }

    public function test_user_cannot_mark_another_users_notification_as_read(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();

        $id = $this->insertNotification(user: $otherUser);

        $this
            ->withToken($this->tokenFor($user))
            ->patchJson("/api/v1/notifications/$id/read")
            ->assertNotFound();

        $this->assertDatabaseHas('notifications', [
            'id' => $id,
            'notifiable_type' => User::class,
            'notifiable_id' => $otherUser->id,
            'read_at' => null,
        ]);
    }

    public function test_user_can_mark_all_own_notifications_as_read(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();

        $this->insertNotification(user: $user);
        $this->insertNotification(user: $user);

        $otherId = $this->insertNotification(
            user: $otherUser,
        );

        $this
            ->withToken($this->tokenFor($user))
            ->postJson('/api/v1/notifications/read-all')
            ->assertOk()
            ->assertJsonPath('data.updated_count', 2)
            ->assertJsonPath('data.unread_count', 0);

        $this->assertDatabaseMissing('notifications', [
            'notifiable_type' => User::class,
            'notifiable_id' => $user->id,
            'read_at' => null,
        ]);

        $this->assertDatabaseHas('notifications', [
            'id' => $otherId,
            'notifiable_type' => User::class,
            'notifiable_id' => $otherUser->id,
            'read_at' => null,
        ]);
    }

    private function insertNotification(
        User $user,
        string $type = 'order_created',
        string $title = 'Test notification',
        string $body = 'Test notification body.',
        array $metadata = [],
        ?CarbonImmutable $readAt = null,
        ?CarbonImmutable $createdAt = null,
    ): string {
        $id = Str::uuid()->toString();
        $createdAt ??= CarbonImmutable::now();

        DB::table('notifications')->insert([
            'id' => $id,
            'type' => $type,
            'notifiable_type' => User::class,
            'notifiable_id' => $user->id,
            'data' => json_encode([
                'title' => $title,
                'body' => $body,
                'data' => $metadata,
            ], JSON_THROW_ON_ERROR
                | JSON_UNESCAPED_SLASHES
                | JSON_UNESCAPED_UNICODE),
            'read_at' => $readAt,
            'created_at' => $createdAt,
            'updated_at' => $createdAt,
        ]);

        return $id;
    }

    private function tokenFor(User $user): string
    {
        return $user
            ->createToken('notification-api-test')
            ->plainTextToken;
    }
}
