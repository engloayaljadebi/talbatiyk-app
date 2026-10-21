<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable([
    'code',
    'name_ar',
    'parent_id',
    'is_active',
    'sort_order',
])]
class BusinessCategory extends Model
{
    use HasUuids;

    protected $table = 'business_categories';

    public function parent(): BelongsTo
    {
        return $this->belongsTo(
            self::class,
            'parent_id',
        );
    }

    public function children(): HasMany
    {
        return $this->hasMany(
            self::class,
            'parent_id',
        );
    }

    public function businesses(): BelongsToMany
    {
        return $this->belongsToMany(
            Business::class,
            'business_category_assignments',
            'category_id',
            'business_id',
        )->withPivot('created_at');
    }

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }
}
