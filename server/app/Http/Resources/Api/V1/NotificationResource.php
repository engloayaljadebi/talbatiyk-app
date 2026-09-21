<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

final class NotificationResource extends JsonResource
{
    /**
     * Keep Laravel polymorphic persistence details private.
     *
     * Flutter receives a stable application contract rather than
     * notifiable_type / notifiable_id or Notification PHP class names.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $payload = is_array($this->data)
            ? $this->data
            : [];

        $metadata = $payload['data'] ?? [];

        if (! is_array($metadata)) {
            $metadata = [];
        }

        return [
            /** @format uuid */
            'id' => (string) $this->id,

            'type' => (string) $this->type,

            'title' => (string) ($payload['title'] ?? ''),

            'body' => (string) ($payload['body'] ?? ''),

            /** @var array<string, mixed> */
            'data' => $metadata,

            'is_read' => $this->read_at !== null,

            /** @format date-time */
            'read_at' => $this->read_at?->toISOString(),

            /** @format date-time */
            'created_at' => $this->created_at?->toISOString(),

            /** @format date-time */
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
