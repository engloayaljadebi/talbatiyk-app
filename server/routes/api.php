<?php

/*
|--------------------------------------------------------------------------
| API Routes - V1
|--------------------------------------------------------------------------
|
| جميع مسارات تطبيق Flutter تبدأ من:
|
| /api/v1
|
| الأقسام الحالية:
| - Auth API
| - Business API
|
*/

use App\Http\Controllers\Api\V1\Auth\AuthController;
use App\Http\Controllers\Api\V1\Business\BusinessController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    /*
    |--------------------------------------------------------------------------
    | Authentication
    |--------------------------------------------------------------------------
    */

    Route::prefix('auth')->group(function (): void {
        /*
         * إنشاء حساب جديد.
         */
        Route::post('/register', [AuthController::class, 'register'])
            ->middleware('throttle:5,1');

        /*
         * تسجيل الدخول.
         */
        Route::post('/login', [AuthController::class, 'login'])
            ->middleware('throttle:10,1');

        /*
         * المسارات التي تحتاج Token صالحًا.
         */
        Route::middleware('auth:sanctum')->group(function (): void {
            /*
             * قراءة بيانات المستخدم الحالي.
             *
             * يجب أن يكون الحساب نشطًا.
             */
            Route::get('/me', [AuthController::class, 'me'])
                ->middleware('active.user');

            /*
             * تسجيل خروج الجهاز الحالي فقط.
             *
             * لا نضع active.user هنا حتى يستطيع المستخدم
             * الموقوف إلغاء Token الحالي.
             */
            Route::post('/logout', [AuthController::class, 'logout']);
        });
    });

    /*
    |--------------------------------------------------------------------------
    | Businesses
    |--------------------------------------------------------------------------
    |
    | عمليات الأنشطة التجارية تحتاج:
    | - مستخدمًا مسجل الدخول.
    | - حسابًا نشطًا.
    |
    */

    Route::middleware([
        'auth:sanctum',
        'active.user',
    ])->group(function (): void {
        Route::post('/businesses', [BusinessController::class, 'store']);
    });
});
