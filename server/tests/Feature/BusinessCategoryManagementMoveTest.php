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

final class BusinessCategoryManagementMoveTest extends TestCase
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

    public function test_admin_can_move_unused_leaf(): void
    {
        $first = $this->category('move_first_parent');
        $second = $this->category('move_second_parent');
        $leaf = $this->category('move_leaf', $first->id);

        $moved = $this->service()->move(
            $this->admin(),
            $leaf,
            $second->id
        );

        $this->assertSame($second->id, $moved->parent_id);
        $this->assertDatabaseHas('business_categories', [
            'id' => $leaf->id,
            'parent_id' => $second->id,
        ]);
    }

    public function test_admin_can_move_unused_subtree(): void
    {
        $root = $this->category('move_subtree_root');
        $child = $this->category('move_subtree_child', $root->id);
        $destination = $this->category('move_subtree_destination');

        $this->service()->move(
            $this->admin(),
            $root,
            $destination->id
        );

        $this->assertSame(
            $destination->id,
            $root->fresh()->parent_id
        );

        $this->assertSame(
            $root->id,
            $child->fresh()->parent_id
        );
    }

    public function test_admin_can_move_unused_category_to_root(): void
    {
        $parent = $this->category('move_to_root_parent');
        $child = $this->category('move_to_root_child', $parent->id);

        $moved = $this->service()->move(
            $this->admin(),
            $child,
            null
        );

        $this->assertNull($moved->parent_id);
    }

    public function test_category_cannot_be_moved_under_its_descendant(): void
    {
        $root = $this->category('move_cycle_root');
        $child = $this->category('move_cycle_child', $root->id);

        $this->expectException(ValidationException::class);

        $this->service()->move(
            $this->admin(),
            $root,
            $child->id
        );
    }

    public function test_category_cannot_be_its_own_parent(): void
    {
        $category = $this->category('move_self_parent');

        $this->expectException(ValidationException::class);

        $this->service()->move(
            $this->admin(),
            $category,
            $category->id
        );
    }

    public function test_assigned_category_cannot_be_moved(): void
    {
        $category = $this->category('move_assigned_leaf');
        $destination = $this->category('move_assigned_destination');
        $this->assign($category);

        $this->expectException(ValidationException::class);

        $this->service()->move(
            $this->admin(),
            $category,
            $destination->id
        );
    }

    public function test_ancestor_of_assigned_category_cannot_be_moved(): void
    {
        $root = $this->category('move_assigned_ancestor');
        $leaf = $this->category('move_assigned_descendant', $root->id);
        $destination = $this->category('move_ancestor_destination');
        $this->assign($leaf);

        $this->expectException(ValidationException::class);

        $this->service()->move(
            $this->admin(),
            $root,
            $destination->id
        );
    }

    public function test_cannot_move_under_assigned_parent(): void
    {
        $destination = $this->category('move_occupied_parent');
        $moving = $this->category('move_unassigned_leaf');
        $this->assign($destination);

        $this->expectException(ValidationException::class);

        $this->service()->move(
            $this->admin(),
            $moving,
            $destination->id
        );
    }

    public function test_cannot_move_under_inactive_parent(): void
    {
        $destination = $this->category('move_inactive_parent');
        $moving = $this->category('move_active_leaf');

        $destination->update(['is_active' => false]);

        $this->expectException(ValidationException::class);

        $this->service()->move(
            $this->admin(),
            $moving,
            $destination->id
        );
    }

    public function test_regular_user_cannot_move_category(): void
    {
        $category = $this->category('move_unauthorized');
        $user = User::factory()->create(['status' => 'active']);

        $this->expectException(AuthorizationException::class);

        $this->service()->move($user, $category, null);
    }

    public function test_invalid_parent_id_is_rejected(): void
    {
        $category = $this->category('move_invalid_parent');

        $this->expectException(ValidationException::class);

        $this->service()->move(
            $this->admin(),
            $category,
            'invalid-id'
        );
    }

    private function service(): BusinessCategoryManagementService
    {
        return app(BusinessCategoryManagementService::class);
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

    private function assign(BusinessCategory $category): void
    {
        $business = Business::query()->create([
            'name' => 'Category move test business',
            'status' => 'active',
        ]);

        $business->categories()->attach($category->id);
    }
}
