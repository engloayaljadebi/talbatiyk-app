<?php

namespace App\Services\Business;

use App\Models\Business;
use Illuminate\Database\Eloquent\Collection;

class SupplierDiscoveryService
{
    /**
     * Return businesses currently eligible to receive supplier orders.
     *
     * @return Collection<int, Business>
     */
    public function available(): Collection
    {
        return Business::query()
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
