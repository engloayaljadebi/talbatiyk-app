<?php

namespace App\Http\Controllers\Api\V1\Notification;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Notification\ListNotificationsRequest;
use App\Http\Resources\Api\V1\NotificationResource;
use App\Services\Notification\NotificationService;
use Dedoc\Scramble\Attributes\PathParameter;
use Dedoc\Scramble\Attributes\Response;
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

    /**
     * Mark one notification owned by the authenticated user as read.
     */
    #[PathParameter(
        'notification',
        description: 'Notification UUID.',
        required: true,
        type: 'string',
        format: 'uuid',
    )]
    #[Response(
        200,
        'Notification marked as read.',
        type: 'array{data: NotificationResource}',
    )]
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
