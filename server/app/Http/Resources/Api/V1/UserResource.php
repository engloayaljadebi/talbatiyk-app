<?php

/*
|--------------------------------------------------------------------------
| شكل المستخدم في API
|--------------------------------------------------------------------------
|
| هذا الملف يحدد البيانات المسموح بإرسالها إلى Flutter.
| كلمة المرور وremember_token لا يخرجان مطلقًا.
|
*/

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * تحويل المستخدم إلى JSON ثابت للـAPI.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'username' => $this->username,
            'display_name' => $this->display_name,
            'status' => $this->status,
            'last_login_at' => $this->last_login_at?->toISOString(),

            'contacts' => $this->whenLoaded(
                'contacts',
                fn () => $this->contacts->map(
                    fn ($contact) => [
                        'id' => $contact->id,
                        'type' => $contact->type,
                        'value' => $contact->value,
                        'is_primary' => $contact->is_primary,
                        'verified_at' => $contact->verified_at?->toISOString(),
                    ],
                )->values(),
            ),
        ];
    }
}
