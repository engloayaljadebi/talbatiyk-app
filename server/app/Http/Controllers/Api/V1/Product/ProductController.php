<?php

namespace App\Http\Controllers\Api\V1\Product;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Product\CreateProductRequest;
use App\Http\Requests\Api\V1\Product\IndexProductsRequest;
use App\Http\Resources\Api\V1\ProductResource;
use App\Services\Product\ProductDiscoveryService;
use App\Services\Product\ProductPublishingService;
use Dedoc\Scramble\Attributes\HeaderParameter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Symfony\Component\HttpFoundation\Response;

class ProductController extends Controller
{
    public function __construct(
        private readonly ProductDiscoveryService $discoveryService,
        private readonly ProductPublishingService $publishingService,
    ) {}

    public function index(
        IndexProductsRequest $request,
    ): AnonymousResourceCollection {
        $products = $this->discoveryService->getDiscoverableProducts(
            (int) $request->validated('per_page', 20),
        );

        return ProductResource::collection($products);
    }

    /**
     * ينشر منتجًا مباشرة على الخادم لنشاط مورد حقيقي.
     *
     * supplier_id لا يأتي من Request؛
     * ProductPublishingService يستخدم business الموجود في URL
     * بعد التحقق من العضوية والدور وSupplier capability.
     */
    #[HeaderParameter(
        'Idempotency-Key',
        description: 'Stable UUID reused for retries of the same logical product publication.',
        required: true,
        type: 'string',
        format: 'uuid',
        example: '550e8400-e29b-41d4-a716-446655440000',
    )]
    public function store(
        CreateProductRequest $request,
        string $business,
    ): JsonResponse {
        $product = $this->publishingService->publish(
            $request->user(),
            $business,
            $request->validated(),
            $request->idempotencyKey(),
        );

        return (new ProductResource($product))
            ->response()
            ->setStatusCode(Response::HTTP_CREATED);
    }
}
