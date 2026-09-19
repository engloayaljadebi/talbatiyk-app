<?php

namespace App\Http\Controllers\Api\V1\Follow;

use App\Http\Controllers\Controller;
use App\Models\Business;
use App\Services\Follow\SupplierFollowService;
use Dedoc\Scramble\Attributes\Response;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SupplierFollowController extends Controller
{
    public function __construct(
        private readonly SupplierFollowService $service,
    ) {}

    /**
     * حالة متابعة المستخدم الحالي للمورد.
     */
    public function show(
        Request $request,
        Business $business,
    ): JsonResponse {
        return $this->followResponse(
            $business,
            $this->service->isFollowing(
                $request->user(),
                $business,
            ),
        );
    }

    /**
     * متابعة المورد.
     *
     * العملية idempotent؛ تكرار الطلب لا ينشئ علاقة ثانية.
     */
    #[Response(
        422,
        'The business is not an active followable supplier.',
        type: 'array{message: string, errors: array{business_id: string[]}}',
    )]
    public function store(
        Request $request,
        Business $business,
    ): JsonResponse {
        $this->service->follow(
            $request->user(),
            $business,
        );

        return $this->followResponse(
            $business,
            true,
        );
        /**
         * متابعة المورد.
         *
         * العملية idempotent؛ تكرار الطلب لا ينشئ علاقة ثانية.
         */
    }

    /**
     * إلغاء متابعة المورد.
     *
     * العملية idempotent؛ إلغاء متابعة غير موجودة لا يعتبر خطأ.
     */
    public function destroy(
        Request $request,
        Business $business,
    ): JsonResponse {
        $this->service->unfollow(
            $request->user(),
            $business,
        );

        return $this->followResponse(
            $business,
            false,
        );
    }

    /**
     * شكل الاستجابة الموحد لحالة Follow.
     */
    private function followResponse(
        Business $business,
        bool $isFollowing,
    ): JsonResponse {
        return response()->json([
            'data' => [
                /** @format uuid */
                'business_id' => $business->id,
                'is_following' => $isFollowing,
            ],
        ]);
    }
}
