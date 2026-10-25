<?php

namespace App\Services\Business;

use App\Models\Business;
use App\Models\BusinessCapability;
use App\Models\User;
use App\Models\Verification;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;

final class SupplierApprovalReviewService
{

    /**
     * Approve a pending application and activate supplier capability.
     */
    public function approve(
        string $verificationId,
        User $reviewer,
        string $reviewNote,
    ): Verification {
        return $this->decide(
            $verificationId,
            $reviewer,
            'approved',
            $reviewNote,
        );
    }

    /**
     * Reject a pending application without enabling supplier access.
     */
    public function reject(
        string $verificationId,
        User $reviewer,
        string $reviewNote,
    ): Verification {
        return $this->decide(
            $verificationId,
            $reviewer,
            'rejected',
            $reviewNote,
        );
    }

    private function decide(
        string $verificationId,
        User $reviewer,
        string $decision,
        string $reviewNote,
    ): Verification {
        $this->authorizeReviewer($reviewer);

        $note = trim($reviewNote);

        if ($decision === 'rejected' && $note === '') {
            throw ValidationException::withMessages([
                'review_note' => 'A rejection reason is required.',
            ]);
        }

        return DB::transaction(function () use (
            $verificationId,
            $reviewer,
            $decision,
            $note,
        ): Verification {
            // Locks the verification so concurrent reviewers cannot
            // independently approve the same pending request.
            $verification = Verification::query()
                ->whereKey($verificationId)
                ->whereIn(
                    'verification_type_code',
                    ['supplier_approval', 'shop_approval'],
                )
                ->lockForUpdate()
                ->firstOrFail();

            if ($verification->status !== 'pending') {
                throw new ConflictHttpException(
                    'This supplier application was already reviewed.',
                );
            }

            if ($verification->requested_by_user_id === $reviewer->id) {
                throw new AuthorizationException(
                    'Self-approval is not permitted.',
                );
            }

            $business = Business::query()
                ->whereKey($verification->business_id)
                ->lockForUpdate()
                ->firstOrFail();

            // Reviewers cannot approve or reject businesses
            // in which they hold an active membership.
            $hasConflictOfInterest = $business->memberships()
                ->where('user_id', $reviewer->id)
                ->where('status', 'active')
                ->exists();

            if ($hasConflictOfInterest) {
                throw new AuthorizationException(
                    'A reviewer cannot review a business they belong to.',
                );
            }

            if ($business->status !== 'active') {
                throw new ConflictHttpException(
                    'The business must be active for review.',
                );
            }

            if ($decision === 'approved') {
                $capabilityCode = match ($verification->verification_type_code) {
                    'supplier_approval' => 'supplier',
                    'shop_approval' => 'shop',
                    default => throw new ConflictHttpException(
                        'Unsupported business approval type.'
                    ),
                };

                $this->activateCapability($business, $capabilityCode);
            }

            $verification->update([
                'status' => $decision,
                'reviewed_by_user_id' => $reviewer->id,
                'reviewed_at' => now(),
                'review_note' => $note !== '' ? $note : null,
            ]);

            return $verification->refresh();
        }, 3);
    }

    /**
     * Platform approval is separate from business owner/manager roles.
     */
    private function authorizeReviewer(User $reviewer): void
    {
        // Reload account eligibility from the database; do not trust
        // an old in-memory User object after suspension or deletion.
        $isActive = User::query()
            ->whereKey($reviewer->id)
            ->where('status', 'active')
            ->exists();

        if (! $isActive) {
            throw new AuthorizationException(
                'An active platform reviewer is required.',
            );
        }

        Gate::forUser($reviewer)->authorize(
            'reviewSupplierApprovals',
        );
    }

    /**
     * Activate the capability associated with the approved request.
     */
    private function activateCapability(
        Business $business,
        string $capabilityCode,
    ): void {
        $isAvailable = BusinessCapability::query()
            ->where('code', $capabilityCode)
            ->whereNull('retired_at')
            ->exists();

        if (! $isAvailable) {
            throw new ConflictHttpException(
                'Business capability is unavailable.',
            );
        }

        $alreadyAssigned = $business->capabilities()
            ->where('business_capabilities.code', $capabilityCode)
            ->exists();

        if ($alreadyAssigned) {
            throw new ConflictHttpException(
                'Business capability is already assigned.',
            );
        }

        $business->capabilities()->attach($capabilityCode, [
            'enabled_by_membership_id' => null,
            'enabled_at' => now(),
            'disabled_at' => null,
        ]);
    }
}
