<?php

namespace Tests\Feature;

use App\Models\BusinessCategory;
use App\Services\Business\BusinessCategorySelectionService;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class BusinessCategorySelectionTest extends TestCase
{
    use DatabaseTransactions;

    public function test_active_leaf_category_is_accepted(): void
    {
        $parent = $this->category('parent_selection_test');
        $leaf = $this->category('leaf_selection_test', $parent->id);

        $result = app(BusinessCategorySelectionService::class)
            ->validate([$leaf->id]);

        $this->assertCount(1, $result);
        $this->assertSame($leaf->id, $result->first()->id);
    }

    public function test_empty_selection_is_rejected(): void
    {
        $this->expectException(ValidationException::class);

        app(BusinessCategorySelectionService::class)->validate([]);
    }

    public function test_parent_category_is_rejected(): void
    {
        $parent = $this->category('parent_rejected_test');
        $this->category('child_of_parent_test', $parent->id);

        $this->expectException(ValidationException::class);

        app(BusinessCategorySelectionService::class)
            ->validate([$parent->id]);
    }

    public function test_inactive_category_is_rejected(): void
    {
        $category = $this->category('inactive_selection_test');
        $category->update(['is_active' => false]);

        $this->expectException(ValidationException::class);

        app(BusinessCategorySelectionService::class)
            ->validate([$category->id]);
    }

    public function test_inactive_ancestor_is_rejected(): void
    {
        $parent = $this->category('inactive_parent_test');
        $leaf = $this->category('active_child_test', $parent->id);

        $parent->update(['is_active' => false]);

        $this->expectException(ValidationException::class);

        app(BusinessCategorySelectionService::class)
            ->validate([$leaf->id]);
    }

    public function test_duplicate_selection_is_rejected(): void
    {
        $category = $this->category('duplicate_selection_test');

        $this->expectException(ValidationException::class);

        app(BusinessCategorySelectionService::class)
            ->validate([$category->id, $category->id]);
    }

    public function test_unknown_category_is_rejected(): void
    {
        $this->expectException(ValidationException::class);

        app(BusinessCategorySelectionService::class)
            ->validate(['00000000-0000-4000-8000-000000000001']);
    }

    private function category(string $code, ?string $parentId = null): BusinessCategory
    {
        return BusinessCategory::create([
            'code' => $code,
            'name_ar' => $code,
            'parent_id' => $parentId,
            'is_active' => true,
            'sort_order' => 0,
        ]);
    }
}
