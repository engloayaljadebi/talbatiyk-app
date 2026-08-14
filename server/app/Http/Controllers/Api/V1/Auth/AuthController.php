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
use App\Http\Resources\Api\V1\UserResource;
use App\Services\Auth\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function __construct(
        private readonly AuthService $authService,
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
                'access_token' => $result['token'],
                'token_type' => 'Bearer',
            ],
        ], 201);
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
