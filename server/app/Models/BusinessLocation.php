<?php

/*
|--------------------------------------------------------------------------
| نموذج موقع النشاط - BusinessLocation
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل فرع أو متجر أو مكتب أو مخزن.
| - ربط الموقع بالنشاط التجاري.
| - تخزين العنوان والمنطقة الزمنية والإحداثيات.
| - دعم تحديد الموقع الرئيسي.
| - دعم الحذف المنطقي.
|
*/

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'business_id',
    'name',
    'type',
    'timezone',
    'country_code',
    'administrative_area',
    'locality',
    'district',
    'street_address',
    'address_notes',
    'latitude',
    'longitude',
    'is_primary',
    'status',
])]
class BusinessLocation extends Model
{
    use HasUuids;
    use SoftDeletes;

    /**
     * النشاط التجاري صاحب هذا الموقع.
     */
    public function business(): BelongsTo
    {
        return $this->belongsTo(Business::class);
    }

    /**
     * وسائل الاتصال الخاصة بهذا الفرع فقط.
     */
    public function contacts(): HasMany
    {
        return $this->hasMany(
            BusinessContact::class,
            'business_location_id',
        );
    }

    /**
     * الاستثناءات الخاصة بأيام محددة.
     *
     * مثل:
     * - إجازة العيد.
     * - إغلاق للجرد.
     * - دوام رمضان.
     * - دوام استثنائي في تاريخ معين.
     */
    public function dayOverrides(): HasMany
    {
        return $this->hasMany(
            BusinessDayOverride::class,
            'business_location_id',
        );
    }

    /**
     * فترات الدوام الأسبوعية الخاصة بهذا الموقع.
     *
     * قد يحتوي اليوم نفسه على أكثر من فترة،
     * مثل فترة صباحية وفترة مسائية.
     */
    public function hours(): HasMany
    {
        return $this->hasMany(
            BusinessHour::class,
            'business_location_id',
        );
    }

    /**
     * تحويل أنواع الحقول تلقائيًا.
     */
    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'is_primary' => 'boolean',
            'deleted_at' => 'datetime',
        ];
    }
}
