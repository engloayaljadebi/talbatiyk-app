<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'supplier_id',
    'name',
    'description',
    'category',
    'brand',
    'price',
    'quantity',
    'is_available',
    'image_url',
    'colors',
    'discount',
    'rating',
])]
class Product extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'quantity' => 'integer',
            'is_available' => 'boolean',
            'colors' => 'array',
            'discount' => 'decimal:2',
            'rating' => 'decimal:2',
            'deleted_at' => 'datetime',
        ];
    }

    public function supplier(): BelongsTo
    {
        return $this->belongsTo(Business::class, 'supplier_id');
    }
}
