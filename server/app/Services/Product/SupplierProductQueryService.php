<?php

namespace App\Services\Product;

use App\Models\Product;
use App\Models\User;
use App\Services\Business\BusinessAccessService;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class SupplierProductQueryService
{
    public function __construct(
        private readonly BusinessAccessService $businessAccessService,
    ) {}

    public function getManageableProducts(
        User $user,
        string $businessId,
        int $perPage = 20,
    ): LengthAwarePaginator {
        /*
         * Product management uses the same authorization boundary as
         * supplier publication/update:
         *
         * - active membership is required;
         * - owner or manager is required;
         * - a user outside the Business receives 404;
         * - staff receives 403.
         */
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        $perPage = max(
            1,
            min(
                $perPage,
                100,
            ),
        );

        /*
         * The URL Business is the ownership scope.
         *
         * Never accept supplier_id from the client for this query.
         */
        return Product::query()
            ->with([
                'supplier:id,name',

                'supplier.locations' => function (
                    $query
                ): void {
                    $query
                        ->select([
                            'id',
                            'business_id',
                            'administrative_area',
                            'is_primary',
                        ])
                        ->where(
                            'is_primary',
                            true,
                        );
                },
            ])
            ->where(
                'supplier_id',
                $businessId,
            )
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->paginate($perPage);
    }
}
