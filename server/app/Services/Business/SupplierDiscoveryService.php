<?php

namespace App\Services\Business;

use App\Models\Business;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class SupplierDiscoveryService
{
    public function __construct(private readonly BusinessMarketScope $marketScope) {}

    /**
     * Return businesses currently eligible to receive supplier orders.
     *
     * @return Collection<int, Business>
     */
    public function available(User $user): Collection
    {
        $categoryIds = $this->marketScope->categoryIdsFor($user);

        return Business::query()
            ->whereHas('categories', fn ($query) => $query->whereIn('business_categories.id', $categoryIds))
            ->where('status', 'active')
            ->whereHas('capabilities', function ($query): void {
                $query
                    ->where('business_capabilities.code', 'supplier')
                    ->whereNull('business_capabilities.retired_at')
                    ->whereNull(
                        'business_capability_assignments.disabled_at',
                    );
            })
            ->orderBy('name')
            ->get();
    }
}
