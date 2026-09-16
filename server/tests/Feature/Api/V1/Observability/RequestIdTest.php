<?php

namespace Tests\Feature\Api\V1\Observability;

use App\Http\Middleware\AssignRequestId;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Str;
use RuntimeException;
use Tests\TestCase;

class RequestIdTest extends TestCase
{
    private const REQUEST_ID = '550e8400-e29b-41d4-a716-446655440000';

    protected function setUp(): void
    {
        parent::setUp();

        Route::get(
            '/api/v1/observability/request-id-probe',
            static fn () => response()->json([
                'request_id' => Log::sharedContext()[
                    AssignRequestId::ATTRIBUTE_NAME
                ] ?? null,
            ]),
        );

        Route::get(
            '/api/v1/observability/request-id-error-probe',
            static fn () => throw new RuntimeException(
                'REQUEST_ID_ERROR_PROBE',
            ),
        );
    }

    public function test_api_request_receives_generated_request_id(): void
    {
        $response = $this->getJson(
            '/api/v1/observability/request-id-probe',
        );

        $response->assertOk();

        $requestId = $response->headers->get(
            AssignRequestId::HEADER_NAME,
        );

        $this->assertIsString($requestId);
        $this->assertTrue(Str::isUuid($requestId));
        $this->assertSame(
            $requestId,
            $response->json('request_id'),
        );
    }

    public function test_valid_incoming_request_id_is_preserved_and_shared_with_logs(): void
    {
        $response = $this
            ->withHeader(
                AssignRequestId::HEADER_NAME,
                self::REQUEST_ID,
            )
            ->getJson(
                '/api/v1/observability/request-id-probe',
            );

        $response
            ->assertOk()
            ->assertHeader(
                AssignRequestId::HEADER_NAME,
                self::REQUEST_ID,
            )
            ->assertJsonPath(
                'request_id',
                self::REQUEST_ID,
            );
    }

    public function test_invalid_incoming_request_id_is_replaced(): void
    {
        $invalidRequestId = 'not-a-valid-request-id';

        $response = $this
            ->withHeader(
                AssignRequestId::HEADER_NAME,
                $invalidRequestId,
            )
            ->getJson(
                '/api/v1/observability/request-id-probe',
            );

        $response->assertOk();

        $requestId = $response->headers->get(
            AssignRequestId::HEADER_NAME,
        );

        $this->assertIsString($requestId);
        $this->assertNotSame($invalidRequestId, $requestId);
        $this->assertTrue(Str::isUuid($requestId));
        $this->assertSame(
            $requestId,
            $response->json('request_id'),
        );
    }

    public function test_framework_generated_api_404_keeps_request_id_header(): void
    {
        $response = $this
            ->withHeader(
                AssignRequestId::HEADER_NAME,
                self::REQUEST_ID,
            )
            ->get(
                '/api/v1/observability/route-that-does-not-exist',
            );

        $response
            ->assertStatus(404)
            ->assertHeader(
                AssignRequestId::HEADER_NAME,
                self::REQUEST_ID,
            );
    }

    public function test_unhandled_api_exception_keeps_request_id_header(): void
    {
        config()->set('app.debug', false);

        $response = $this
            ->withHeader(
                AssignRequestId::HEADER_NAME,
                self::REQUEST_ID,
            )
            ->get(
                '/api/v1/observability/request-id-error-probe',
            );

        $response
            ->assertStatus(500)
            ->assertHeader(
                AssignRequestId::HEADER_NAME,
                self::REQUEST_ID,
            );
    }
}
