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

        return $hasActiveMembership
            ? Response::allow()
            : Response::denyAsNotFound();
    }

    /**
     * Response submission has the same supplier membership boundary as inbox read.
     */
    public function respondToReceivedOrder(
        User $user,
        Business $business,
    ): Response {
        return $this->viewReceivedOrders($user, $business);
    }

    /**
     * Fulfillment transitions use the same private supplier membership boundary.
     */
    public function updateReceivedOrderFulfillment(
        User $user,
        Business $business,
    ): Response {
        return $this->viewReceivedOrders($user, $business);
    }
}
