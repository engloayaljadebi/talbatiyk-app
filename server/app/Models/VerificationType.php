<?php

/*
|--------------------------------------------------------------------------
| نموذج نوع التوثيق - VerificationType
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تعريف نوع التوثيق مرة واحدة فقط.
| - تحديد هل النوع يخص مستخدمًا أم نشاطًا.
| - ربط النوع بجميع عمليات التوثيق الخاصة به.
|
| أمثلة:
| identity
| official_business
| business_registration
|
*/

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable([
    'code',
    'subject_kind',
    'retired_at',
])]
class VerificationType extends Model
{
    /**
     * المفتاح الأساسي هو code.
     */
    protected $primaryKey = 'code';

    /**
     * المفتاح نصي وليس رقمًا متزايدًا.
     */
    public $incrementing = false;

    /**
     * نوع المفتاح الأساسي.
     */
    protected $keyType = 'string';

    /**
     * الجدول لا يحتوي created_at وupdated_at.
     */
    public $timestamps = false;

    /**
     * جميع عمليات التوثيق من هذا النوع.
     */
    public function verifications(): HasMany
    {
        return $this->hasMany(
            Verification::class,
            'verification_type_code',
            'code',
        );
    }

    /**
     * تحويل أنواع الحقول.
     */
    protected function casts(): array
    {
        return [
            'retired_at' => 'datetime',
        ];
    }
}
