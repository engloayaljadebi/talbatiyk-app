<?php

namespace App\Http\Resources\Api\V1;

use App\Models\Verification;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Verification
 */
class SupplierApprovalResource extends JsonResource
{
    /**
     * Supplier-facing review status without internal reviewer details.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'requested_at' => $this->requested_at?->toISOString(),
            'reviewed_at' => $this->reviewed_at?->toISOString(),
            'rejection_reason' => $this->status === 'rejected'
                ? $this->review_note
                : null,
        ];
    }
}
