<?php

namespace App\Services\Product;

use App\Models\Product;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;

class ProductDiscoveryService
{
    public function getDiscoverableProducts(
        int $perPage = 20
    ): LengthAwarePaginator {
        $perPage = max(1, min($perPage, 100));

        return Product::query()
            ->with('supplier:id,name')
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
