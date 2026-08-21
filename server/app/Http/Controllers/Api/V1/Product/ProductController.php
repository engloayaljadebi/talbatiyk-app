<?php

namespace App\Http\Controllers\Api\V1\Product;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Product\IndexProductsRequest;
use App\Http\Resources\Api\V1\ProductResource;
use App\Services\Product\ProductDiscoveryService;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class ProductController extends Controller
{
    public function __construct(
        private readonly ProductDiscoveryService $service
    ) {}

    public function index(
        IndexProductsRequest $request
    ): AnonymousResourceCollection {
        $products = $this->service->getDiscoverableProducts(
            (int) $request->validated('per_page', 20)
        );

        return ProductResource::collection($products);
    }
}
