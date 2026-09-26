<?php

namespace App\Http\Requests\Api\V1\Auth;

use App\Models\User;
use App\Support\ContactValueNormalizer;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    protected function prepareForValidation(): void
    {
        $normalized = [];

        if ($this->has('username')) {
            $normalized['username'] = ContactValueNormalizer::username(
                $this->input('username'),
            );
        }

        if ($this->has('display_name')) {
            $normalized['display_name'] = trim(
                (string) $this->input('display_name'),
            );
        }

        if ($normalized !== []) {
            $this->merge($normalized);
        }
    }

    public function rules(): array
    {
        return [
            'username' => [
                'sometimes',
                'required',
                'string',
                'min:3',
                'max:50',
                'regex:/^[\pL\pN._-]+$/u',
            ],

            'display_name' => [
                'sometimes',
                'required',
                'string',
                'min:2',
                'max:160',
            ],

            /** @hidden */
            'password' => [
                'missing',
            ],

            /** @hidden */
            'status' => [
                'missing',
            ],

            /** @hidden */
            'last_login_at' => [
                'missing',
            ],

            /** @hidden */
            'contact' => [
                'missing',
            ],

            /** @hidden */
            'contacts' => [
                'missing',
            ],
        ];
    }

    public function after(): array
    {
        return [
            function (Validator $validator): void {
                if (
                    $validator->errors()->isNotEmpty()
                    || ! $this->has('username')
                ) {
                    return;
                }

                $user = $this->user();

                if (! $user instanceof User) {
                    return;
                }

                $usernameExists = User::withTrashed()
                    ->whereKeyNot($user->getKey())
                    ->whereRaw(
                        'LOWER(username) = ?',
                        [$this->string('username')->lower()->toString()],
                    )
                    ->exists();

                if ($usernameExists) {
                    $validator->errors()->add(
                        'username',
                        'اسم المستخدم مستخدم مسبقًا.',
                    );
                }
            },
        ];
    }
}
