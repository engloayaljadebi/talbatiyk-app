<?php

/*
|--------------------------------------------------------------------------
| خدمة صلاحيات النشاط التجاري - BusinessAccessService
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - العثور على عضوية المستخدم النشطة داخل النشاط.
| - إخفاء النشاط عن المستخدم الذي لا يملك عضوية نشطة فيه.
| - التحقق من الأدوار المسموح لها بإدارة النشاط.
| - إبقاء قواعد الصلاحيات خارج Controllers.
|
| قواعد الوصول الحالية:
| - owner   : مسموح له بإدارة وتعديل النشاط.
| - manager : مسموح له بإدارة وتعديل النشاط.
| - staff   : لا يملك صلاحية تعديل بيانات النشاط الأساسية.
|
| ملاحظات أمنية:
| - عدم وجود عضوية active يعامل كـ 404.
| - العضوية suspended أو left تعامل كـ 404.
| - العضو النشط بدون الدور المطلوب يحصل على 403.
|
*/

namespace App\Services\Business;

use App\Models\BusinessMembership;
use App\Models\User;
use Illuminate\Auth\Access\AuthorizationException;

class BusinessAccessService
{
    /**
     * الأدوار المسموح لها بتعديل
     * البيانات الأساسية للنشاط.
     *
     * @var list<string>
     */
    private const UPDATE_ROLES = [
        'owner',
        'manager',
    ];

    /**
     * إرجاع عضوية المستخدم النشطة داخل النشاط.
     *
     * عدم وجود النشاط ضمن عضويات المستخدم النشطة
     * يؤدي إلى 404 بواسطة firstOrFail().
     *
     * بذلك لا نكشف للمستخدم غير المصرح له
     * ما إذا كان النشاط موجودًا أصلًا أم لا.
     */
    public function activeMembership(
        User $user,
        string $businessId,
    ): BusinessMembership {
        return BusinessMembership::query()
            ->where('business_id', $businessId)
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->with([
                /*
                 * نحمل الأدوار النشطة فقط.
                 *
                 * إذا تم تعطيل دور عالميًا فلا يجب أن
                 * يستمر في منح الصلاحيات للعضويات القديمة.
                 */
                'roles' => fn ($query) => $query
                    ->where('business_roles.is_active', true),
            ])
            ->firstOrFail();
    }

    /**
     * التأكد من أن المستخدم يستطيع تعديل النشاط.
     *
     * owner و manager مسموح لهما.
     * أي عضو active آخر يحصل على 403.
     *
     * @throws AuthorizationException
     */
    public function ensureCanUpdate(
        User $user,
        string $businessId,
    ): BusinessMembership {
        $membership = $this->activeMembership(
            $user,
            $businessId,
        );

        $canUpdate = $membership->roles->contains(
            fn ($role): bool => in_array(
                $role->code,
                self::UPDATE_ROLES,
                true,
            ),
        );

        if (! $canUpdate) {
            throw new AuthorizationException(
                'ليس لديك صلاحية لتعديل هذا النشاط.',
            );
        }

        return $membership;
    }
}
