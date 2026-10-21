<?php

declare(strict_types=1);

namespace App\Services\Platform;

use App\Models\User;
use App\Services\User\UserProfileService;
use App\Support\ContactValueNormalizer;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

final class AdminUserUpdateService
{
    public function __construct(
        private readonly UserProfileService $profiles,
    ) {}

    /**
     * Update basic and personal data only.
     *
     * Does not update password, contacts, roles or status.
     *
     * @param array<string, mixed> $input
     */
    public function update(
        User $admin,
        User $target,
        array $input,
    ): User {
        Gate::forUser($admin)->authorize('manageUsers');

        $username = ContactValueNormalizer::username(
            $input['username'] ?? null
        );

        $displayName = trim(
            (string) ($input['display_name'] ?? '')
        );

        $country = $input['nationality_country_code'] ?? null;

        if (is_string($country)) {
            $country = strtoupper(trim($country));
            $country = $country === '' ? null : $country;
        }

        $birthDate = $input['birth_date'] ?? null;

        if ($birthDate === '') {
            $birthDate = null;
        }

        $data = Validator::make([
            'username' => $username,
            'display_name' => $displayName,
            'nationality_country_code' => $country,
            'birth_date' => $birthDate,
        ], [
            'username' => [
                'required',
                'string',
                'min:3',
                'max:50',
                'regex:/^[\pL\pN._-]+$/u',
            ],
            'display_name' => [
                'required',
                'string',
                'min:2',
                'max:160',
            ],
            'nationality_country_code' => [
                'nullable',
                'string',
                'size:2',
                'regex:/^[A-Z]{2}$/',
            ],
            'birth_date' => [
                'nullable',
                'date_format:Y-m-d',
                'before_or_equal:today',
            ],
        ])->validate();

        return DB::transaction(function () use (
            $admin,
            $target,
            $data,
        ): User {
            Gate::forUser($admin)->authorize('manageUsers');

            // Re-read and lock the current database record.
            $user = User::query()
                ->whereKey($target->getKey())
                ->lockForUpdate()
                ->firstOrFail();

            $duplicate = User::withTrashed()
                ->whereKeyNot($user->getKey())
                ->whereRaw(
                    'LOWER(username) = ?',
                    [mb_strtolower($data['username'])]
                )
                ->exists();

            if ($duplicate) {
                throw ValidationException::withMessages([
                    'username' => 'اسم المستخدم مستخدم مسبقًا.',
                ]);
            }

            $this->profiles->update($user, [
                'username' => $data['username'],
                'display_name' => $data['display_name'],
            ]);

            $profileData = [
                'nationality_country_code' =>
                    $data['nationality_country_code'] ?? null,
                'birth_date' =>
                    $data['birth_date'] ?? null,
            ];

            $hasPersonalData = (
                $profileData['nationality_country_code'] !== null
                || $profileData['birth_date'] !== null
            );

            // Do not create empty profiles unnecessarily.
            if ($hasPersonalData || $user->profile()->exists()) {
                $this->profiles->savePersonalDetails(
                    $user,
                    $profileData
                );
            }

            return $user->refresh()->load([
                'profile',
                'contacts',
            ]);
        }, 3);
    }
}