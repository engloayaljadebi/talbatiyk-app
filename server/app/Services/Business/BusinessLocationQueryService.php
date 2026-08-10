<?php

/*
|--------------------------------------------------------------------------
| خدمة قراءة مواقع النشاط - BusinessLocationQueryService
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - عرض مواقع النشاط للمستخدم صاحب العضوية النشطة.
| - جلب موقع واحد مع التأكد من انتمائه للنشاط.
| - منع الوصول إلى مواقع نشاط آخر.
| - إرجاع 404 بدل كشف وجود الموارد للمستخدم غير المصرح.
|
*/

namespace App\Services\Business;

use App\Models\BusinessLocation;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class BusinessLocationQueryService
{
    public function __construct(
        private readonly BusinessAccessService $businessAccessService,
    ) {}

    /**
     * عرض جميع مواقع النشاط.
     *
     * العضو active يستطيع القراءة مهما كان دوره.
     *
     * @return Collection<int, BusinessLocation>
     */
    public function forUser(
        User $user,
        string $businessId,
    ): Collection {
        /*
         * عدم وجود عضوية active ينتج 404.
         */
        $this->businessAccessService->activeMembership(
            $user,
            $businessId,
        );

        return BusinessLocation::query()
            ->where('business_id', $businessId)
            ->orderByDesc('is_primary')
            ->orderBy('name')
            ->get();
    }

    /**
     * جلب موقع واحد داخل النشاط.
     *
     * يجب أن:
     * - يكون المستخدم عضوًا active.
     * - يكون الموقع تابعًا للنشاط الموجود في URL.
     */
    public function findForUser(
        User $user,
        string $businessId,
        string $locationId,
    ): BusinessLocation {
        $this->businessAccessService->activeMembership(
            $user,
            $businessId,
        );

        return BusinessLocation::query()
            ->where('business_id', $businessId)
            ->whereKey($locationId)
            ->firstOrFail();
    }
}
