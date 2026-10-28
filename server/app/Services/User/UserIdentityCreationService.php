<?php

declare(strict_types=1);

namespace App\Services\User;

use App\Models\User;
use App\Models\UserContact;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class UserIdentityCreationService
{
    /**
     * Create a user and their primary contact.
     *
     * The caller must validate and normalize the input.
     * This service does not issue tokens or assign roles.
     *
     * @param  array<string, mixed>  $data
     */
    public function assertUnambiguousLoginIdentifiers(
        string $username,
        ?string $phone = null,
        ?string $ownerUserId = null,
    ): void {
        if (preg_match('/^[0-9]{9}$/D', $username) === 1) {
            $query = UserContact::withTrashed()
                ->where('type', 'phone')
                ->where('value', $username);

            if ($ownerUserId !== null) {
                $query->where('user_id', '!=', $ownerUserId);
            }

            if ($query->exists()) {
                throw ValidationException::withMessages([
                    'username' => 'هذا الرقم مستخدم كجوال لحساب آخر.',
                ]);
            }
        }

        if ($phone !== null) {
            $query = User::withTrashed()
                ->whereRaw('LOWER(username) = ?', [strtolower($phone)]);

            if ($ownerUserId !== null) {
                $query->whereKeyNot($ownerUserId);
            }

            if ($query->exists()) {
                throw ValidationException::withMessages([
                    'contact_value' => 'هذا الرقم مستخدم كاسم مستخدم لحساب آخر.',
                ]);
            }
        }
    }

    public function create(array $data): User
    {
        return DB::transaction(function () use ($data): User {
            $this->assertUnambiguousLoginIdentifiers(
                (string) $data['username'],
                $data['contact_type'] === 'phone'
                    ? (string) $data['contact_value']
                    : null,
            );

            $user = User::query()->create([
                'username' => $data['username'],
                'display_name' => $data['display_name'],
                'password' => $data['password'],
                'status' => 'active',
            ]);

            $user->contacts()->create([
                'type' => $data['contact_type'],
                'value' => $data['contact_value'],
                'is_primary' => true,
                'verified_at' => null,
            ]);

            return $user->load('contacts');
        });
    }
}
