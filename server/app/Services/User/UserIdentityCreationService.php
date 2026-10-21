<?php

declare(strict_types=1);

namespace App\Services\User;

use App\Models\User;
use Illuminate\Support\Facades\DB;

final class UserIdentityCreationService
{
    /**
     * Create a user and their primary contact.
     *
     * The caller must validate and normalize the input.
     * This service does not issue tokens or assign roles.
     *
     * @param array<string, mixed> $data
     */
    public function create(array $data): User
    {
        return DB::transaction(function () use ($data): User {
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
