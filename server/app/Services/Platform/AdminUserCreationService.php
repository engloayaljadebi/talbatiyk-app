<?php

declare(strict_types=1);

namespace App\Services\Platform;

use App\Models\User;
use App\Models\UserContact;
use App\Rules\MaxBytes;
use App\Services\User\UserIdentityCreationService;
use App\Support\ContactValueNormalizer;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;

final class AdminUserCreationService
{
    public function __construct(
        private readonly UserIdentityCreationService $identityCreation,
    ) {}

    /** @param array<string, mixed> $input */
    public function create(User $admin, array $input): User
    {
        Gate::forUser($admin)->authorize('manageUsers');

        $input['username'] = ContactValueNormalizer::username(
            $input['username'] ?? null
        );

        $input['contact_type'] = strtolower(
            trim((string) ($input['contact_type'] ?? ''))
        );

        $input['contact_value'] = ContactValueNormalizer::contact(
            $input['contact_type'],
            $input['contact_value'] ?? null
        );

        $data = Validator::make($input, [
            'username' => [
                'required', 'string', 'min:3', 'max:50',
                'regex:/^[\pL\pN._-]+$/u',
            ],
            'display_name' => [
                'required', 'string', 'min:2', 'max:160',
            ],
            'password' => [
                'required', 'confirmed',
                Password::min(8), 'max:72',
                new MaxBytes(72),
            ],
            'password_confirmation' => ['required', 'string'],
            'contact_type' => [
                'required', Rule::in(['phone', 'email']),
            ],
            'contact_value' => [
                'required', 'string', 'max:320',
                ...($input['contact_type'] === 'email'
                    ? ['email:rfc']
                    : ['regex:/^\+[1-9]\d{7,14}$/']),
            ],
        ])->validate();

        try {
            return DB::transaction(function () use ($admin, $data): User {
                Gate::forUser($admin)->authorize('manageUsers');

                if (
                    User::withTrashed()
                        ->whereRaw('LOWER(username) = ?', [$data['username']])
                        ->exists()
                ) {
                    throw ValidationException::withMessages([
                        'username' => 'اسم المستخدم مستخدم مسبقًا.',
                    ]);
                }

                $contacts = UserContact::withTrashed()
                    ->where('type', $data['contact_type']);

                if ($data['contact_type'] === 'email') {
                    $contacts->whereRaw(
                        'LOWER(value) = ?',
                        [$data['contact_value']]
                    );
                } else {
                    $contacts->where(
                        'value',
                        $data['contact_value']
                    );
                }

                if ($contacts->exists()) {
                    throw ValidationException::withMessages([
                        'contact_value' => 'وسيلة الاتصال مستخدمة مسبقًا.',
                    ]);
                }

                return $this->identityCreation->create($data);
            }, 3);
        } catch (UniqueConstraintViolationException $exception) {
            $message = $exception->getMessage();

            if (str_contains($message, 'users_username_case_insensitive_unique')) {
                throw ValidationException::withMessages([
                    'username' => 'اسم المستخدم مستخدم مسبقًا.',
                ]);
            }

            if (str_contains($message, 'user_contacts_type_value_unique')) {
                throw ValidationException::withMessages([
                    'contact_value' => 'وسيلة الاتصال مستخدمة مسبقًا.',
                ]);
            }

            throw $exception;
        }
    }
}
