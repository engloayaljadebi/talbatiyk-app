<?php

/*
|--------------------------------------------------------------------------
| خدمة قراءة أنشطة المستخدم
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إرجاع الأنشطة التي يملك المستخدم عضوية نشطة فيها.
| - تحميل بيانات العرض المطلوبة بكفاءة.
| - منع قراءة نشاط لا توجد للمستخدم عضوية نشطة فيه.
| - إبقاء قواعد الوصول خارج Controller.
|
*/

namespace App\Services\Business;

use App\Models\Business;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class BusinessQueryService
{
    /**
     * جميع الأنشطة التي لدى المستخدم عضوية نشطة فيها.
     *
     * @return Collection<int, Business>
     */
    public function forUser(User $user): Collection
    {
        return Business::query()
            ->whereHas(
                'memberships',
                fn ($query) => $query
                    ->where('user_id', $user->id)
                    ->where('status', 'active'),
            )
            ->with([
                'locations' => fn ($query) => $query
                    ->where('is_primary', true),

                'contacts' => fn ($query) => $query
                    ->where('is_primary', true),

                'capabilities',

                /*
                 * نحمل عضوية المستخدم الحالي فقط.
                 *
                 * هذا يمنع BusinessResource من اختيار عضوية
                 * مستخدم آخر عند وجود عدة أعضاء في النشاط.
                 */
                'memberships' => fn ($query) => $query
                    ->where('user_id', $user->id)
                    ->where('status', 'active')
                    ->with('roles'),
            ])
            ->orderBy('name')
            ->get();
    }

    /**
     * قراءة نشاط واحد بشرط وجود عضوية نشطة للمستخدم.
     *
     * عند عدم وجود الصلاحية نستخدم firstOrFail،
     * وبالتالي لا نكشف وجود النشاط لمستخدم غير عضو.
     */
    public function findForUser(
        User $user,
        string $businessId,
    ): Business {
        return Business::query()
            ->whereKey($businessId)
            ->whereHas(
                'memberships',
                fn ($query) => $query
                    ->where('user_id', $user->id)
                    ->where('status', 'active'),
            )
            ->with([
                'locations',
                'contacts',
                'capabilities',

                'memberships' => fn ($query) => $query
                    ->where('user_id', $user->id)
                    ->where('status', 'active')
                    ->with('roles'),
            ])
            ->firstOrFail();
    }
}
