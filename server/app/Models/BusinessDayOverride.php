<?php

/*
|--------------------------------------------------------------------------
| نموذج استثناء دوام يوم محدد - BusinessDayOverride
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل يوم يختلف عن الدوام الأسبوعي المعتاد.
| - دعم إغلاق الموقع طوال اليوم.
| - دعم ساعات عمل مخصصة لتاريخ معين.
| - ربط الاستثناء بالموقع التجاري.
|
| mode:
| - closed       => مغلق طوال اليوم.
| - custom_hours => استخدم الفترات الموجودة في intervals.
|
*/

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable([
    'business_location_id',
    'date',
    'mode',
    'reason',
])]
class BusinessDayOverride extends Model
{
    use HasUuids;

    /**
     * الموقع الذي يطبق عليه هذا الاستثناء.
     */
    public function location(): BelongsTo
    {
        return $this->belongsTo(
            BusinessLocation::class,
            'business_location_id',
        );
    }

    /**
     * فترات العمل الخاصة بهذا اليوم الاستثنائي.
     *
     * تستخدم فقط عندما يكون mode = custom_hours.
     */
    public function intervals(): HasMany
    {
        return $this->hasMany(
            BusinessDayOverrideInterval::class,
            'business_day_override_id',
        );
    }

    /**
     * تحويل التاريخ تلقائيًا.
     */
    protected function casts(): array
    {
        return [
            'date' => 'date',
        ];
    }
}
