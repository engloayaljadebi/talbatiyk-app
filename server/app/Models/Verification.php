<?php

/*
|--------------------------------------------------------------------------
| نموذج عملية التوثيق - Verification
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل طلب أو حالة توثيق لمستخدم أو نشاط.
| - دعم دورة pending / approved / rejected / revoked / expired.
| - الاحتفاظ بتاريخ الطلب والمراجعة والانتهاء والإلغاء.
| - ربط العملية بنوع التوثيق.
|
| قاعدة الملكية:
| - user_id موجود => توثيق مستخدم.
| - business_id موجود => توثيق نشاط.
| - قاعدة PostgreSQL تمنع وجود الاثنين معًا.
|
*/

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'verification_type_code',
    'user_id',
    'business_id',
    'requested_by_user_id',
    'reviewed_by_user_id',
    'status',
    'requested_at',
    'reviewed_at',
    'expires_at',
    'revoked_at',
    'review_note',
])]
class Verification extends Model
{
    use HasUuids;

    /**
     * نوع عملية التوثيق.
     */
    public function type(): BelongsTo
    {
        return $this->belongsTo(
            VerificationType::class,
            'verification_type_code',
            'code',
        );
    }

    /**
     * المستخدم محل التوثيق.
     *
     * تكون null عندما يكون التوثيق لنشاط.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * النشاط محل التوثيق.
     *
     * تكون null عندما يكون التوثيق لمستخدم.
     */
    public function business(): BelongsTo
    {
        return $this->belongsTo(Business::class);
    }

    /**
     * المستخدم الذي بدأ طلب التوثيق.
     */
    public function requestedBy(): BelongsTo
    {
        return $this->belongsTo(
            User::class,
            'requested_by_user_id',
        );
    }

    /**
     * المستخدم الإداري الذي راجع الطلب.
     */
    public function reviewedBy(): BelongsTo
    {
        return $this->belongsTo(
            User::class,
            'reviewed_by_user_id',
        );
    }

    /**
     * تحويل التواريخ تلقائيًا.
     */
    protected function casts(): array
    {
        return [
            'requested_at' => 'datetime',
            'reviewed_at' => 'datetime',
            'expires_at' => 'datetime',
            'revoked_at' => 'datetime',
        ];
    }
}
