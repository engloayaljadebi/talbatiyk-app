<?php

namespace Tests\Feature;

use App\Models\Business;
use App\Models\BusinessCategory;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

class BusinessCategoryRelationsTest extends TestCase
{
    use DatabaseTransactions;

    public function test_business_can_have_multiple_leaf_categories(): void
    {
        $business = Business::create([
            'name' => 'نشاط اختبار التصنيفات',
        ]);

        $parent = BusinessCategory::create([
            'code' => 'electronics_test',
            'name_ar' => 'الإلكترونيات',
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $first = BusinessCategory::create([
            'code' => 'phones_test',
            'name_ar' => 'الهواتف',
            'parent_id' => $parent->id,
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $second = BusinessCategory::create([
            'code' => 'accessories_test',
            'name_ar' => 'الإكسسوارات',
            'parent_id' => $parent->id,
            'is_active' => true,
            'sort_order' => 2,
        ]);

        $business->categories()->attach([
            $first->id,
            $second->id,
        ]);

        $this->assertSame(2, $business->categories()->count());
        $this->assertSame(2, $parent->children()->count());
        $this->assertSame($parent->id, $first->parent->id);
        $this->assertSame(1, $first->businesses()->count());

        $this->assertDatabaseMissing('business_category_assignments', [
            'business_id' => $business->id,
            'category_id' => $parent->id,
        ]);
    }

    public function test_duplicate_business_category_assignment_is_rejected(): void
    {
        $business = Business::create([
            'name' => 'نشاط اختبار منع التكرار',
        ]);

        $category = BusinessCategory::create([
            'code' => 'stationery_test',
            'name_ar' => 'القرطاسية',
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $business->categories()->attach($category->id);

        $this->expectException(QueryException::class);

        $business->categories()->attach($category->id);
    }

    public function test_category_cannot_be_its_own_parent(): void
    {
        $category = BusinessCategory::create([
            'code' => 'self_parent_test',
            'name_ar' => 'اختبار الأب الذاتي',
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $this->expectException(QueryException::class);

        $category->update([
            'parent_id' => $category->id,
        ]);
    }
}