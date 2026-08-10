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
| - Business Locations API
|
*/

use App\Http\Controllers\Api\V1\Auth\AuthController;
use App\Http\Controllers\Api\V1\Business\BusinessController;
use App\Http\Controllers\Api\V1\Business\BusinessLocationController;
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
    | Authenticated Active User API
    |--------------------------------------------------------------------------
    |
    | جميع المسارات التالية تحتاج:
    | - Token صالحًا.
    | - حساب مستخدم active.
    |
    */

    Route::middleware([
        'auth:sanctum',
        'active.user',
    ])->group(function (): void {
        /*
        |--------------------------------------------------------------------------
        | Businesses
        |--------------------------------------------------------------------------
        */

        /*
         * قائمة الأنشطة التي لدى المستخدم
         * عضوية نشطة فيها.
         */
        Route::get('/businesses', [BusinessController::class, 'index']);

        /*
         * إنشاء نشاط تجاري جديد.
         */
        Route::post('/businesses', [BusinessController::class, 'store']);

        /*
         * تفاصيل نشاط واحد.
         *
         * BusinessQueryService يتأكد من أن المستخدم
         * لديه عضوية active في النشاط.
         */
        Route::get('/businesses/{business}', [BusinessController::class, 'show']);

        /*
         * تعديل البيانات الأساسية لنشاط واحد.
         *
         * BusinessAccessService يتأكد أن المستخدم
         * owner أو manager داخل النشاط.
         */
        Route::patch(
            '/businesses/{business}',
            [BusinessController::class, 'update'],
        );

        /*
        |--------------------------------------------------------------------------
        | Business Locations
        |--------------------------------------------------------------------------
        |
        | إدارة فروع ومتاجر ومكاتب ومخازن النشاط.
        |
        */

        Route::scopeBindings()->group(function (): void {
            /*
             * عرض جميع مواقع النشاط.
             */
            Route::get(
                '/businesses/{business}/locations',
                [BusinessLocationController::class, 'index'],
            );

            /*
             * إنشاء موقع جديد.
             */
            Route::post(
                '/businesses/{business}/locations',
                [BusinessLocationController::class, 'store'],
            );

            /*
             * عرض موقع واحد.
             */
            Route::get(
                '/businesses/{business}/locations/{location}',
                [BusinessLocationController::class, 'show'],
            );

            /*
             * تعديل موقع موجود.
             */
            Route::patch(
                '/businesses/{business}/locations/{location}',
                [BusinessLocationController::class, 'update'],
            );

            /*
             * حذف موقع.
             */
            Route::delete(
                '/businesses/{business}/locations/{location}',
                [BusinessLocationController::class, 'destroy'],
            );

            /*
             * تعيين الموقع الرئيسي للنشاط.
             */
            Route::post(
                '/businesses/{business}/locations/{location}/primary',
                [BusinessLocationController::class, 'setPrimary'],
            );
        });
    });
});
