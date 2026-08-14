<?php

/*
|--------------------------------------------------------------------------
| نموذج المستخدم - User
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تمثيل حساب المستخدم الأساسي داخل النظام.
| - إنشاء UUID v7 تلقائيًا عند إنشاء المستخدم.
| - دعم Laravel Sanctum لتوثيق تطبيق Flutter.
| - تشفير كلمة المرور تلقائيًا.
| - دعم الحذف المنطقي للحساب.
|
| ملاحظات معمارية:
| - الهاتف والبريد لا يخزنان في users.
| - وسائل الاتصال موجودة في user_contacts.
| - بيانات النشاط التجاري موجودة في businesses.
| - علاقة المستخدم بالنشاط موجودة في business_memberships.
| - التوثيق موجود في verifications.
|
*/

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

/**
 * حساب المستخدم الأساسي في منصة طلبيتك.
 */
#[Fillable([
    'username',
    'display_name',
    'password',
    'status',
    'last_login_at',
])]
#[Hidden([
    'password',
    'remember_token',
])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens;

    use HasFactory;
    use HasUuids;
    use Notifiable;
    use SoftDeletes;

    /**
     * تحويل أنواع الحقول تلقائيًا عند القراءة والكتابة.
     *
     * password:
     * يتم تشفيرها بواسطة Laravel عند تعيينها.
     *
     * last_login_at:
     * تتحول إلى كائن تاريخ ووقت.
     */
    /**
     * جميع وسائل الاتصال المرتبطة بالمستخدم.
     *
     * يمكن أن يحتوي المستخدم على:
     * - هاتف.
     * - بريد.
     * - أكثر من وسيلة من النوع نفسه.
     */
    public function contacts(): HasMany
    {
        return $this->hasMany(UserContact::class);
    }

    /**
     * جميع عضويات المستخدم في الأنشطة التجارية.
     */
    public function memberships(): HasMany
    {
        return $this->hasMany(BusinessMembership::class);
    }

    /**
     * عمليات التوثيق التي تخص هذا المستخدم.
     */
    public function verifications(): HasMany
    {
        return $this->hasMany(Verification::class);
    }

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'last_login_at' => 'datetime',
            'deleted_at' => 'datetime',
        ];
    }
}
