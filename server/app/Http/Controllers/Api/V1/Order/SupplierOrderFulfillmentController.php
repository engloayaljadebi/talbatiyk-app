<?php

namespace App\Http\Controllers\Api\V1\Order;

use App\Actions\Order\UpdateSupplierFulfillmentAction;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Order\UpdateSupplierFulfillmentRequest;
use App\Http\Resources\Api\V1\OrderRecipientResource;
use App\Models\Business;
use Dedoc\Scramble\Attributes\Response as OpenApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Gate;

class SupplierOrderFulfillmentController extends Controller
{
    public function __construct(
        private readonly UpdateSupplierFulfillmentAction $updateFulfillment,
    ) {}

    /**
     * Advance one supplier Recipient through its fulfillment lifecycle.
     */
    #[OpenApiResponse(
        409,
        'The fulfillment version is stale, the supplier is not selected, or the transition is invalid.',
    )]
    public function update(
        UpdateSupplierFulfillmentRequest $request,
        Business $business,
        string $recipient,
    ): JsonResponse {
        Gate::authorize(
            'updateReceivedOrderFulfillment',
            $business,
        );

        $updatedRecipient = $this->updateFulfillment->execute(
            $business,
            $recipient,
            $request->user(),
            $request->fulfillmentPayload(),
        );

        return (new OrderRecipientResource(
            $updatedRecipient,
        ))->response();
    }
}
