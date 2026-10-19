<?php

namespace App\Policies;

use App\Models\Business;
use App\Models\BusinessMembership;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class BusinessPolicy
{
    /**
     * A supplier inbox is private to active members of that Business.
     *
     * Missing, suspended, or left memberships return 404 so the endpoint does not
     * reveal whether another supplier Business exists or has received orders.
     */
    public function viewReceivedOrders(
        User $user,
        Business $business,
    ): Response {
        $hasActiveMembership = BusinessMembership::query()
            ->where('business_id', $business->id)
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->exists();

        if (! $hasActiveMembership) {
            return Response::denyAsNotFound();
        }

        // Active membership alone never grants supplier permissions.
        $supplierIsEnabled = $this->hasCurrentSupplierCapability($business);

        if ($supplierIsEnabled) {
            return Response::allow();
        }

        // A previously enabled supplier may read existing historical orders.
        // A never-approved supplier has no previous enabled assignment.
        $wasPreviouslyEnabled = $business->capabilities()
            ->where('business_capabilities.code', 'supplier')
            ->wherePivotNotNull('enabled_at')
            ->wherePivotNotNull('disabled_at')
            ->exists();

        if ($wasPreviouslyEnabled && $business->orderRecipients()->exists()) {
            return Response::allow();
        }

        return Response::deny('Supplier approval is required.');
    }

    /**
     * Response submission has the same supplier membership boundary as inbox read.
     */
    public function respondToReceivedOrder(
        User $user,
        Business $business,
    ): Response {
        $readAccess = $this->viewReceivedOrders($user, $business);

        if ($readAccess->denied()) {
            return $readAccess;
        }

        // Historical read access never restores mutation permission.
        return $this->hasCurrentSupplierCapability($business)
            ? Response::allow()
            : Response::deny('Supplier approval is required.');
    }

    /**
     * Fulfillment transitions use the same private supplier membership boundary.
     */
    public function updateReceivedOrderFulfillment(
        User $user,
        Business $business,
    ): Response {
        $readAccess = $this->viewReceivedOrders($user, $business);

        if ($readAccess->denied()) {
            return $readAccess;
        }

        // Historical read access never restores mutation permission.
        return $this->hasCurrentSupplierCapability($business)
            ? Response::allow()
            : Response::deny('Supplier approval is required.');
    }

    /**
     * Current supplier capability, independent of historical inbox access.
     */
    private function hasCurrentSupplierCapability(Business $business): bool
    {
        return $business->capabilities()
            ->where('business_capabilities.code', 'supplier')
            ->whereNull('business_capabilities.retired_at')
            ->wherePivotNotNull('enabled_at')
            ->wherePivotNull('disabled_at')
            ->exists();
    }
}
