<?php

namespace App\Http\Controllers\Api\V1\Notification;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Notification\ListNotificationsRequest;
use App\Http\Resources\Api\V1\NotificationResource;
use App\Services\Notification\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

final class NotificationController extends Controller
{
    public function __construct(
        private readonly NotificationService $notificationService,
    ) {}

    public function index(
        ListNotificationsRequest $request,
    ): AnonymousResourceCollection {
        return NotificationResource::collection(
            $this->notificationService->paginateForUser(
                user: $request->user(),
                page: $request->page(),
                perPage: $request->perPage(),
            ),
        );
    }

    public function unreadCount(Request $request): JsonResponse
    {
        return response()->json([
            'data' => [
                'unread_count' => $this->notificationService
                    ->unreadCountForUser($request->user()),
            ],
        ]);
    }

    public function markRead(
        Request $request,
        string $notification,
    ): JsonResponse {
        $resource = new NotificationResource(
            $this->notificationService->markRead(
                user: $request->user(),
                notificationId: $notification,
            ),
        );

        /*
         * NotificationResource intentionally exposes an application-level
         * field named "data" for notification metadata.
         *
         * JsonResource normally also uses "data" as its outer wrapper.
         * For a single resource Laravel avoids double wrapping when the
         * resolved payload already contains a "data" key.
         *
         * Wrap explicitly here so the single-resource endpoint keeps the
         * same stable API envelope used by the rest of the API:
         *
         * {
         *   "data": {
         *     "id": "...",
         *     "data": {...}
         *   }
         * }
         */
        return response()->json([
            'data' => $resource->resolve($request),
        ]);
    }

    public function markAllRead(Request $request): JsonResponse
    {
        return response()->json([
            'data' => $this->notificationService
                ->markAllRead($request->user()),
        ]);
    }
}
