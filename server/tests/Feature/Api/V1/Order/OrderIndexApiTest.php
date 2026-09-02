<?php

namespace Tests\Feature\Api\V1\Order;

use App\Models\Order;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OrderIndexApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_unauthenticated_user_cannot_list_orders(): void
    {
        $this
            ->getJson('/api/v1/orders')
            ->assertUnauthorized();
    }

    public function test_authenticated_user_only_receives_own_orders_with_aggregate_status(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $otherUser = User::factory()->create([
            'status' => 'active',
        ]);

        $visibleOrder = $this->createOrderFor(
            $user,
            'Visible customer order',
        );

        $hiddenOrder = $this->createOrderFor(
            $otherUser,
            'Other customer order',
        );

        Sanctum::actingAs($user);

        $this
            ->getJson('/api/v1/orders')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $visibleOrder->id)
            ->assertJsonPath('data.0.status', 'pending')
            ->assertJsonPath(
                'data.0.aggregate_status',
                'pending_responses',
            )
            ->assertJsonPath(
                'data.0.notes',
                'Visible customer order',
            )
            ->assertJsonPath('data.0.items', [])
            ->assertJsonMissing([
                'id' => $hiddenOrder->id,
            ]);
    }

    private function createOrderFor(User $user, string $notes): Order
    {
        return Order::query()->create([
            'user_id' => $user->id,
            'idempotency_key' => (string) Str::uuid(),
            'idempotency_payload_hash' => hash(
                'sha256',
                (string) Str::uuid(),
            ),
            'status' => 'pending',
            'notes' => $notes,
        ]);
    }
}
