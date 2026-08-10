<?php

/*
|--------------------------------------------------------------------------
| خدمة إدارة مواقع النشاط - BusinessLocationService
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إنشاء موقع جديد.
| - تعديل بيانات الموقع.
| - حذف الموقع حذفًا منطقيًا.
| - تعيين الموقع الرئيسي.
| - حماية المواقع من الوصول عبر نشاط آخر.
| - إبقاء منطق المواقع خارج Controllers.
|
| الصلاحيات:
| - owner   : إدارة المواقع.
| - manager : إدارة المواقع.
| - staff   : قراءة فقط.
|
| قواعد مهمة:
| - business_id يأتي من URL وليس من Request.
| - is_primary لا يعدل عبر create/update.
| - تعيين الموقع الرئيسي له عملية مستقلة.
| - لا يسمح بحذف الموقع الرئيسي مباشرة.
|
*/

namespace App\Services\Business;

use App\Models\BusinessLocation;
use App\Models\User;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class BusinessLocationService
{
    public function __construct(
        private readonly BusinessAccessService $businessAccessService,
    ) {}

    /**
     * الحقول التي يمكن تعديلها من API المواقع.
     *
     * @var list<string>
     */
    private const MUTABLE_FIELDS = [
        'name',
        'type',
        'timezone',
        'country_code',
        'administrative_area',
        'locality',
        'district',
        'street_address',
        'address_notes',
        'latitude',
        'longitude',
        'status',
    ];

    /**
     * إنشاء موقع جديد داخل النشاط.
     *
     * @param  array<string, mixed>  $data
     */
    public function create(
        User $user,
        string $businessId,
        array $data,
    ): BusinessLocation {
        /*
         * owner و manager فقط.
         */
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        /*
         * Defense in depth:
         * حتى لو وصل حقل إضافي إلى الخدمة
         * فلن يتم تمريره إلى Model.
         */
        $attributes = Arr::only(
            $data,
            self::MUTABLE_FIELDS,
        );

        $attributes['business_id'] = $businessId;

        /*
         * تعيين الرئيسي يتم عبر عملية مستقلة.
         */
        $attributes['is_primary'] = false;

        /*
         * القيمة الافتراضية في قاعدة البيانات active،
         * ونضعها هنا أيضًا لتكون النتيجة واضحة قبل الحفظ.
         */
        $attributes['status'] ??= 'active';

        return BusinessLocation::query()
            ->create($attributes);
    }

    /**
     * تعديل موقع موجود.
     *
     * @param  array<string, mixed>  $data
     */
    public function update(
        User $user,
        string $businessId,
        string $locationId,
        array $data,
    ): BusinessLocation {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        /*
         * نبحث عن الموقع داخل النشاط نفسه.
         *
         * إذا كان الموقع تابعًا لنشاط آخر
         * فالنتيجة 404.
         */
        $location = $this->findLocation(
            $businessId,
            $locationId,
        );

        $attributes = Arr::only(
            $data,
            self::MUTABLE_FIELDS,
        );

        if ($attributes !== []) {
            $location->fill($attributes);
            $location->save();
        }

        return $location->fresh();
    }

    /**
     * حذف موقع حذفًا منطقيًا.
     *
     * لا نحذف الموقع الرئيسي قبل اختيار
     * موقع رئيسي بديل.
     *
     * @throws ValidationException
     */
    public function delete(
        User $user,
        string $businessId,
        string $locationId,
    ): void {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        $location = $this->findLocation(
            $businessId,
            $locationId,
        );

        if ($location->is_primary) {
            throw ValidationException::withMessages([
                'location' => [
                    'لا يمكن حذف الموقع الرئيسي. عيّن موقعًا رئيسيًا آخر أولًا.',
                ],
            ]);
        }

        $location->delete();
    }

    /**
     * تعيين موقع باعتباره الموقع الرئيسي.
     *
     * العملية Transactional حتى لا يصبح للنشاط
     * أكثر من موقع رئيسي أثناء التغيير.
     */
    public function setPrimary(
        User $user,
        string $businessId,
        string $locationId,
    ): BusinessLocation {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        return DB::transaction(
            function () use (
                $businessId,
                $locationId,
            ): BusinessLocation {
                /*
                 * نقفل مواقع النشاط بترتيب ثابت.
                 *
                 * هذا يقلل مشاكل السباق عندما يحاول
                 * طلبان تغيير الموقع الرئيسي في الوقت نفسه.
                 */
                $locations = BusinessLocation::query()
                    ->where('business_id', $businessId)
                    ->orderBy('id')
                    ->lockForUpdate()
                    ->get();

                $location = $locations->firstWhere(
                    'id',
                    $locationId,
                );

                /*
                 * الموقع غير موجود أو تابع لنشاط آخر.
                 */
                abort_if(
                    $location === null,
                    404,
                );

                /*
                 * إذا كان رئيسيًا بالفعل فلا حاجة
                 * لأي تحديث إضافي.
                 */
                if ($location->is_primary) {
                    return $location;
                }

                /*
                 * إزالة الرئيسي السابق.
                 */
                BusinessLocation::query()
                    ->where('business_id', $businessId)
                    ->where('is_primary', true)
                    ->update([
                        'is_primary' => false,
                    ]);

                /*
                 * تعيين الموقع الجديد.
                 */
                $location->is_primary = true;
                $location->save();

                return $location->fresh();
            },
        );
    }

    /**
     * جلب موقع مع ضمان انتمائه للنشاط.
     *
     * SoftDeletes يجعل المواقع المحذوفة
     * غير مرئية تلقائيًا.
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
