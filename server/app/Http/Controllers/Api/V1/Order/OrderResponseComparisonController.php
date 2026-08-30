<?php

namespace App\Http\Controllers\Api\V1\Order;

use App\Actions\Order\SelectOrderSupplierResponsesAction;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Order\SelectOrderSupplierResponsesRequest;
use App\Http\Resources\Api\V1\OrderResponseComparisonResource;
use App\Services\Order\OrderResponseComparisonQueryService;
use Dedoc\Scramble\Attributes\Response;
use Illuminate\Http\Request;

class OrderResponseComparisonController extends Controller
{
    public function __construct(
        private readonly OrderResponseComparisonQueryService $comparisonQuery,
        private readonly SelectOrderSupplierResponsesAction $selectAction,
    ) {}

    /**
     * Compare all final supplier responses for one owned Order.
     */
    #[Response(404, 'Order not found.')]
    public function show(
        Request $request,
        string $order,
    ): OrderResponseComparisonResource {
        return new OrderResponseComparisonResource(
            $this->comparisonQuery->forUser(
                $request->user(),
                $order,
            ),
        );
    }

    /**
     * Replace the customer's supplier-response selection atomically.
     */
    #[Response(404, 'Order not found.')]
    #[Response(409, 'The order version is stale.')]
    public function update(
        SelectOrderSupplierResponsesRequest $request,
        string $order,
    ): OrderResponseComparisonResource {
        return new OrderResponseComparisonResource(
            $this->selectAction->execute(
                $request->user(),
                $order,
                $request->validated(),
            ),
        );
    }
}
