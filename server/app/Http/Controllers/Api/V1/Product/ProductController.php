<?php

namespace App\Http\Controllers\Api\V1\Product;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Product\CreateProductRequest;
use App\Http\Requests\Api\V1\Product\DeleteProductRequest;
use App\Http\Requests\Api\V1\Product\IndexProductsRequest;
use App\Http\Requests\Api\V1\Product\UpdateProductImageRequest;
use App\Http\Requests\Api\V1\Product\UpdateProductRequest;
use App\Http\Resources\Api\V1\ProductResource;
use App\Services\Product\ProductDiscoveryService;
use App\Services\Product\ProductMutationService;
use App\Services\Product\ProductPublishingService;
use App\Services\Product\SupplierProductQueryService;
use Dedoc\Scramble\Attributes\HeaderParameter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response as HttpResponse;
use Symfony\Component\HttpFoundation\Response;

class ProductController extends Controller
{
    public function __construct(
        private readonly ProductDiscoveryService $discoveryService,
        private readonly SupplierProductQueryService $supplierProductQueryService,
        private readonly ProductPublishingService $publishingService,
        private readonly ProductMutationService $mutationService,
    ) {}

    public function index(
        IndexProductsRequest $request,
    ): AnonymousResourceCollection {
        $products = $this->discoveryService->getDiscoverableProducts(
            (int) $request->validated('per_page', 20),
        );

        return ProductResource::collection($products);
    }

    public function businessIndex(
        IndexProductsRequest $request,
        string $business,
    ): AnonymousResourceCollection {
        $products = $this->supplierProductQueryService
            ->getManageableProducts(
                $request->user(),
                $business,
                (int) $request->validated(
                    'per_page',
                    20,
                ),
            );

        return ProductResource::collection(
            $products,
        );
    }

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

    public function update(
        UpdateProductRequest $request,
        string $business,
        string $product,
    ): ProductResource {
        $updatedProduct = $this->mutationService->update(
            $request->user(),
            $business,
            $product,
            $request->validated(),
        );

        return new ProductResource($updatedProduct);
    }

    public function updateImage(
        UpdateProductImageRequest $request,
        string $business,
        string $product,
    ): ProductResource {
        $updatedProduct = $this->mutationService->updateImage(
            $request->user(),
            $business,
            $product,
            $request->validated(),
        );

        return new ProductResource($updatedProduct);
    }

    public function destroy(
        DeleteProductRequest $request,
        string $business,
        string $product,
    ): HttpResponse {
        $this->mutationService->delete(
            $request->user(),
            $business,
            $product,
            (int) $request->validated('expected_version'),
        );

        return response()->noContent();
    }
}
