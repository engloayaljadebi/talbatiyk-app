<?php

namespace App\Http\Controllers\Api\V1\Platform;

use App\Http\Controllers\Controller;
use App\Models\Verification;
use App\Services\Business\SupplierApprovalReviewService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

final class SupplierApprovalAdminController extends Controller
{
    public function __construct(
        private readonly SupplierApprovalReviewService $reviews,
    ) {}

    /**
     * List pending supplier applications for authorized platform staff.
     */
    public function index(Request $request): JsonResponse
    {
        $this->authorizePlatformReviewer($request);

        $validated = $request->validate([
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:50'],
        ]);

        $perPage = (int) ($validated['per_page'] ?? 20);

        $page = Verification::query()
            ->with(['business', 'requestedBy'])
            ->where('verification_type_code', 'supplier_approval')
            ->where('status', 'pending')
            ->orderBy('requested_at')
            ->orderBy('id')
            ->paginate($perPage);

        $data = $page->getCollection()
            ->map(static function (Verification $verification): array {
                $business = $verification->business;
                $requester = $verification->requestedBy;

                return [
                    'id' => $verification->id,
                    'business_id' => $verification->business_id,
                    'status' => $verification->status,
                    'requested_at' => $verification->requested_at
                        ?->toIso8601String(),
                    'business' => $business === null
                        ? null
                        : [
                            'id' => $business->id,
                            'name' => $business->name,
                            'status' => $business->status,
                        ],
                    'requested_by' => $requester === null
                        ? null
                        : [
                            'id' => $requester->id,
                            'display_name' => $requester->display_name,
                        ],
                ];
            })
            ->values();

        return response()->json([
            'data' => $data,
            'meta' => [
                'current_page' => $page->currentPage(),
                'last_page' => $page->lastPage(),
                'per_page' => $page->perPage(),
                'total' => $page->total(),
            ],
        ]);
    }

    /**
     * Approve exactly one pending supplier application.
     */
    public function approve(
        Request $request,
        string $verification,
    ): JsonResponse {
        $this->authorizePlatformReviewer($request);

        $validated = $request->validate([
            'review_note' => ['nullable', 'string', 'max:2000'],
        ]);

        $reviewed = $this->reviews->approve(
            $verification,
            $request->user(),
            (string) ($validated['review_note'] ?? ''),
        );

        return response()->json([
            'data' => $this->decisionData($reviewed),
        ]);
    }

    /**
     * Reject exactly one pending supplier application.
     * A meaningful reason is mandatory.
     */
    public function reject(
        Request $request,
        string $verification,
    ): JsonResponse {
        $this->authorizePlatformReviewer($request);

        $validated = $request->validate([
            'review_note' => [
                'required',
                'string',
                'min:1',
                'max:2000',
            ],
        ]);

        $reviewed = $this->reviews->reject(
            $verification,
            $request->user(),
            $validated['review_note'],
        );

        return response()->json([
            'data' => $this->decisionData($reviewed),
        ]);
    }

    private function authorizePlatformReviewer(Request $request): void
    {
        // Defense in depth: permissions are checked both
        // in routing and here, before any database action.
        Gate::forUser($request->user())->authorize(
            'reviewSupplierApprovals',
        );
    }

    /**
     * Explicit response shape; no accidental model attribute exposure.
     *
     * @return array<string, mixed>
     */
    private function decisionData(Verification $verification): array
    {
        return [
            'id' => $verification->id,
            'business_id' => $verification->business_id,
            'status' => $verification->status,
            'reviewed_by_user_id' => $verification->reviewed_by_user_id,
            'reviewed_at' => $verification->reviewed_at
                ?->toIso8601String(),
            'review_note' => $verification->review_note,
        ];
    }
}
