<?php

namespace App\Services\Notification;

use App\Models\User;
use Illuminate\Notifications\DatabaseNotification;
use Illuminate\Pagination\LengthAwarePaginator;

final class NotificationService
{
    /**
     * @return LengthAwarePaginator<int, DatabaseNotification>
     */
    public function paginateForUser(
        User $user,
        int $page,
        int $perPage,
    ): LengthAwarePaginator {
        return $user
            ->notifications()
            ->orderByDesc('created_at')
            ->paginate(
                perPage: $perPage,
                columns: ['*'],
                pageName: 'page',
                page: $page,
            );
    }

    public function unreadCountForUser(User $user): int
    {
        return $user
            ->unreadNotifications()
            ->count();
    }

    public function markRead(
        User $user,
        string $notificationId,
    ): DatabaseNotification {
        /*
         * Ownership is part of the query.
         *
         * A notification belonging to another user behaves as 404,
         * preventing cross-account disclosure.
         */
        /** @var DatabaseNotification $notification */
        $notification = $user
            ->notifications()
            ->whereKey($notificationId)
            ->firstOrFail();

        /*
         * Idempotent:
         * retries must not replace the original read_at timestamp.
         */
        if ($notification->read_at === null) {
            $notification->markAsRead();
            $notification->refresh();
        }

        return $notification;
    }

    /**
     * @return array{
     *     updated_count: int,
     *     unread_count: int
     * }
     */
    public function markAllRead(User $user): array
    {
        $now = now();

        $updatedCount = $user
            ->unreadNotifications()
            ->update([
                'read_at' => $now,
                'updated_at' => $now,
            ]);

        return [
            'updated_count' => $updatedCount,
            'unread_count' => 0,
        ];
    }
}
