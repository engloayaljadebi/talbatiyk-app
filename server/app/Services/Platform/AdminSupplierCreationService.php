<?php

declare(strict_types=1);

namespace App\Services\Platform;

use App\Models\Business;
use App\Models\BusinessRole;
use App\Models\User;
use App\Models\UserContact;
use App\Rules\MaxBytes;
use App\Services\Business\BusinessOnboardingService;
use App\Services\User\UserIdentityCreationService;
use App\Support\ContactValueNormalizer;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;
use RuntimeException;

final class AdminSupplierCreationService
{
    public function __construct(
        private readonly BusinessOnboardingService $onboarding,
        private readonly UserIdentityCreationService $identityCreation,
    ) {}

    /** @param array<string, mixed> $input */
    public function create(User $admin, array $input): Business
    {
        Gate::forUser($admin)->authorize('reviewSupplierApprovals');

        $input['username'] = ContactValueNormalizer::username($input['username'] ?? null);
        $input['contact_type'] = strtolower(trim((string) ($input['contact_type'] ?? '')));
        $input['contact_value'] = ContactValueNormalizer::contact(
            $input['contact_type'], $input['contact_value'] ?? null,
        );
        $input['business_contact_type'] = strtolower(trim((string) ($input['business_contact_type'] ?? '')));
        $input['business_contact_value'] = ContactValueNormalizer::contact(
            $input['business_contact_type'], $input['business_contact_value'] ?? null,
        );
        $input['country_code'] = strtoupper(trim((string) ($input['country_code'] ?? '')));
        foreach (['display_name', 'name', 'location_name', 'timezone'] as $field) {
            if (isset($input[$field]) && is_string($input[$field])) {
                $input[$field] = trim($input[$field]);
            }
        }
        foreach (['legal_name', 'description', 'administrative_area', 'locality', 'district', 'street_address'] as $field) {
            if (isset($input[$field]) && is_string($input[$field])) {
                $input[$field] = trim($input[$field]) ?: null;
            }
        }

        $contactRules = match ($input['business_contact_type']) {
            'phone', 'whatsapp' => ['regex:/^\+[1-9]\d{7,14}$/'],
            'email' => ['email:rfc'],
            'website' => ['url:http,https'],
            default => [],
        };

        $data = Validator::make($input, [
            'username' => ['required', 'string', 'min:3', 'max:50', 'regex:/^[\pL\pN._-]+$/u'],
            'display_name' => ['required', 'string', 'min:2', 'max:160'],
            'password' => ['bail', 'required', 'confirmed', Password::min(8), 'max:72', new MaxBytes(72)],
            'password_confirmation' => ['required', 'string'],
            'contact_type' => ['required', Rule::in(['phone', 'email'])],
            'contact_value' => [
                'required', 'string', 'max:320',
                ...($input['contact_type'] === 'email' ? ['email:rfc'] : ['regex:/^\+[1-9]\d{7,14}$/']),
            ],
            'category_ids' => ['required', 'array', 'min:1'],
            'category_ids.*' => ['required', 'uuid', 'distinct'],
            'name' => ['required', 'string', 'min:2', 'max:200'],
            'legal_name' => ['nullable', 'string', 'max:250'],
            'description' => ['nullable', 'string', 'max:5000'],
            'location_name' => ['required', 'string', 'min:2', 'max:160'],
            'location_type' => ['required', Rule::in(['branch', 'office', 'warehouse', 'store'])],
            'timezone' => ['required', 'string', 'timezone', 'max:64'],
            'country_code' => ['required', 'string', 'size:2', 'alpha'],
            'administrative_area' => ['nullable', 'string', 'max:160'],
            'locality' => ['nullable', 'string', 'max:160'],
            'district' => ['nullable', 'string', 'max:160'],
            'street_address' => ['nullable', 'string', 'max:300'],
            'business_contact_type' => ['required', Rule::in(['phone', 'whatsapp', 'email', 'website'])],
            'business_contact_value' => ['required', 'string', 'max:500', ...$contactRules],
        ])->validate();

        try {
            return DB::transaction(function () use ($admin, $data): Business {
                Gate::forUser($admin)->authorize('reviewSupplierApprovals');

                if (User::withTrashed()->whereRaw('LOWER(username) = ?', [$data['username']])->exists()) {
                    throw ValidationException::withMessages(['username' => 'اسم المستخدم مستخدم مسبقًا.']);
                }

                $contactQuery = UserContact::withTrashed()->where('type', $data['contact_type']);
                if ($data['contact_type'] === 'email') {
                    $contactQuery->whereRaw('LOWER(value) = ?', [$data['contact_value']]);
                } else {
                    $contactQuery->where('value', $data['contact_value']);
                }
                if ($contactQuery->exists()) {
                    throw ValidationException::withMessages(['contact_value' => 'وسيلة الاتصال مستخدمة مسبقًا.']);
                }

                if (! BusinessRole::query()->where('code', 'owner')->where('is_active', true)->exists()) {
                    throw new RuntimeException('Active owner role is missing.');
                }
                if (! DB::table('business_capabilities')->where('code', 'supplier')->whereNull('retired_at')->exists()) {
                    throw new RuntimeException('Supplier capability is missing.');
                }
                if (! DB::table('verification_types')->where('code', 'supplier_approval')->exists()) {
                    throw new RuntimeException('Supplier approval type is missing.');
                }

                $user = $this->identityCreation->create([
                    'username' => $data['username'],
                    'display_name' => $data['display_name'],
                    'password' => $data['password'],
                    'contact_type' => $data['contact_type'],
                    'contact_value' => $data['contact_value'],
                ]);

                $business = $this->onboarding->create($user, [
                    'category_ids' => $data['category_ids'],
                    'name' => $data['name'],
                    'legal_name' => $data['legal_name'] ?? null,
                    'description' => $data['description'] ?? null,
                    'capabilities' => ['supplier'],
                    'location' => [
                        'name' => $data['location_name'],
                        'type' => $data['location_type'],
                        'timezone' => $data['timezone'],
                        'country_code' => $data['country_code'],
                        'administrative_area' => $data['administrative_area'] ?? null,
                        'locality' => $data['locality'] ?? null,
                        'district' => $data['district'] ?? null,
                        'street_address' => $data['street_address'] ?? null,
                    ],
                    'contact' => [
                        'type' => $data['business_contact_type'],
                        'value' => $data['business_contact_value'],
                    ],
                ]);

                if (! $business->memberships()->where('user_id', $user->id)
                    ->where('status', 'active')->whereHas('roles', fn ($query) => $query->where('business_roles.code', 'owner'))->exists()) {
                    throw new RuntimeException('Owner membership was not created.');
                }
                if (! $business->verifications()->where('verification_type_code', 'supplier_approval')
                    ->where('status', 'pending')->exists()) {
                    throw new RuntimeException('Pending supplier approval was not created.');
                }
                if ($business->capabilities()->where('business_capabilities.code', 'supplier')->exists()) {
                    throw new RuntimeException('Supplier capability enabled before approval.');
                }

                return $business;
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
                    'contact_value' => 'وسيلة الاتصال مستخدمة في حساب آخر.',
                ]);
            }

            throw $exception;
        }
    }
}
