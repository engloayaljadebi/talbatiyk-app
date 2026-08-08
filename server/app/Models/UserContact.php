<?php

/*
|--------------------------------------------------------------------------
| نموذج وسيلة اتصال المستخدم - UserContact
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل الهاتف أو البريد المرتبط بحساب المستخدم.
| - إنشاء UUID v7 تلقائيًا لكل وسيلة اتصال.
| - ربط وسيلة الاتصال بالمستخدم صاحبها.
| - دعم وسيلة اتصال رئيسية لكل نوع.
| - دعم توثيق الهاتف أو البريد.
| - دعم الحذف المنطقي.
|
| ملاحظات:
| - الهاتف والبريد لا يخزنان داخل users.
| - value يحتوي القيمة الموحدة فقط.
| - الهاتف سيخزن لاحقًا بصيغة E.164.
| - البريد سيخزن بصيغة lowercase.
|
*/

namespace App\Models;

use Database\Factories\UserContactFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'user_id',
    'type',
    'value',
    'is_primary',
    'verified_at',
])]
class UserContact extends Model
{
    /** @use HasFactory<UserContactFactory> */
    use HasFactory;

    use HasUuids;
    use SoftDeletes;

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

    /**
     * المستخدم صاحب وسيلة الاتصال.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
