<?php

/*
|--------------------------------------------------------------------------
| نموذج دوام موقع النشاط - BusinessHour
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل فترة دوام أسبوعية لفرع أو موقع.
| - دعم أكثر من فترة في اليوم نفسه.
| - دعم الدوام الممتد بعد منتصف الليل.
| - ربط فترة الدوام بموقع النشاط.
|
| day_of_week:
| 1 = الاثنين
| 2 = الثلاثاء
| ...
| 7 = الأحد
|
| end_day_offset:
| 0 = الإغلاق في اليوم نفسه.
| 1 = الإغلاق في اليوم التالي.
|
*/

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'business_location_id',
    'day_of_week',
    'opens_at',
    'closes_at',
    'end_day_offset',
])]
class BusinessHour extends Model
{
    use HasUuids;

    /**
     * الموقع أو الفرع الذي تتبع له فترة الدوام.
     */
    public function location(): BelongsTo
    {
        return $this->belongsTo(
            BusinessLocation::class,
            'business_location_id',
        );
    }

    /**
     * تحويل الحقول الرقمية تلقائيًا.
     */
    protected function casts(): array
    {
        return [
            'day_of_week' => 'integer',
            'end_day_offset' => 'integer',
        ];
    }
}
