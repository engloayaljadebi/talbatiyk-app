<?php

namespace App\Services\Product;

use App\Models\Product;
use App\Models\User;
use App\Services\Business\BusinessMarketScope;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;

class ProductDiscoveryService
{
    public function __construct(private readonly BusinessMarketScope $marketScope) {}

    public function getDiscoverableProducts(
        User $user,
        int $perPage = 20
    ): LengthAwarePaginator {
        $perPage = max(1, min($perPage, 100));

        $categoryIds = $this->marketScope->categoryIdsFor($user);

        return Product::query()
            ->whereHas('supplier.categories', fn ($query) => $query->whereIn('business_categories.id', $categoryIds))
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
            ->whereHas(
                'supplier',
                function (Builder $query): void {
                    $query
                        ->where('status', 'active')
                        ->whereNull('deleted_at');
                }
            )
            ->whereExists(function ($query): void {
                $query
                    ->select(DB::raw(1))
                    ->from('business_capability_assignments as bca')
                    ->join(
                        'business_capabilities as bc',
                        'bc.code',
                        '=',
                        'bca.capability_code'
                    )
                    ->whereColumn(
                        'bca.business_id',
                        'products.supplier_id'
                    )
                    ->where('bc.code', 'supplier')
                    ->whereNull('bc.retired_at')
                    ->whereNull('bca.disabled_at');
            })
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->paginate($perPage);
    }
}
