<?php

namespace App\Services\Follow;

use App\Models\Business;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Validation\ValidationException;

class SupplierFollowService
{
    /**
     * متابعة مورد فعّال.
     *
     * @return bool true عندما أُنشئت المتابعة الآن، false إذا كانت موجودة مسبقًا.
     */
    public function follow(User $user, Business $business): bool
    {
        $this->ensureFollowableSupplier($business);

        // syncWithoutDetaching يجعل POST idempotent:
        // تكرار Follow لا ينشئ صفًا ثانيًا ولا يكسر المفتاح المركب.
        $changes = $user->followedBusinesses()->syncWithoutDetaching([
            $business->getKey(),
        ]);

        return $changes['attached'] !== [];
    }

    /**
     * إلغاء متابعة المورد.
     *
     * @return bool true عندما حُذفت علاقة موجودة، false إذا لم تكن موجودة.
     */
    public function unfollow(User $user, Business $business): bool
    {
        return $user->followedBusinesses()->detach($business->getKey()) > 0;
    }

    /**
     * هل المستخدم يتابع هذا المورد حاليًا؟
     */
    public function isFollowing(User $user, Business $business): bool
    {
        return $user->followedBusinesses()
            ->whereKey($business->getKey())
            ->exists();
    }

    /**
     * Follow مسموح فقط للنشاط الفعّال الذي يملك
     * supplier capability فعّالة وغير retired.
     */
    private function ensureFollowableSupplier(Business $business): void
    {
        $isFollowable = Business::query()
            ->whereKey($business->getKey())
            ->where('status', 'active')
            ->whereHas(
                'capabilities',
                function (Builder $query): void {
                    $query
                        ->where('business_capabilities.code', 'supplier')
                        ->whereNull('business_capabilities.retired_at')
                        ->whereNull(
                            'business_capability_assignments.disabled_at'
                        );
                }
            )
            ->exists();

        if ($isFollowable) {
            return;
        }

        throw ValidationException::withMessages([
            'business_id' => [
                'The business is not an active followable supplier.',
            ],
        ]);
    }
}
