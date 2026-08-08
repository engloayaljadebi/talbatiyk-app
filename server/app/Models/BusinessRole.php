<?php

/*
|--------------------------------------------------------------------------
| نموذج دور النشاط - BusinessRole
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل تعريف الدور مرة واحدة فقط.
| - استخدام code كمفتاح أساسي.
| - ربط الدور بجميع العضويات التي تمتلكه.
|
| أمثلة:
| owner
| manager
| staff
|
*/

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

#[Fillable([
    'code',
    'is_active',
])]
class BusinessRole extends Model
{
    /**
     * اسم المفتاح الأساسي.
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
     * العضويات التي تمتلك هذا الدور.
     */
    public function memberships(): BelongsToMany
    {
        return $this->belongsToMany(
            BusinessMembership::class,
            'membership_roles',
            'role_code',
            'membership_id',
            'code',
            'id',
        )->withPivot([
            'assigned_by_membership_id',
            'assigned_at',
        ]);
    }

    /**
     * تحويل أنواع الحقول.
     */
    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }
}
