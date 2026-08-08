<?php

/*
|--------------------------------------------------------------------------
| نموذج فترة دوام استثنائية - BusinessDayOverrideInterval
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل فترة عمل داخل يوم استثنائي.
| - دعم أكثر من فترة في اليوم نفسه.
| - دعم الفترة الممتدة بعد منتصف الليل.
| - ربط الفترة بالاستثناء الذي تتبع له.
|
*/

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'business_day_override_id',
    'opens_at',
    'closes_at',
    'end_day_offset',
])]
class BusinessDayOverrideInterval extends Model
{
    use HasUuids;

    /**
     * اليوم الاستثنائي الذي تتبع له هذه الفترة.
     */
    public function override(): BelongsTo
    {
        return $this->belongsTo(
            BusinessDayOverride::class,
            'business_day_override_id',
        );
    }

    /**
     * تحويل القيم الرقمية تلقائيًا.
     */
    protected function casts(): array
    {
        return [
            'end_day_offset' => 'integer',
        ];
    }
}
