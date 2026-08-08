<?php

/*
|--------------------------------------------------------------------------
| نموذج عضوية النشاط - BusinessMembership
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - ربط مستخدم واحد بنشاط تجاري واحد.
| - تمثيل حالة العضوية داخل النشاط.
| - ربط العضوية بالأدوار مثل owner وmanager.
| - الاحتفاظ بتاريخ الانضمام والمغادرة.
|
| ملاحظات:
| - بيانات المستخدم لا تتكرر هنا.
| - بيانات النشاط لا تتكرر هنا.
| - الدور لا يخزن مباشرة في هذا الجدول.
|
*/

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

#[Fillable([
    'user_id',
    'business_id',
    'status',
    'joined_at',
    'left_at',
])]
class BusinessMembership extends Model
{
    use HasUuids;

    /**
     * المستخدم صاحب العضوية.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * النشاط الذي تنتمي إليه العضوية.
     */
    public function business(): BelongsTo
    {
        return $this->belongsTo(Business::class);
    }

    /**
     * الأدوار الممنوحة لهذه العضوية.
     *
     * مثل:
     * owner
     * manager
     * staff
     */
    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(
            BusinessRole::class,
            'membership_roles',
            'membership_id',
            'role_code',
            'id',
            'code',
        )->withPivot([
            'assigned_by_membership_id',
            'assigned_at',
        ]);
    }

    /**
     * تحويل حقول التاريخ تلقائيًا.
     */
    protected function casts(): array
    {
        return [
            'joined_at' => 'datetime',
            'left_at' => 'datetime',
        ];
    }
}
