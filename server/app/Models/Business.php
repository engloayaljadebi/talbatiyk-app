<?php

/*
|--------------------------------------------------------------------------
| نموذج النشاط التجاري - Business
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل الهوية الأساسية للنشاط التجاري.
| - إنشاء UUID v7 تلقائيًا.
| - ربط النشاط بمواقعه وفروعه.
| - دعم الحذف المنطقي.
|
| لا نخزن هنا:
| - الهاتف أو البريد.
| - العنوان.
| - الدوام.
| - نوع النشاط كمورد أو متجر.
|
*/

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'name',
    'legal_name',
    'description',
    'status',
])]
class Business extends Model
{
    use HasUuids;
    use SoftDeletes;

    /**
     * جميع المواقع والفروع التابعة للنشاط.
     */
    public function locations(): HasMany
    {
        return $this->hasMany(BusinessLocation::class);
    }

    /**
     * وسائل الاتصال العامة الخاصة بالنشاط.
     *
     * لا تشمل وسائل الاتصال الخاصة بالفروع.
     */
    public function contacts(): HasMany
    {
        return $this->hasMany(BusinessContact::class);
    }

    /**
     * القدرات التجارية الخاصة بالنشاط.
     *
     * يمكن للنشاط أن يكون:
     * - موردًا.
     * - متجرًا.
     * - موردًا ومتجرًا في الوقت نفسه.
     */
    public function capabilities(): BelongsToMany
    {
        return $this->belongsToMany(
            BusinessCapability::class,
            'business_capability_assignments',
            'business_id',
            'capability_code',
            'id',
            'code',
        )->withPivot([
            'enabled_by_membership_id',
            'enabled_at',
            'disabled_at',
        ]);
    }

    /**
     * جميع عضويات المستخدمين داخل النشاط.
     */
    public function memberships(): HasMany
    {
        return $this->hasMany(BusinessMembership::class);
    }

    /**
     * عمليات التوثيق الخاصة بالنشاط التجاري.
     */
    public function verifications(): HasMany
    {
        return $this->hasMany(Verification::class);
    }

    /**
     * عناصر الطلبات التي يكون هذا النشاط موردًا لها.
     */
    public function suppliedOrderItems(): HasMany
    {
        return $this->hasMany(
            OrderItem::class,
            'supplier_id',
        );
    }

    /**
     * تحويل أنواع الحقول تلقائيًا.
     */
    protected function casts(): array
    {
        return [
            'deleted_at' => 'datetime',
        ];
    }

    /**
     * المنتجات التي يوفرها هذا النشاط بصفته مورداً.
     */
    public function suppliedProducts(): HasMany
    {
        return $this->hasMany(Product::class, 'supplier_id');
    }
}
