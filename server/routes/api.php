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
     * ------------------------------------------------------------------
     * Authentication
     * ------------------------------------------------------------------
     */
    Route::prefix('auth')->group(function (): void {
        Route::post('/register', [AuthController::class, 'register'])
            ->middleware('throttle:5,1');

        Route::post('/login', [AuthController::class, 'login'])
            ->middleware('throttle:10,1');

        Route::middleware('auth:sanctum')->group(function (): void {
            Route::get('/me', [AuthController::class, 'me']);

            Route::post('/logout', [AuthController::class, 'logout']);
        });
    });

    /*
     * ------------------------------------------------------------------
     * Businesses
     * ------------------------------------------------------------------
     *
     * إنشاء النشاط يتطلب مستخدمًا مسجل الدخول.
     */
    Route::middleware('auth:sanctum')->group(function (): void {
        Route::post('/businesses', [BusinessController::class, 'store']);
    });
});
