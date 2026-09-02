<?php

namespace App\Http\Controllers\Api\V1\Order;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Order\CreateOrderRequest;
use App\Http\Resources\Api\V1\OrderResource;
use App\Services\Order\OrderQueryService;
use App\Services\Order\OrderService;
use Dedoc\Scramble\Attributes\HeaderParameter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Symfony\Component\HttpFoundation\Response;

class OrderController extends Controller
{
    public function __construct(
        private readonly OrderService $orderService,
        private readonly OrderQueryService $orderQueryService,
    ) {}

    /**
     * Return orders owned by the authenticated customer.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        return OrderResource::collection(
            $this->orderQueryService->forUser($request->user()),
        );
    }

    /**
     * Create a new order for the authenticated user.
     */ #[HeaderParameter(
        'Idempotency-Key',
        description: 'Stable UUID reused for retries of the same logical order creation.',
        required: true,
        type: 'string',
        format: 'uuid',
        example: '550e8400-e29b-41d4-a716-446655440000',
    )]
    public function store(CreateOrderRequest $request): JsonResponse
    {
        $order = $this->orderService->create(
            $request->user(),
            $request->validated(),
            $request->idempotencyKey(),
        );

        return (new OrderResource($order))
            ->response()
            ->setStatusCode(Response::HTTP_CREATED);
    }
}
