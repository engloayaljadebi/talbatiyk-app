<?php

/*
|--------------------------------------------------------------------------
| Auth API Controller
|--------------------------------------------------------------------------
|
| Endpoints:
| POST /api/v1/auth/register
| POST /api/v1/auth/login
| GET  /api/v1/auth/me
| POST /api/v1/auth/logout
|
*/

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Auth\LoginRequest;
use App\Http\Requests\Api\V1\Auth\RegisterRequest;
use App\Http\Requests\Api\V1\Auth\UpdateProfileRequest;
use App\Http\Resources\Api\V1\BusinessResource;
use App\Http\Resources\Api\V1\UserResource;
use App\Services\Auth\AuthService;
use App\Services\Business\BusinessCategorySelectionService;
use App\Services\User\UserProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    public function __construct(
        private readonly AuthService $authService,
        private readonly UserProfileService $userProfileService,
    ) {}

    /**
     * إنشاء حساب جديد.
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->authService->register(
            $request->validated(),
        );

        return response()->json([
            'data' => [
                'user' => new UserResource($result['user']),
                'business' => $result['business'] === null
                    ? null
                    : new BusinessResource($result['business']),
                'access_token' => $result['token'],
                'token_type' => 'Bearer',
            ],
        ], 201);
    }

    /**
     * Public list of selectable categories for mobile registration.
     */
    public function registrationCategories(
        BusinessCategorySelectionService $categories,
    ): JsonResponse {
        $items = [];

        foreach ($categories->selectableLeafOptions() as $id => $name) {
            $items[] = [
                'id' => $id,
                'name' => $name,
            ];
        }

        return response()->json(['data' => $items]);
    }

    /**
     * تسجيل الدخول.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login(
            $request->validated(),
        );

        return response()->json([
            'data' => [
                'user' => new UserResource($result['user']),
                'access_token' => $result['token'],
                'token_type' => 'Bearer',
            ],
        ]);
    }

    /**
     * بيانات المستخدم الحالي.
     */
    public function me(Request $request): UserResource
    {
        return new UserResource(
            $request->user()->load('contacts'),
        );
    }

    /**
     * Review status for active business memberships of the authenticated user.
     * The user account itself remains active while its business is reviewed.
     * This endpoint never exposes reviewers, private notes, or other users' data.
     *
     * @response array{data: list<array{business_id: string, shop_status: string|null, supplier_status: string|null, supplier_enabled: bool}>}
     */
    public function businessApprovals(Request $request): JsonResponse
    {
        $businessIds = DB::table('business_memberships as memberships')
            ->join('businesses', 'businesses.id', '=', 'memberships.business_id')
            ->where('memberships.user_id', $request->user()->getKey())
            ->where('memberships.status', 'active')
            ->whereNull('businesses.deleted_at')
            ->distinct()
            ->orderBy('businesses.id')
            ->pluck('businesses.id');

        if ($businessIds->isEmpty()) {
            return response()->json(['data' => []]);
        }

        $items = [];
        foreach ($businessIds as $id) {
            $items[$id] = [
                'business_id' => $id,
                'shop_status' => null,
                'supplier_status' => null,
                'supplier_enabled' => false,
            ];
        }

        $verifications = DB::table('verifications')
            ->whereIn('business_id', $businessIds)
            ->whereIn('verification_type_code', ['shop_approval', 'supplier_approval'])
            ->orderByDesc('requested_at')
            ->orderByDesc('id')
            ->get(['business_id', 'verification_type_code', 'status']);

        // The first row for each type is its latest request.
        foreach ($verifications as $verification) {
            $type = $verification->verification_type_code === 'shop_approval'
                ? 'shop_status'
                : 'supplier_status';

            if ($items[$verification->business_id][$type] === null) {
                $items[$verification->business_id][$type] = $verification->status;
            }
        }

        $enabledSuppliers = DB::table('business_capability_assignments as assignments')
            ->join('business_capabilities as capabilities',
                'capabilities.code', '=', 'assignments.capability_code')
            ->whereIn('assignments.business_id', $businessIds)
            ->where('assignments.capability_code', 'supplier')
            ->whereNull('assignments.disabled_at')
            ->whereNull('capabilities.retired_at')
            ->pluck('assignments.business_id');

        foreach ($enabledSuppliers as $businessId) {
            $items[$businessId]['supplier_enabled'] = true;
        }

        return response()->json(['data' => array_values($items)]);
    }

    /**
     * Update the authenticated user's basic profile identity.
     */
    public function updateProfile(
        UpdateProfileRequest $request,
    ): UserResource {
        return new UserResource(
            $this->userProfileService->update(
                $request->user(),
                $request->validated(),
            ),
        );
    }

    /**
     * تسجيل خروج الجهاز الحالي فقط.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()
            ->currentAccessToken()
            ?->delete();

        return response()->json([
            'message' => 'تم تسجيل الخروج بنجاح.',
        ]);
    }
}
