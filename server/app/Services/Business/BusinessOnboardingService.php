<?php

/*
|--------------------------------------------------------------------------
| خدمة إنشاء النشاط التجاري - Business Onboarding
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إنشاء النشاط التجاري.
| - إنشاء الموقع الرئيسي للنشاط.
| - إنشاء وسيلة الاتصال الرئيسية.
| - إنشاء عضوية المستخدم المنشئ كمالك.
| - منح العضوية دور owner.
| - تفعيل قدرات النشاط مثل supplier و shop.
| - تنفيذ جميع العمليات داخل Database Transaction واحدة.
|
| قاعدة مهمة:
| إذا فشل أي جزء من عملية الإنشاء:
|
| Business
| Location
| Contact
| Membership
| Role
| Capabilities
|
| يتم التراجع عن جميع العمليات تلقائيًا بواسطة PostgreSQL.
|
*/

namespace App\Services\Business;

use App\Models\Business;
use App\Models\BusinessRole;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class BusinessOnboardingService
{
    /**
     * إنشاء نشاط تجاري كامل للمستخدم الحالي.
     *
     * @param  array<string, mixed>  $data
     */
    public function create(User $user, array $data): Business
    {
        return DB::transaction(function () use ($user, $data): Business {
            /*
             * ------------------------------------------------------------
             * 1. إنشاء الهوية الأساسية للنشاط
             * ------------------------------------------------------------
             *
             * لا نخزن هنا:
             * - العنوان.
             * - الهاتف.
             * - نوع المورد/المتجر.
             *
             * لكل معلومة جدولها المتخصص.
             */
            $business = Business::query()->create([
                'name' => $data['name'],
                'legal_name' => $data['legal_name'] ?? null,
                'description' => $data['description'] ?? null,
                'status' => 'active',
            ]);

            /*
             * ------------------------------------------------------------
             * 2. إنشاء الموقع الرئيسي
             * ------------------------------------------------------------
             */
            $locationData = $data['location'];

            $business->locations()->create([
                'name' => $locationData['name'],
                'type' => $locationData['type'],
                'timezone' => $locationData['timezone'],
                'country_code' => $locationData['country_code'],
                'administrative_area' => $locationData['administrative_area'] ?? null,
                'locality' => $locationData['locality'] ?? null,
                'district' => $locationData['district'] ?? null,
                'street_address' => $locationData['street_address'] ?? null,
                'address_notes' => $locationData['address_notes'] ?? null,
                'latitude' => $locationData['latitude'] ?? null,
                'longitude' => $locationData['longitude'] ?? null,

                /*
                 * أول موقع يتم إنشاؤه أثناء onboarding
                 * هو الموقع الرئيسي تلقائيًا.
                 */
                'is_primary' => true,

                'status' => 'active',
            ]);

            /*
             * ------------------------------------------------------------
             * 3. إنشاء وسيلة الاتصال العامة الرئيسية
             * ------------------------------------------------------------
             *
             * نستخدم business_id فقط.
             *
             * لا نربطها بالموقع الرئيسي لأن هذه الوسيلة
             * تمثل النشاط التجاري كاملًا.
             */
            $contactData = $data['contact'];

            $business->contacts()->create([
                'type' => $contactData['type'],
                'value' => $contactData['value'],
                'label' => $contactData['label'] ?? null,
                'is_primary' => true,

                /*
                 * لا نعتبر الوسيلة موثقة تلقائيًا.
                 * عملية التوثيق ستكون مستقلة لاحقًا.
                 */
                'verified_at' => null,
            ]);

            /*
             * ------------------------------------------------------------
             * 4. إنشاء عضوية مالك النشاط
             * ------------------------------------------------------------
             *
             * لا نخزن owner داخل business_memberships؛
             * العضوية والأدوار منفصلان حسب التصميم.
             */
            $membership = $business->memberships()->create([
                'user_id' => $user->id,
                'status' => 'active',
                'joined_at' => now(),
                'left_at' => null,
            ]);

            /*
             * ------------------------------------------------------------
             * 5. منح المالك دور owner
             * ------------------------------------------------------------
             *
             * نتأكد كذلك أن الدور المرجعي موجود ومفعّل.
             */
            $ownerRoleExists = BusinessRole::query()
                ->where('code', 'owner')
                ->where('is_active', true)
                ->exists();

            if (! $ownerRoleExists) {
                throw new RuntimeException(
                    'The required business owner role is not configured.',
                );
            }

            /*
             * assigned_by_membership_id = null
             *
             * لأن هذه أول عضوية في النشاط،
             * والنظام نفسه هو من يمنح الدور الأول.
             */
            $membership->roles()->attach('owner', [
                'assigned_by_membership_id' => null,
                'assigned_at' => now(),
            ]);

            /*
             * ------------------------------------------------------------
             * 6. تفعيل قدرات النشاط
             * ------------------------------------------------------------
             *
             * مثال:
             *
             * supplier
             * shop
             *
             * تم التحقق من وجود الأكواد مسبقًا
             * داخل CreateBusinessRequest.
             */
            $capabilityAssignments = [];

            foreach ($data['capabilities'] as $capabilityCode) {
                $capabilityAssignments[$capabilityCode] = [
                    /*
                     * المالك الأول هو من فعّل قدرات نشاطه.
                     */
                    'enabled_by_membership_id' => $membership->id,
                    'enabled_at' => now(),
                    'disabled_at' => null,
                ];
            }

            $business->capabilities()->attach($capabilityAssignments);

            /*
             * ------------------------------------------------------------
             * 7. تحميل العلاقات المطلوبة لاستجابة API
             * ------------------------------------------------------------
             *
             * نعيد نفس النشاط بعد تحميل:
             *
             * - الموقع الرئيسي.
             * - الاتصال الرئيسي.
             * - العضوية.
             * - دور المالك.
             * - القدرات.
             */
            return $business->load([
                'locations',
                'contacts',
                'capabilities',
                'memberships.roles',
            ]);
        });
    }
}
