<?php

namespace App\Http\Controllers\Api\V1\Order;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\OrderRecipientResource;
use App\Models\Business;
use App\Services\Order\SupplierOrderQueryService;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\Gate;

class SupplierOrderController extends Controller
{
    public function __construct(
        private readonly SupplierOrderQueryService $supplierOrderQueryService,
    ) {}

    /**
     * List orders received by one supplier Business.
     */
    public function index(
        Business $business,
    ): AnonymousResourceCollection {
        /*
         * The Policy owns membership authorization. The QueryService still scopes
         * by supplier_id so authorization and data isolation are independent layers.
         */
        Gate::authorize('viewReceivedOrders', $business);

        return OrderRecipientResource::collection(
            $this->supplierOrderQueryService->receivedOrders($business),
        );
    }
}
