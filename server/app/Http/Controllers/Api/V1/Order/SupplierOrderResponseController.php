<?php

namespace App\Http\Controllers\Api\V1\Order;

use App\Actions\Order\SubmitSupplierOrderResponseAction;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Order\SubmitSupplierOrderResponseRequest;
use App\Http\Resources\Api\V1\OrderRecipientResponseResource;
use App\Models\Business;
use Dedoc\Scramble\Attributes\HeaderParameter;
use Dedoc\Scramble\Attributes\Response as OpenApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Gate;
use Symfony\Component\HttpFoundation\Response;

class SupplierOrderResponseController extends Controller
{
    public function __construct(
        private readonly SubmitSupplierOrderResponseAction $submitResponse,
    ) {}

    /**
     * Submit the final response for one supplier order recipient.
     */
    #[HeaderParameter(
        'Idempotency-Key',
        description: 'Stable UUID reused for retries of the same logical supplier response.',
        required: true,
        type: 'string',
        format: 'uuid',
        example: '550e8400-e29b-41d4-a716-446655440000',
    )] #[OpenApiResponse(
        409,
        'The recipient already has a final response or the Idempotency-Key was reused with a different payload.',
    )]
    public function store(
        SubmitSupplierOrderResponseRequest $request,
        Business $business,
        string $recipient,
    ): JsonResponse {
        Gate::authorize('respondToReceivedOrder', $business);

        $response = $this->submitResponse->execute(
            $business,
            $recipient,
            $request->responsePayload(),
            $request->idempotencyKey(),
        );

        return (new OrderRecipientResponseResource($response))
            ->response()
            ->setStatusCode(Response::HTTP_CREATED);
    }
}
