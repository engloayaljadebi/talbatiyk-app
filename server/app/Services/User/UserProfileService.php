<?php

namespace App\Services\User;

use App\Models\User;
use App\Models\UserProfile;
use Illuminate\Database\QueryException;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class UserProfileService
{
    /**
     * Update the authenticated user's basic identity fields only.
     *
     * @param  array<string, mixed>  $data
     */
    public function update(
        User $user,
        array $data,
    ): User {
        $attributes = Arr::only(
            $data,
            [
                'username',
                'display_name',
            ],
        );

        if ($attributes !== []) {
            $user->fill($attributes);

            try {
                $user->getConnection()->transaction(fn () => $user->save());
            } catch (QueryException $exception) {
                $sqlState = $exception->errorInfo[0] ?? null;
                $constraint = $exception->errorInfo[2] ?? '';

                if (
                    $sqlState === '23505'
                    && str_contains(
                        (string) $constraint,
                        'users_username_case_insensitive_unique',
                    )
                ) {
                    throw ValidationException::withMessages([
                        'username' => [
                            'اسم المستخدم مستخدم مسبقًا.',
                        ],
                    ]);
                }

                throw $exception;
            }
        }

        return $user->load('contacts');
    }

    /**
     * Create or update a user's personal details without duplication.
     *
     * @param  array<string, mixed>  $data
     */
    public function savePersonalDetails(
        User $user,
        array $data,
    ): UserProfile {
        $attributes = Arr::only($data, [
            'nationality_country_code',
            'birth_date',
        ]);

        $attributes = Validator::make(
            $attributes,
            [
                'nationality_country_code' => [
                    'sometimes',
                    'nullable',
                    'string',
                    'size:2',
                    'regex:/^[A-Z]{2}$/',
                ],
                'birth_date' => [
                    'sometimes',
                    'nullable',
                    'date_format:Y-m-d',
                    'before_or_equal:today',
                ],
            ]
        )->validate();

        return $user->getConnection()->transaction(
            function () use ($user, $attributes): UserProfile {
                $profile = $user->profile()->createOrFirst([]);

                if ($attributes !== []) {
                    $profile->fill($attributes);
                    $profile->save();
                }

                return $profile->refresh();
            }
        );
    }
}
