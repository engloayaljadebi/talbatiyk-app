<?php

/*
|--------------------------------------------------------------------------
| نموذج قدرة النشاط - BusinessCapability
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل نوع قدرة النشاط التجاري مرة واحدة فقط.
| - استخدام code كمفتاح أساسي طبيعي.
| - ربط القدرة بجميع الأنشطة التي تستخدمها.
|
| أمثلة:
| - supplier
| - shop
|
| لا نخزن اسم العرض أو الترجمة هنا؛
| التطبيق يعرض الترجمة المناسبة حسب اللغة.
|
*/

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

#[Fillable([
    'code',
    'retired_at',
])]
class BusinessCapability extends Model
{
    /**
     * المفتاح الأساسي هو code.
     */
    protected $primaryKey = 'code';

    /**
     * المفتاح ليس رقمًا متزايدًا.
     */
    public $incrementing = false;

    /**
     * نوع المفتاح نصي.
     */
    protected $keyType = 'string';

    /**
     * الجدول لا يحتوي created_at وupdated_at.
     */
    public $timestamps = false;

    /**
     * جميع الأنشطة التي تمتلك هذه القدرة.
     */
    public function businesses(): BelongsToMany
    {
        return $this->belongsToMany(
            Business::class,
            'business_capability_assignments',
            'capability_code',
            'business_id',
            'code',
            'id',
        )->withPivot([
            'enabled_by_membership_id',
            'enabled_at',
            'disabled_at',
        ]);
    }

    /**
     * تحويل حقول التاريخ تلقائيًا.
     */
    protected function casts(): array
    {
        return [
            'retired_at' => 'datetime',
        ];
    }
}
