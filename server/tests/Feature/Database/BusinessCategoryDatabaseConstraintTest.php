<?php

namespace Tests\Feature\Database;

use App\Models\Business;
use App\Models\BusinessCategory;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class BusinessCategoryDatabaseConstraintTest extends TestCase
{
    use DatabaseTransactions;

    public function test_database_rejects_second_category_for_same_business(): void
    {
        $business = Business::create([
            'name' => 'Single category database test',
        ]);

        $first = $this->category('db_constraint_first');
        $second = $this->category('db_constraint_second');

        $business->categories()->attach($first->id);

        $exception = null;

        try {
            DB::transaction(function () use ($business, $second): void {
                $business->categories()->attach($second->id);
            });
        } catch (QueryException $caught) {
            $exception = $caught;
        }

        $this->assertNotNull(
            $exception,
            'The database must reject a second category.'
        );

        $this->assertSame(
            '23505',
            $exception->errorInfo[0] ?? null
        );

        $this->assertSame(
            [$first->id],
            $business->categories()
                ->pluck('business_categories.id')
                ->all()
        );
    }

    public function test_different_businesses_can_share_the_same_category(): void
    {
        $firstBusiness = Business::create([
            'name' => 'First shared category business',
        ]);

        $secondBusiness = Business::create([
            'name' => 'Second shared category business',
        ]);

        $category = $this->category('db_constraint_shared');

        $firstBusiness->categories()->attach($category->id);
        $secondBusiness->categories()->attach($category->id);

        $this->assertSame(
            1,
            $firstBusiness->categories()->count()
        );

        $this->assertSame(
            1,
            $secondBusiness->categories()->count()
        );

        $this->assertSame(
            2,
            $category->businesses()->count()
        );
    }

    private function category(string $code): BusinessCategory
    {
        return BusinessCategory::create([
            'code' => $code,
            'name_ar' => $code,
            'is_active' => true,
            'sort_order' => 0,
        ]);
    }
}
