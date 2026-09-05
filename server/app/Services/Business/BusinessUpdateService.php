<?php

/*
|--------------------------------------------------------------------------
| خدمة تعديل النشاط التجاري - BusinessUpdateService
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التحقق من أن المستخدم يستطيع تعديل النشاط.
| - تعديل البيانات الأساسية المسموح بها فقط.
| - إبقاء منطق التعديل خارج Controller.
| - إعادة تحميل العلاقات المطلوبة بعد التعديل.
|
| البيانات التي تعدلها هذه الخدمة:
| - name
| - legal_name
| - description
|
| لا تعدل هذه الخدمة:
| - status
| - capabilities
| - locations
| - contacts
|
| التحقق من الصلاحيات:
| يتم بواسطة BusinessAccessService.
|
*/

namespace App\Services\Business;

use App\Models\Business;
use App\Models\User;
use Illuminate\Support\Arr;

class BusinessUpdateService
{
    public function __construct(
        private readonly BusinessAccessService $businessAccessService,
    ) {}

    /**
     * تعديل البيانات الأساسية لنشاط تجاري.
     *
     * @param  array<string, mixed>  $data
     */
    public function update(
        User $user,
        string $businessId,
        array $data,
    ): Business {
        /*
         * التحقق أولًا من:
         *
         * - وجود عضوية active.
         * - امتلاك owner أو manager.
         *
         * BusinessAccessService يعيد:
         * - 404 إذا لم توجد عضوية active.
         * - 403 إذا كانت العضوية active لكن الدور غير مسموح.
         */
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        /*
         * نبحث عن النشاط بعد نجاح التحقق من الصلاحية.
         *
         * استخدام findOrFail هنا آمن لأن BusinessAccessService
         * أخفى النشاط أصلًا عن المستخدم غير المصرح له.
         */
        $business = Business::query()
            ->findOrFail($businessId);

        /*
         * UpdateBusinessRequest يضمن أن $data لا يحتوي
         * إلا على الحقول المسموح بها.
         */
        $attributes = Arr::only(
            $data,
            [
                'name',
                'legal_name',
                'description',
            ],
        );

        if ($attributes !== []) {
            $business->fill($attributes);
            $business->save();
        }

        /*
         * نعيد تحميل العلاقات التي يحتاجها BusinessResource.
         *
         * مهم:
         * نحمل عضوية المستخدم الحالي فقط لمنع تسريب
         * عضوية مستخدم آخر داخل الاستجابة.
         */
        $business->load([
            'locations',
            'contacts',
            'capabilities',

            'memberships' => fn ($query) => $query
                ->where('user_id', $user->id)
                ->where('status', 'active')
                ->with('roles'),
        ]);

        return $business;
    }
}
