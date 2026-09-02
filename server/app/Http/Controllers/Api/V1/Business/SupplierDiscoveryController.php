<?php

namespace App\Http\Controllers\Api\V1\Business;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\SupplierSummaryResource;
use App\Services\Business\SupplierDiscoveryService;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class SupplierDiscoveryController extends Controller
{
    public function __construct(
        private readonly SupplierDiscoveryService $supplierDiscoveryService,
    ) {}

    public function index(): AnonymousResourceCollection
    {
        return SupplierSummaryResource::collection(
            $this->supplierDiscoveryService->available(),
        );
    }
}
