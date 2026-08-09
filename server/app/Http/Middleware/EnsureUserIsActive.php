<?php

/*
|--------------------------------------------------------------------------
| Middleware التحقق من نشاط المستخدم
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - منع الحسابات الموقوفة أو المعطلة من استخدام API المحمي.
| - حماية الـTokens القديمة بعد تغيير حالة الحساب.
| - السماح فقط للمستخدم الذي حالته active.
|
| ملاحظة:
| المصادقة نفسها مسؤولية auth:sanctum.
| هذا الـMiddleware يعمل بعد نجاح المصادقة.
|
*/

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsActive
{
    /**
     * السماح فقط للحسابات النشطة.
     *
     * @param  Closure(Request): Response  $next
     */
    public function handle(
        Request $request,
        Closure $next,
    ): Response {
        $user = $request->user();

        /*
         * هذا فحص دفاعي فقط.
         *
         * المفترض أن auth:sanctum يمنع الوصول
         * قبل الوصول إلى هذا الـMiddleware.
         */
        if ($user === null) {
            return new JsonResponse([
                'message' => 'غير مصرح.',
            ], Response::HTTP_UNAUTHORIZED);
        }

        /*
         * أي حالة غير active لا يسمح لها
         * باستخدام المسارات المحمية.
         *
         * يشمل حاليًا:
         * - suspended
         * - disabled
         */
        if ($user->status !== 'active') {
            return new JsonResponse([
                'message' => 'هذا الحساب غير نشط.',
                'code' => 'ACCOUNT_INACTIVE',
            ], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}
