<?php

namespace App\Services\Business;

use App\Models\BusinessCategory;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

final class BusinessCategoryManagementService
{
    /**
     * Move an unused category or subtree to another active parent.
     *
     * Assigned categories and ancestors of assigned categories
     * cannot be moved through this operation.
     */
    public function move(
        User $admin,
        BusinessCategory $category,
        ?string $newParentId
    ): BusinessCategory {
        Gate::forUser($admin)->authorize('manageBusinessCategories');

        Validator::make(
            ['parent_id' => $newParentId],
            [
                'parent_id' => [
                    'nullable',
                    'uuid',
                    Rule::exists('business_categories', 'id'),
                ],
            ]
        )->validate();

        return DB::transaction(function () use (
            $category,
            $newParentId
        ): BusinessCategory {
            // Serialize moves to prevent two simultaneous moves
            // from introducing a circular category hierarchy.
            DB::select('SELECT pg_advisory_xact_lock(2301, 20261023)');

            $record = BusinessCategory::query()
                ->whereKey($category->id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($record->parent_id === $newParentId) {
                return $record;
            }

            $subtreeIds = [$record->id];
            $visited = [$record->id => true];

            for ($index = 0; $index < count($subtreeIds); $index++) {
                $children = BusinessCategory::query()
                    ->where('parent_id', $subtreeIds[$index])
                    ->lockForUpdate()
                    ->get(['id']);

                foreach ($children as $child) {
                    if (isset($visited[$child->id])) {
                        throw ValidationException::withMessages([
                            'parent_id' => 'تحتوي شجرة الفئات على علاقة دائرية.',
                        ]);
                    }

                    $visited[$child->id] = true;
                    $subtreeIds[] = $child->id;
                }
            }

            if (
                $newParentId !== null
                && isset($visited[$newParentId])
            ) {
                throw ValidationException::withMessages([
                    'parent_id' => 'لا يمكن نقل الفئة داخل أحد فروعها.',
                ]);
            }

            $hasAssignedBusinesses = DB::table(
                'business_category_assignments'
            )
                ->whereIn('category_id', $subtreeIds)
                ->exists();

            if ($hasAssignedBusinesses) {
                throw ValidationException::withMessages([
                    'parent_id' => 'لا يمكن نقل فئة مرتبطة بأنشطة تجارية أو تحتوي على فئات مرتبطة بها.',
                ]);
            }

            $parentId = $newParentId;
            $parentVisited = [];

            while ($parentId !== null) {
                if (isset($parentVisited[$parentId])) {
                    throw ValidationException::withMessages([
                        'parent_id' => 'تحتوي شجرة الفئات على علاقة دائرية.',
                    ]);
                }

                $parentVisited[$parentId] = true;

                $parent = BusinessCategory::query()
                    ->whereKey($parentId)
                    ->lockForUpdate()
                    ->first();

                if ($parent === null || ! $parent->is_active) {
                    throw ValidationException::withMessages([
                        'parent_id' => 'يجب اختيار فئة رئيسية نشطة وصحيحة.',
                    ]);
                }

                if (
                    DB::table('business_category_assignments')
                        ->where('category_id', $parent->id)
                        ->exists()
                ) {
                    throw ValidationException::withMessages([
                        'parent_id' => 'لا يمكن نقل فئة أسفل فئة مرتبطة بأنشطة.',
                    ]);
                }

                $parentId = $parent->parent_id;
            }

            $record->parent_id = $newParentId;
            $record->save();

            return $record;
        });
    }

    /**
     * Create a category after validating its hierarchy and permissions.
     *
     * @param  array<string, mixed>  $input
     */
    /**
     * Update editable category details and activation state.
     *
     * Code and parent changes require separate controlled operations.
     *
     * @param  array<string, mixed>  $input
     */
    public function update(
        User $admin,
        BusinessCategory $category,
        array $input
    ): BusinessCategory {
        Gate::forUser($admin)->authorize('manageBusinessCategories');

        $allowed = ['name_ar', 'sort_order', 'is_active'];

        if (array_diff(array_keys($input), $allowed) !== []) {
            throw ValidationException::withMessages([
                'category' => 'تحتوي البيانات على حقول غير مسموح بتعديلها.',
            ]);
        }

        $data = Validator::make($input, [
            'name_ar' => ['sometimes', 'required', 'string', 'min:2', 'max:150'],
            'sort_order' => ['sometimes', 'required', 'integer', 'min:0'],
            'is_active' => ['sometimes', 'required', 'boolean'],
        ])->validate();

        if ($data === []) {
            throw ValidationException::withMessages([
                'category' => 'يجب تحديد بيانات لتحديث الفئة.',
            ]);
        }

        return DB::transaction(function () use ($category, $data): BusinessCategory {
            $record = BusinessCategory::query()
                ->whereKey($category->id)
                ->lockForUpdate()
                ->firstOrFail();

            if (array_key_exists('is_active', $data)) {
                $enable = (bool) $data['is_active'];

                if ($enable) {
                    $visited = [$record->id => true];
                    $parentId = $record->parent_id;

                    while ($parentId !== null) {
                        if (isset($visited[$parentId])) {
                            throw ValidationException::withMessages([
                                'is_active' => 'تحتوي شجرة الفئات على علاقة دائرية.',
                            ]);
                        }

                        $visited[$parentId] = true;

                        $parent = BusinessCategory::query()
                            ->whereKey($parentId)
                            ->lockForUpdate()
                            ->first();

                        if ($parent === null || ! $parent->is_active) {
                            throw ValidationException::withMessages([
                                'is_active' => 'يجب تفعيل الفئات الرئيسية أولًا.',
                            ]);
                        }

                        $parentId = $parent->parent_id;
                    }
                } elseif ($record->is_active) {
                    $subtreeIds = [$record->id];
                    $visited = [$record->id => true];

                    for ($index = 0; $index < count($subtreeIds); $index++) {
                        $children = BusinessCategory::query()
                            ->where('parent_id', $subtreeIds[$index])
                            ->lockForUpdate()
                            ->get(['id']);

                        foreach ($children as $child) {
                            if (isset($visited[$child->id])) {
                                throw ValidationException::withMessages([
                                    'is_active' => 'تحتوي شجرة الفئات على علاقة دائرية.',
                                ]);
                            }

                            $visited[$child->id] = true;
                            $subtreeIds[] = $child->id;
                        }
                    }

                    $hasAssignments = DB::table('business_category_assignments')
                        ->whereIn('category_id', $subtreeIds)
                        ->exists();

                    if ($hasAssignments) {
                        throw ValidationException::withMessages([
                            'is_active' => 'لا يمكن تعطيل فئة مرتبطة بأنشطة تجارية أو تحتوي على فئات مرتبطة بأنشطة.',
                        ]);
                    }
                }
            }

            $record->fill($data);
            $record->save();

            return $record;
        });
    }

    public function create(User $admin, array $input): BusinessCategory
    {
        Gate::forUser($admin)->authorize('manageBusinessCategories');

        $data = Validator::make($input, [
            'code' => [
                'required',
                'string',
                'max:80',
                'regex:/^[a-z][a-z0-9_]*$/',
                Rule::unique('business_categories', 'code'),
            ],
            'name_ar' => ['required', 'string', 'min:2', 'max:150'],
            'parent_id' => [
                'nullable',
                'uuid',
                Rule::exists('business_categories', 'id'),
            ],
            'is_active' => ['required', 'boolean'],
            'sort_order' => ['required', 'integer', 'min:0'],
        ])->validate();

        return DB::transaction(function () use ($data): BusinessCategory {
            $parentId = $data['parent_id'] ?? null;
            $visited = [];

            while ($parentId !== null) {
                if (isset($visited[$parentId])) {
                    throw ValidationException::withMessages([
                        'parent_id' => 'تحتوي شجرة الفئات على علاقة دائرية.',
                    ]);
                }

                $visited[$parentId] = true;

                $parent = BusinessCategory::query()
                    ->whereKey($parentId)
                    ->lockForUpdate()
                    ->first();

                if ($parent === null || ! $parent->is_active) {
                    throw ValidationException::withMessages([
                        'parent_id' => 'يجب اختيار فئة رئيسية نشطة وصحيحة.',
                    ]);
                }

                if (
                    DB::table('business_category_assignments')
                        ->where('category_id', $parent->id)
                        ->exists()
                ) {
                    throw ValidationException::withMessages([
                        'parent_id' => 'لا يمكن تحويل فئة مرتبطة بأنشطة إلى فئة رئيسية.',
                    ]);
                }

                $parentId = $parent->parent_id;
            }

            return BusinessCategory::query()->create($data);
        });
    }
}
