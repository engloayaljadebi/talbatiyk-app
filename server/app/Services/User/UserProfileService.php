<?php

namespace App\Services\User;

use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Support\Arr;
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
}
