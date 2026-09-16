<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class AssignRequestId
{
    public const HEADER_NAME = 'X-Request-ID';

    public const ATTRIBUTE_NAME = 'request_id';

    /**
     * @param  Closure(Request): Response  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->is('api/*')) {
            return $next($request);
        }

        $requestId = $this->resolveRequestId($request);

        $request->attributes->set(
            self::ATTRIBUTE_NAME,
            $requestId,
        );

        $request->headers->set(
            self::HEADER_NAME,
            $requestId,
        );

        Log::shareContext([
            self::ATTRIBUTE_NAME => $requestId,
        ]);

        $response = $next($request);

        $response->headers->set(
            self::HEADER_NAME,
            $requestId,
        );

        return $response;
    }

    private function resolveRequestId(Request $request): string
    {
        $providedRequestId = trim(
            (string) $request->header(self::HEADER_NAME, ''),
        );

        if ($providedRequestId !== '' && Str::isUuid($providedRequestId)) {
            return strtolower($providedRequestId);
        }

        return (string) Str::uuid();
    }
}
