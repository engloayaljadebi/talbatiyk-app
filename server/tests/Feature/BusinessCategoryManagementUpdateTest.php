<?php

namespace Tests\Feature;

use App\Models\Business;
use App\Models\BusinessCategory;
use App\Models\User;
use App\Services\Business\BusinessCategoryManagementService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class BusinessCategoryManagementUpdateTest extends TestCase
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

    public function test_admin_can_edit_name_and_order(): void
    {
        $category = $this->category('edit_category_test');

        $updated = app(BusinessCategoryManagementService::class)
            ->update($this->admin(), $category, [
                'name_ar' => 'فئة تجارية محدثة',
                'sort_order' => 15,
            ]);

        $this->assertSame('فئة تجارية محدثة', $updated->name_ar);
        $this->assertSame(15, $updated->sort_order);
    }

    public function test_admin_can_disable_unused_category(): void
    {
        $category = $this->category('unused_category_test');

        $updated = app(BusinessCategoryManagementService::class)
            ->update($this->admin(), $category, [
                'is_active' => false,
            ]);

        $this->assertFalse($updated->is_active);
    }

    public function test_admin_cannot_disable_assigned_category(): void
    {
        $category = $this->category('assigned_category_test');

        $business = Business::query()->create([
            'name' => 'Assigned business test',
            'status' => 'active',
        ]);

        $business->categories()->attach($category->id);

        $this->expectException(ValidationException::class);

        app(BusinessCategoryManagementService::class)
            ->update($this->admin(), $category, [
                'is_active' => false,
            ]);
    }

    public function test_admin_cannot_disable_ancestor_of_assigned_category(): void
    {
        $root = $this->category('ancestor_category_test');
        $leaf = $this->category('descendant_category_test', $root->id);

        $business = Business::query()->create([
            'name' => 'Descendant business test',
            'status' => 'active',
        ]);

        $business->categories()->attach($leaf->id);

        $this->expectException(ValidationException::class);

        app(BusinessCategoryManagementService::class)
            ->update($this->admin(), $root, [
                'is_active' => false,
            ]);
    }

    public function test_admin_cannot_enable_category_under_inactive_parent(): void
    {
        $root = $this->category('inactive_parent_update_test');
        $child = $this->category('child_activation_test', $root->id);

        $root->update(['is_active' => false]);
        $child->update(['is_active' => false]);

        $this->expectException(ValidationException::class);

        app(BusinessCategoryManagementService::class)
            ->update($this->admin(), $child, [
                'is_active' => true,
            ]);
    }

    public function test_regular_user_cannot_update_category(): void
    {
        $category = $this->category('unauthorized_update_test');
        $user = User::factory()->create(['status' => 'active']);

        $this->expectException(AuthorizationException::class);

        app(BusinessCategoryManagementService::class)
            ->update($user, $category, [
                'name_ar' => 'تعديل غير مصرح',
            ]);
    }

    public function test_code_and_parent_cannot_be_changed_by_generic_update(): void
    {
        $category = $this->category('protected_fields_test');

        $this->expectException(ValidationException::class);

        app(BusinessCategoryManagementService::class)
            ->update($this->admin(), $category, [
                'code' => 'other_code',
            ]);
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

    private function category(
        string $code,
        ?string $parentId = null
    ): BusinessCategory {
        return BusinessCategory::query()->create([
            'code' => $code,
            'name_ar' => 'فئة اختبار',
            'parent_id' => $parentId,
            'is_active' => true,
            'sort_order' => 0,
        ]);
    }
}
