<?php

namespace Tests\Feature\Services\Follow;

use App\Models\Business;
use App\Models\User;
use App\Services\Follow\SupplierFollowService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class SupplierFollowServiceTest extends TestCase
{
    use RefreshDatabase;

    private SupplierFollowService $service;

    protected function setUp(): void
    {
        parent::setUp();

        $this->service = app(SupplierFollowService::class);
    }

    public function test_follow_creates_relation_and_reports_following(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $supplier = $this->supplier();

        $this->assertFalse(
            $this->service->isFollowing($user, $supplier),
        );

        $created = $this->service->follow($user, $supplier);

        $this->assertTrue($created);

        $this->assertDatabaseHas('business_follows', [
            'user_id' => $user->id,
            'business_id' => $supplier->id,
        ]);

        $this->assertTrue(
            $this->service->isFollowing($user, $supplier),
        );
    }

    public function test_duplicate_follow_is_idempotent(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $supplier = $this->supplier();

        $this->assertTrue(
            $this->service->follow($user, $supplier),
        );

        // تكرار POST Follow يجب ألا ينشئ علاقة ثانية.
        $this->assertFalse(
            $this->service->follow($user, $supplier),
        );

        $this->assertSame(
            1,
            DB::table('business_follows')
                ->where('user_id', $user->id)
                ->where('business_id', $supplier->id)
                ->count(),
        );
    }

    public function test_unfollow_removes_relation_and_is_idempotent(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $supplier = $this->supplier();

        $this->service->follow($user, $supplier);

        $this->assertTrue(
            $this->service->unfollow($user, $supplier),
        );

        $this->assertDatabaseMissing('business_follows', [
            'user_id' => $user->id,
            'business_id' => $supplier->id,
        ]);

        $this->assertFalse(
            $this->service->isFollowing($user, $supplier),
        );

        // تكرار Unfollow لا يعتبر خطأ ولا يحذف شيئًا إضافيًا.
        $this->assertFalse(
            $this->service->unfollow($user, $supplier),
        );
    }

    public function test_suspended_supplier_cannot_be_followed(): void
    {
        $user = User::factory()->create();

        $supplier = $this->supplier(status: 'suspended');

        $this->assertCannotFollow($user, $supplier);
    }

    public function test_closed_supplier_cannot_be_followed(): void
    {
        $user = User::factory()->create();

        $supplier = $this->supplier(status: 'closed');

        $this->assertCannotFollow($user, $supplier);
    }

    public function test_disabled_supplier_capability_cannot_be_followed(): void
    {
        $user = User::factory()->create();

        $supplier = $this->supplier(disabled: true);

        $this->assertCannotFollow($user, $supplier);
    }

    public function test_retired_supplier_capability_cannot_be_followed(): void
    {
        $user = User::factory()->create();

        $supplier = $this->supplier(retired: true);

        $this->assertCannotFollow($user, $supplier);
    }

    public function test_soft_deleted_supplier_cannot_be_followed(): void
    {
        $user = User::factory()->create();

        $supplier = $this->supplier();

        $supplier->delete();

        $this->assertCannotFollow($user, $supplier);
    }

    public function test_business_without_supplier_capability_cannot_be_followed(): void
    {
        $user = User::factory()->create();

        $business = Business::query()->create([
            'name' => 'Non Supplier Business',
            'status' => 'active',
        ]);

        $this->assertCannotFollow($user, $business);
    }

    /**
     * إنشاء Business يطابق Supplier eligibility المستخدم
     * حاليًا في Product Discovery.
     */
    private function supplier(
        string $status = 'active',
        bool $disabled = false,
        bool $retired = false,
    ): Business {
        $business = Business::query()->create([
            'name' => 'Gate 2.3 Supplier',
            'status' => $status,
        ]);

        DB::table('business_capabilities')->updateOrInsert(
            ['code' => 'supplier'],
            [
                'retired_at' => $retired ? now() : null,
            ],
        );

        $enabledAt = now();

        DB::table('business_capability_assignments')->insert([
            'business_id' => $business->id,
            'capability_code' => 'supplier',
            'enabled_at' => $enabledAt,
            'disabled_at' => $disabled ? $enabledAt : null,
        ]);

        return $business;
    }

    /**
     * يثبت رفض Follow وعدم إنشاء أي Pivot row.
     */
    private function assertCannotFollow(
        User $user,
        Business $business,
    ): void {
        try {
            $this->service->follow($user, $business);

            $this->fail(
                'Expected the supplier follow operation to be rejected.',
            );
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey(
                'business_id',
                $exception->errors(),
            );
        }

        $this->assertDatabaseMissing('business_follows', [
            'user_id' => $user->id,
            'business_id' => $business->id,
        ]);
    }
}
