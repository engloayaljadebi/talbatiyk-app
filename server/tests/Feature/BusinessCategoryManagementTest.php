<?php

namespace Tests\Feature;

use App\Models\Business;
use App\Models\User;
use App\Services\Business\BusinessCategoryManagementService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class BusinessCategoryManagementTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();

        if (
            DB::connection()->getDatabaseName() !== 'talbatiyk_testing'
            || DB::selectOne('SELECT current_database() AS db')->db
                !== 'talbatiyk_testing'
        ) {
            throw new \RuntimeException('Unsafe test database.');
        }
    }

    public function test_admin_can_create_root_and_child_categories(): void
    {
        $admin = $this->admin();
        $service = app(BusinessCategoryManagementService::class);

        $root = $service->create($admin, $this->data('electronics_test'));
        $child = $service->create(
            $admin,
            $this->data('phones_test', $root->id)
        );

        $this->assertNull($root->parent_id);
        $this->assertSame($root->id, $child->parent_id);
        $this->assertTrue($child->is_active);
    }

    public function test_regular_user_cannot_create_category(): void
    {
        $user = User::factory()->create(['status' => 'active']);

        $this->expectException(AuthorizationException::class);

        app(BusinessCategoryManagementService::class)
            ->create($user, $this->data('unauthorized_test'));
    }

    public function test_invalid_code_is_rejected(): void
    {
        $this->expectException(ValidationException::class);

        app(BusinessCategoryManagementService::class)
            ->create($this->admin(), $this->data('Invalid Code'));
    }

    public function test_child_under_inactive_ancestor_is_rejected(): void
    {
        $admin = $this->admin();
        $service = app(BusinessCategoryManagementService::class);

        $root = $service->create($admin, $this->data('disabled_root_test'));
        $middle = $service->create(
            $admin,
            $this->data('middle_branch_test', $root->id)
        );

        $root->update(['is_active' => false]);

        $this->expectException(ValidationException::class);

        $service->create(
            $admin,
            $this->data('blocked_leaf_test', $middle->id)
        );
    }

    public function test_assigned_category_cannot_become_parent(): void
    {
        $admin = $this->admin();
        $service = app(BusinessCategoryManagementService::class);

        $category = $service->create(
            $admin,
            $this->data('assigned_leaf_test')
        );

        $business = Business::query()->create([
            'name' => 'Business for category test',
            'status' => 'active',
        ]);

        $business->categories()->attach($category->id);

        $this->expectException(ValidationException::class);

        $service->create(
            $admin,
            $this->data('illegal_child_test', $category->id)
        );
    }

    private function admin(): User
    {
        $admin = User::factory()->create(['status' => 'active']);

        DB::table('platform_role_assignments')->insert([
            'user_id' => $admin->id,
            'role_code' => 'platform_admin',
            'granted_at' => now(),
        ]);

        return $admin;
    }

    private function data(string $code, ?string $parentId = null): array
    {
        return [
            'code' => $code,
            'name_ar' => 'فئة اختبار',
            'parent_id' => $parentId,
            'is_active' => true,
            'sort_order' => 0,
        ];
    }
}
