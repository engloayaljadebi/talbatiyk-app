<?php

namespace App\Services\Business;

use App\Models\BusinessCategory;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class BusinessCategorySelectionService
{
    /**
     * Validate category IDs and return the selected category models.
     *
     * @param  array<int, string>  $categoryIds
     * @return Collection<int, BusinessCategory>
     */
    public function validate(array $categoryIds)
    {
        if ($categoryIds === []) {
            throw ValidationException::withMessages([
                'category_ids' => 'يجب اختيار فئة نشاط واحدة على الأقل.',
            ]);
        }

        if (count($categoryIds) !== count(array_unique($categoryIds))) {
            throw ValidationException::withMessages([
                'category_ids' => 'لا يمكن تكرار فئة النشاط.',
            ]);
        }

        foreach ($categoryIds as $id) {
            if (! is_string($id) || ! Str::isUuid($id)) {
                throw ValidationException::withMessages([
                    'category_ids' => 'معرّفات الفئات غير صحيحة.',
                ]);
            }
        }

        $categories = BusinessCategory::query()
            ->whereIn('id', $categoryIds)
            ->get();

        if ($categories->count() !== count($categoryIds)) {
            throw ValidationException::withMessages([
                'category_ids' => 'إحدى فئات النشاط غير موجودة.',
            ]);
        }

        foreach ($categories as $category) {
            if (! $category->is_active) {
                throw ValidationException::withMessages([
                    'category_ids' => 'لا يمكن اختيار فئة نشاط معطلة.',
                ]);
            }

            if ($category->children()->exists()) {
                throw ValidationException::withMessages([
                    'category_ids' => 'يجب اختيار الفئات النهائية فقط.',
                ]);
            }

            $visited = [$category->id => true];
            $parentId = $category->parent_id;

            while ($parentId !== null) {
                if (isset($visited[$parentId])) {
                    throw ValidationException::withMessages([
                        'category_ids' => 'شجرة فئات الأنشطة تحتوي على دورة غير صحيحة.',
                    ]);
                }

                $visited[$parentId] = true;

                $parent = BusinessCategory::query()->find($parentId);

                if ($parent === null || ! $parent->is_active) {
                    throw ValidationException::withMessages([
                        'category_ids' => 'إحدى الفئات الرئيسية غير نشطة أو غير موجودة.',
                    ]);
                }

                $parentId = $parent->parent_id;
            }
        }

        return $categories;
    }
}
