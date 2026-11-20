<?php

namespace Tests\Support;

use App\Models\Business;
use App\Models\BusinessCategory;
use App\Models\User;

trait BuildsBusinessMarkets
{
    private function market(string $code = 'test_market'): BusinessCategory
    {
        return BusinessCategory::query()->firstOrCreate(
            ['code' => $code],
            ['name_ar' => $code, 'is_active' => true],
        );
    }

    private function joinMarket(User $user, BusinessCategory $category): void
    {
        $business = Business::query()->create([
            'name' => 'Discovery buyer',
            'status' => 'active',
        ]);

        $business->memberships()->create([
            'user_id' => $user->id,
            'status' => 'active',
        ]);
        $business->categories()->attach($category->id);
    }
}
