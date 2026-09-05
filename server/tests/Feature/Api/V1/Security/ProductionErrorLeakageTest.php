<?php

namespace Tests\Feature\Api\V1\Security;

use Illuminate\Support\Facades\Route;
use RuntimeException;
use Tests\TestCase;

class ProductionErrorLeakageTest extends TestCase
{
    public function test_unhandled_api_exception_does_not_leak_debug_details_when_debug_is_disabled(): void
    {
        config()->set('app.debug', false);

        $secretMessage = 'SECURITY_ERROR_LEAK_MARKER';

        Route::get(
            '/api/v1/security/error-leakage-probe',
            static fn () => throw new RuntimeException($secretMessage),
        );

        $response = $this->get('/api/v1/security/error-leakage-probe');

        $response
            ->assertStatus(500)
            ->assertHeader('Content-Type', 'application/json');

        $payload = $response->json();

        $this->assertIsArray($payload);

        foreach (['exception', 'file', 'line', 'trace'] as $key) {
            $this->assertArrayNotHasKey($key, $payload);
        }

        $body = $response->getContent();

        $this->assertStringNotContainsString($secretMessage, $body);
        $this->assertStringNotContainsString(RuntimeException::class, $body);
        $this->assertStringNotContainsString(__FILE__, $body);
    }
}
