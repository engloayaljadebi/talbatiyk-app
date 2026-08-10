<?php

/*
|--------------------------------------------------------------------------
| خدمة قراءة وسائل اتصال النشاط - BusinessContactQueryService
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - عرض وسائل الاتصال العامة للنشاط.
| - عرض وسائل الاتصال الخاصة بفرع.
| - جلب وسيلة اتصال واحدة.
| - التأكد من أن الفرع تابع للنشاط الموجود في URL.
| - منع كشف وسائل اتصال نشاط أو فرع آخر.
|
| الصلاحيات:
| - أي عضو active داخل النشاط يستطيع القراءة.
|
*/

namespace App\Services\Business;

use App\Models\BusinessContact;
use App\Models\BusinessLocation;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class BusinessContactQueryService
{
    public function __construct(
        private readonly BusinessAccessService $businessAccessService,
    ) {}

    /**
     * وسائل الاتصال العامة للنشاط.
     *
     * @return Collection<int, BusinessContact>
     */
    public function forBusiness(
        User $user,
        string $businessId,
    ): Collection {
        $this->businessAccessService->activeMembership(
            $user,
            $businessId,
        );

        return BusinessContact::query()
            ->where('business_id', $businessId)
            ->whereNull('business_location_id')
            ->orderBy('type')
            ->orderByDesc('is_primary')
            ->orderBy('label')
            ->get();
    }

    /**
     * وسيلة اتصال عامة واحدة.
     */
    public function findForBusiness(
        User $user,
        string $businessId,
        string $contactId,
    ): BusinessContact {
        $this->businessAccessService->activeMembership(
            $user,
            $businessId,
        );

        return BusinessContact::query()
            ->where('business_id', $businessId)
            ->whereNull('business_location_id')
            ->whereKey($contactId)
            ->firstOrFail();
    }

    /**
     * وسائل الاتصال الخاصة بفرع.
     *
     * @return Collection<int, BusinessContact>
     */
    public function forLocation(
        User $user,
        string $businessId,
        string $locationId,
    ): Collection {
        $this->businessAccessService->activeMembership(
            $user,
            $businessId,
        );

        $this->findLocation(
            $businessId,
            $locationId,
        );

        return BusinessContact::query()
            ->whereNull('business_id')
            ->where('business_location_id', $locationId)
            ->orderBy('type')
            ->orderByDesc('is_primary')
            ->orderBy('label')
            ->get();
    }

    /**
     * وسيلة اتصال واحدة خاصة بفرع.
     */
    public function findForLocation(
        User $user,
        string $businessId,
        string $locationId,
        string $contactId,
    ): BusinessContact {
        $this->businessAccessService->activeMembership(
            $user,
            $businessId,
        );

        $this->findLocation(
            $businessId,
            $locationId,
        );

        return BusinessContact::query()
            ->whereNull('business_id')
            ->where('business_location_id', $locationId)
            ->whereKey($contactId)
            ->firstOrFail();
    }

    /**
     * ضمان أن الموقع تابع للنشاط.
     */
    private function findLocation(
        string $businessId,
        string $locationId,
    ): BusinessLocation {
        return BusinessLocation::query()
            ->where('business_id', $businessId)
            ->whereKey($locationId)
            ->firstOrFail();
    }
}
