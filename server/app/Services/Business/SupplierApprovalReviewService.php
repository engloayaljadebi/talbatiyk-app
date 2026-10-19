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
    private const VERIFICATION_TYPE = 'supplier_approval';

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
                ->where(
                    'verification_type_code',
                    self::VERIFICATION_TYPE,
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
                $this->activateSupplier($business);
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
     * Activate only the supplier capability.
     * Existing shop capability is never changed.
     */
    private function activateSupplier(Business $business): void
    {
        $isAvailable = BusinessCapability::query()
            ->where('code', 'supplier')
            ->whereNull('retired_at')
            ->exists();

        if (! $isAvailable) {
            throw new ConflictHttpException(
                'Supplier capability is unavailable.',
            );
        }

        $alreadyAssigned = $business->capabilities()
            ->where('business_capabilities.code', 'supplier')
            ->exists();

        if ($alreadyAssigned) {
            // Existing or formerly disabled supplier capabilities
            // must be handled by a separate, explicit workflow.
            throw new ConflictHttpException(
                'Supplier capability is already assigned.',
            );
        }

        $business->capabilities()->attach('supplier', [
            // The platform activates this capability, rather
            // than a business owner or business manager.
            'enabled_by_membership_id' => null,
            'enabled_at' => now(),
            'disabled_at' => null,
        ]);
    }
}
