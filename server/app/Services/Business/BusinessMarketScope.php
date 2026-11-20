<?php

namespace App\Services\Business;

use App\Models\Business;
use App\Models\BusinessCategory;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class BusinessMarketScope
{
    /** @return list<string> */
    public function categoryIdsFor(User $user): array
    {
        $assignedIds = Business::query()
            ->where('status', 'active')
            ->whereHas('memberships', fn ($query) => $query
                ->where('user_id', $user->id)
                ->where('status', 'active'))
            ->with('categories')
            ->get()
            ->flatMap(fn (Business $business) => $business->categories->modelKeys())
            ->unique();

        if ($assignedIds->isEmpty()) {
            return [];
        }

        $categories = BusinessCategory::query()
            ->where('is_active', true)
            ->get(['id', 'parent_id'])
            ->keyBy('id');

        $marketIds = $assignedIds
            ->map(fn (string $id) => $this->rootId($id, $categories))
            ->filter()
            ->unique()
            ->values();

        if ($marketIds->count() !== 1) {
            return [];
        }

        return $categories
            ->filter(fn (BusinessCategory $category) => $this->rootId($category->id, $categories) === $marketIds->first())
            ->modelKeys();
    }

    /** @param Collection<string, BusinessCategory> $categories */
    private function rootId(string $id, Collection $categories): ?string
    {
        $visited = [];

        while (! isset($visited[$id])) {
            $category = $categories->get($id);
            if ($category === null) {
                return null;
            }

            if ($category->parent_id === null) {
                return $id;
            }

            $visited[$id] = true;
            $id = $category->parent_id;
        }

        return null;
    }
}
