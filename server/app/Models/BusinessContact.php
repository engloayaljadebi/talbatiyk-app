<?php

/*
|--------------------------------------------------------------------------
| نموذج وسيلة اتصال النشاط - BusinessContact
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل الهاتف أو الواتساب أو البريد أو الموقع الإلكتروني.
| - ربط وسيلة الاتصال إما بالنشاط كاملًا أو بفرع محدد.
| - إنشاء UUID v7 تلقائيًا.
| - دعم الوسيلة الرئيسية.
| - دعم توثيق وسيلة الاتصال.
| - دعم الحذف المنطقي.
|
| قاعدة مهمة:
| - business_id موجود => الوسيلة عامة للنشاط.
| - business_location_id موجود => الوسيلة خاصة بفرع.
| - قاعدة البيانات تمنع وجود الاثنين معًا.
|
*/

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'business_id',
    'business_location_id',
    'type',
    'value',
    'label',
    'is_primary',
    'verified_at',
])]
class BusinessContact extends Model
{
    use HasUuids;
    use SoftDeletes;

    /**
     * النشاط صاحب وسيلة الاتصال العامة.
     *
     * تكون العلاقة null عندما تكون الوسيلة خاصة بفرع.
     */
    public function business(): BelongsTo
    {
        return $this->belongsTo(Business::class);
    }

    /**
     * الفرع صاحب وسيلة الاتصال.
     *
     * تكون العلاقة null عندما تكون الوسيلة عامة للنشاط.
     */
    public function location(): BelongsTo
    {
        return $this->belongsTo(
            BusinessLocation::class,
            'business_location_id',
        );
    }

    /**
     * تحويل أنواع الحقول تلقائيًا.
     */
    protected function casts(): array
    {
        return [
            'is_primary' => 'boolean',
            'verified_at' => 'datetime',
            'deleted_at' => 'datetime',
        ];
    }
}
