<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1\Auth;

use App\Models\Business;
use App\Models\User;
use App\Models\VerificationType;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class BusinessApprovalStatusApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_guests_cannot_read_business_approval_status(): void
    {
        $this->getJson('/api/v1/auth/business-approvals')->assertUnauthorized();
    }

    public function test_only_active_member_business_approvals_are_returned(): void
    {
        VerificationType::query()->firstOrCreate(
            ['code' => 'shop_approval'],
            ['subject_kind' => 'business'],
        );
        VerificationType::query()->firstOrCreate(
            ['code' => 'supplier_approval'],
            ['subject_kind' => 'business'],
        );

        $owner = User::factory()->create(['status' => 'active']);
        $someoneElse = User::factory()->create(['status' => 'active']);

        $shop = Business::query()->create(['name' => 'Pending shop', 'status' => 'active']);
        $shop->memberships()->create([
            'user_id' => $owner->id, 'status' => 'active', 'joined_at' => now(),
        ]);
        $shop->verifications()->create([
            'verification_type_code' => 'shop_approval',
            'requested_by_user_id' => $owner->id,
            'status' => 'pending',
            'requested_at' => now(),
        ]);

        $supplier = Business::query()->create(['name' => 'Pending supplier', 'status' => 'active']);
        $supplier->memberships()->create([
            'user_id' => $owner->id, 'status' => 'active', 'joined_at' => now(),
        ]);
        $supplier->verifications()->create([
            'verification_type_code' => 'supplier_approval',
            'requested_by_user_id' => $owner->id,
            'status' => 'pending',
            'requested_at' => now(),
        ]);

        $other = Business::query()->create(['name' => 'Someone else', 'status' => 'active']);
        $other->memberships()->create([
            'user_id' => $someoneElse->id, 'status' => 'active', 'joined_at' => now(),
        ]);
        $other->verifications()->create([
            'verification_type_code' => 'supplier_approval',
            'requested_by_user_id' => $someoneElse->id,
            'status' => 'pending',
            'requested_at' => now(),
        ]);

        Sanctum::actingAs($owner);

        $response = $this->getJson('/api/v1/auth/business-approvals');
        $response->assertOk()->assertJsonCount(2, 'data');
        $records = collect($response->json('data'))->keyBy('business_id');
        $this->assertSame('pending', $records[$shop->id]['shop_status']);
        $this->assertNull($records[$shop->id]['supplier_status']);
        $this->assertFalse($records[$shop->id]['supplier_enabled']);
        $this->assertSame('pending', $records[$supplier->id]['supplier_status']);
        $this->assertNull($records[$supplier->id]['shop_status']);
        $this->assertArrayNotHasKey($other->id, $records->all());
    }
}
