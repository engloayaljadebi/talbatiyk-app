<?php

/*
|--------------------------------------------------------------------------
| خدمة إدارة وسائل اتصال النشاط - BusinessContactService
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إنشاء وسيلة اتصال عامة للنشاط.
| - إنشاء وسيلة اتصال خاصة بفرع.
| - تعديل وحذف وسائل الاتصال.
| - تعيين الوسيلة الرئيسية لكل نوع.
| - منع التكرار داخل نفس النشاط أو الفرع.
| - التحقق من صيغة الهاتف والبريد والموقع.
| - إلغاء التوثيق تلقائيًا عند تغيير القيمة.
|
| الصلاحيات:
| - owner   : إدارة وسائل الاتصال.
| - manager : إدارة وسائل الاتصال.
| - staff   : قراءة فقط.
|
| قواعد أمنية:
| - لا يرسل العميل business_id أو location_id.
| - لا يرسل verified_at.
| - لا يغير type بعد إنشاء الوسيلة.
| - تغيير value يلغي verified_at السابق.
|
*/

namespace App\Services\Business;

use App\Models\BusinessContact;
use App\Models\BusinessLocation;
use App\Models\User;
use App\Support\ContactValueNormalizer;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class BusinessContactService
{
    /**
     * أنواع وسائل الاتصال المعروفة.
     *
     * @var list<string>
     */
    private const TYPES = [
        'phone',
        'whatsapp',
        'email',
        'website',
    ];

    public function __construct(
        private readonly BusinessAccessService $businessAccessService,
    ) {}

    /**
     * إنشاء وسيلة اتصال عامة للنشاط.
     *
     * @param  array<string, mixed>  $data
     */
    public function createForBusiness(
        User $user,
        string $businessId,
        array $data,
    ): BusinessContact {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        $type = $data['type'];
        $value = $this->normalizeAndValidateValue(
            $type,
            $data['value'],
        );

        $this->ensureUniqueValue(
            ownerColumn: 'business_id',
            ownerId: $businessId,
            type: $type,
            value: $value,
        );

        return BusinessContact::query()->create([
            'business_id' => $businessId,
            'business_location_id' => null,
            'type' => $type,
            'value' => $value,
            'label' => $data['label'] ?? null,
            'is_primary' => false,
            'verified_at' => null,
        ]);
    }

    /**
     * إنشاء وسيلة اتصال خاصة بفرع.
     *
     * @param  array<string, mixed>  $data
     */
    public function createForLocation(
        User $user,
        string $businessId,
        string $locationId,
        array $data,
    ): BusinessContact {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        $this->findLocation(
            $businessId,
            $locationId,
        );

        $type = $data['type'];
        $value = $this->normalizeAndValidateValue(
            $type,
            $data['value'],
        );

        $this->ensureUniqueValue(
            ownerColumn: 'business_location_id',
            ownerId: $locationId,
            type: $type,
            value: $value,
        );

        return BusinessContact::query()->create([
            'business_id' => null,
            'business_location_id' => $locationId,
            'type' => $type,
            'value' => $value,
            'label' => $data['label'] ?? null,
            'is_primary' => false,
            'verified_at' => null,
        ]);
    }

    /**
     * تعديل وسيلة اتصال عامة.
     *
     * @param  array<string, mixed>  $data
     */
    public function updateForBusiness(
        User $user,
        string $businessId,
        string $contactId,
        array $data,
    ): BusinessContact {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        $contact = $this->findBusinessContact(
            $businessId,
            $contactId,
        );

        return $this->updateContact(
            $contact,
            $data,
        );
    }

    /**
     * تعديل وسيلة اتصال خاصة بفرع.
     *
     * @param  array<string, mixed>  $data
     */
    public function updateForLocation(
        User $user,
        string $businessId,
        string $locationId,
        string $contactId,
        array $data,
    ): BusinessContact {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        $this->findLocation(
            $businessId,
            $locationId,
        );

        $contact = $this->findLocationContact(
            $locationId,
            $contactId,
        );

        return $this->updateContact(
            $contact,
            $data,
        );
    }

    /**
     * حذف وسيلة اتصال عامة حذفًا منطقيًا.
     */
    public function deleteForBusiness(
        User $user,
        string $businessId,
        string $contactId,
    ): void {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        $contact = $this->findBusinessContact(
            $businessId,
            $contactId,
        );

        $contact->delete();
    }

    /**
     * حذف وسيلة اتصال خاصة بفرع.
     */
    public function deleteForLocation(
        User $user,
        string $businessId,
        string $locationId,
        string $contactId,
    ): void {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        $this->findLocation(
            $businessId,
            $locationId,
        );

        $contact = $this->findLocationContact(
            $locationId,
            $contactId,
        );

        $contact->delete();
    }

    /**
     * تعيين وسيلة اتصال عامة كوسيلة رئيسية
     * من نوعها داخل النشاط.
     */
    public function setPrimaryForBusiness(
        User $user,
        string $businessId,
        string $contactId,
    ): BusinessContact {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        $contact = $this->findBusinessContact(
            $businessId,
            $contactId,
        );

        return $this->setPrimary(
            ownerColumn: 'business_id',
            ownerId: $businessId,
            contact: $contact,
        );
    }

    /**
     * تعيين وسيلة اتصال فرع كوسيلة رئيسية
     * من نوعها داخل الفرع.
     */
    public function setPrimaryForLocation(
        User $user,
        string $businessId,
        string $locationId,
        string $contactId,
    ): BusinessContact {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        $this->findLocation(
            $businessId,
            $locationId,
        );

        $contact = $this->findLocationContact(
            $locationId,
            $contactId,
        );

        return $this->setPrimary(
            ownerColumn: 'business_location_id',
            ownerId: $locationId,
            contact: $contact,
        );
    }

    /**
     * تطبيق PATCH على وسيلة الاتصال.
     *
     * تغيير value يلغي verified_at
     * لأن التوثيق يخص القيمة القديمة.
     *
     * @param  array<string, mixed>  $data
     */
    private function updateContact(
        BusinessContact $contact,
        array $data,
    ): BusinessContact {
        $attributes = Arr::only(
            $data,
            [
                'value',
                'label',
            ],
        );

        if (array_key_exists('value', $attributes)) {
            $normalizedValue = $this->normalizeAndValidateValue(
                $contact->type,
                $attributes['value'],
            );

            $this->ensureUniqueForContact(
                $contact,
                $normalizedValue,
            );

            /*
             * التوثيق مرتبط بالقيمة نفسها.
             * إذا تغيرت القيمة فيجب إعادة التوثيق.
             */
            if ($normalizedValue !== $contact->value) {
                $attributes['verified_at'] = null;
            }

            $attributes['value'] = $normalizedValue;
        }

        if ($attributes !== []) {
            $contact->fill($attributes);
            $contact->save();
        }

        return $contact->fresh();
    }

    /**
     * تعيين Contact كرئيسي داخل مالكه ونوعه.
     */
    private function setPrimary(
        string $ownerColumn,
        string $ownerId,
        BusinessContact $contact,
    ): BusinessContact {
        return DB::transaction(
            function () use (
                $ownerColumn,
                $ownerId,
                $contact,
            ): BusinessContact {
                /*
                 * نقفل جميع وسائل الاتصال من نفس النوع
                 * لنفس المالك لمنع سباق طلبين متزامنين.
                 */
                $contacts = BusinessContact::query()
                    ->where($ownerColumn, $ownerId)
                    ->where('type', $contact->type)
                    ->orderBy('id')
                    ->lockForUpdate()
                    ->get();

                $target = $contacts->firstWhere(
                    'id',
                    $contact->id,
                );

                abort_if(
                    $target === null,
                    404,
                );

                if ($target->is_primary) {
                    return $target;
                }

                BusinessContact::query()
                    ->where($ownerColumn, $ownerId)
                    ->where('type', $target->type)
                    ->where('is_primary', true)
                    ->update([
                        'is_primary' => false,
                    ]);

                $target->is_primary = true;
                $target->save();

                return $target->fresh();
            },
        );
    }

    /**
     * توحيد القيمة والتحقق منها حسب النوع.
     */
    private function normalizeAndValidateValue(
        string $type,
        string $value,
    ): string {
        if (! in_array($type, self::TYPES, true)) {
            throw ValidationException::withMessages([
                'type' => [
                    'نوع وسيلة الاتصال غير مدعوم.',
                ],
            ]);
        }

        $value = ContactValueNormalizer::contact(
            $type,
            $value,
        );

        if (
            in_array($type, ['phone', 'whatsapp'], true)
            && preg_match('/^\+[1-9]\d{7,14}$/', $value) !== 1
        ) {
            throw ValidationException::withMessages([
                'value' => [
                    'يجب أن يكون رقم الهاتف بصيغة دولية E.164 مثل +967777123456.',
                ],
            ]);
        }

        if (
            $type === 'email'
            && filter_var(
                $value,
                FILTER_VALIDATE_EMAIL,
            ) === false
        ) {
            throw ValidationException::withMessages([
                'value' => [
                    'يجب إدخال بريد إلكتروني صحيح.',
                ],
            ]);
        }

        if (
            $type === 'website'
            && filter_var(
                $value,
                FILTER_VALIDATE_URL,
            ) === false
        ) {
            throw ValidationException::withMessages([
                'value' => [
                    'يجب إدخال رابط موقع إلكتروني صحيح.',
                ],
            ]);
        }

        return $value;
    }

    /**
     * منع تكرار Contact لنفس المالك والنوع والقيمة.
     */
    private function ensureUniqueValue(
        string $ownerColumn,
        string $ownerId,
        string $type,
        string $value,
        ?string $exceptContactId = null,
    ): void {
        $query = BusinessContact::query()
            ->where($ownerColumn, $ownerId)
            ->where('type', $type);

        if ($type === 'email') {
            $query->whereRaw(
                'LOWER(value) = ?',
                [strtolower($value)],
            );
        } else {
            $query->where('value', $value);
        }

        if ($exceptContactId !== null) {
            $query->where(
                'id',
                '!=',
                $exceptContactId,
            );
        }

        if ($query->exists()) {
            throw ValidationException::withMessages([
                'value' => [
                    'وسيلة الاتصال هذه موجودة مسبقًا.',
                ],
            ]);
        }
    }

    /**
     * تطبيق فحص التكرار اعتمادًا على
     * مالك Contact الحالي.
     */
    private function ensureUniqueForContact(
        BusinessContact $contact,
        string $value,
    ): void {
        if ($contact->business_id !== null) {
            $this->ensureUniqueValue(
                ownerColumn: 'business_id',
                ownerId: $contact->business_id,
                type: $contact->type,
                value: $value,
                exceptContactId: $contact->id,
            );

            return;
        }

        $this->ensureUniqueValue(
            ownerColumn: 'business_location_id',
            ownerId: $contact->business_location_id,
            type: $contact->type,
            value: $value,
            exceptContactId: $contact->id,
        );
    }

    /**
     * التأكد من أن الفرع تابع للنشاط.
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

    /**
     * وسيلة اتصال عامة تابعة للنشاط.
     */
    private function findBusinessContact(
        string $businessId,
        string $contactId,
    ): BusinessContact {
        return BusinessContact::query()
            ->where('business_id', $businessId)
            ->whereNull('business_location_id')
            ->whereKey($contactId)
            ->firstOrFail();
    }

    /**
     * وسيلة اتصال خاصة بالفرع.
     */
    private function findLocationContact(
        string $locationId,
        string $contactId,
    ): BusinessContact {
        return BusinessContact::query()
            ->whereNull('business_id')
            ->where('business_location_id', $locationId)
            ->whereKey($contactId)
            ->firstOrFail();
    }
}
