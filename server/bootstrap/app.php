<?php

/*
|--------------------------------------------------------------------------
| Bootstrap التطبيق
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تسجيل مسارات Laravel.
| - تسجيل Middleware المخصصة.
| - منع تحويل طلبات API غير المصادق عليها إلى صفحة Login.
| - ضمان أن أخطاء API ترجع JSON.
| - إعداد معالجة الاستثناءات.
|
*/

use App\Http\Middleware\EnsureUserIsActive;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        /*
         * مسارات API لا يجب أن تحاول التحويل إلى route('login')
         * عند انتهاء أو غياب Bearer Token.
         *
         * API يعيد 401 بدل Redirect.
         *
         * أما مسارات Web فنحافظ لها على سلوك Laravel المعتاد.
         */
        $middleware->redirectGuestsTo(
            fn (Request $request): ?string => $request->is('api/*')
                ? null
                : route('login'),
        );

        /*
         * Alias موحد لحماية API من الحسابات
         * suspended أو disabled.
         */
        $middleware->alias([
            'active.user' => EnsureUserIsActive::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        /*
         * كل استثناء صادر من /api/*
         * يجب أن يرجع JSON حتى لو لم يرسل العميل
         * Accept: application/json.
         */
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request): bool => $request->is('api/*')
                || $request->expectsJson(),
        );
    })
    ->create();
