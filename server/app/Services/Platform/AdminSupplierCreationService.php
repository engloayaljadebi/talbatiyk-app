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

    /**
     * Create a commercial business for an identity that was already created
     * by AdminUserCreationService. The surrounding transaction rolls back
     * the identity if business onboarding or approval creation fails.
     *
     * @param  array<string, mixed>  $input
     */
    public function createForExistingUser(
        User $admin,
        User $user,
        array $input,
        string $capability,
    ): Business {
        Gate::forUser($admin)->authorize('manageUsers');

        if (! in_array($capability, ['shop', 'supplier'], true)) {
            throw ValidationException::withMessages([
                'account_type' => 'نوع النشاط غير صالح.',
            ]);
        }

        $businessContactType = strtolower(trim((string) ($input['business_contact_type'] ?? '')));
        $businessContactValue = trim((string) ($input['business_contact_value'] ?? ''));

        $input['business_contact_type'] = $businessContactType === '' ? null : $businessContactType;
        $input['business_contact_value'] = $businessContactValue === '' ? null : $businessContactValue;

        if ($input['business_contact_type'] !== null && $input['business_contact_value'] !== null) {
            $input['business_contact_value'] = ContactValueNormalizer::contact(
                $input['business_contact_type'],
                $input['business_contact_value'],
            );
        }

        $additionalBusinessContactType = strtolower(trim(
            (string) ($input['additional_business_contact_type'] ?? '')
        ));
        $input['additional_business_contact_type'] = $additionalBusinessContactType === ''
            ? null
            : $additionalBusinessContactType;

        $additionalBusinessContactValue = trim(
            (string) ($input['additional_business_contact_value'] ?? '')
        );
        $input['additional_business_contact_value'] = $additionalBusinessContactValue === ''
            ? null
            : $additionalBusinessContactValue;

        if (
            in_array(
                $input['additional_business_contact_type'],
                ['phone', 'whatsapp', 'email', 'website'],
                true,
            )
            && $input['additional_business_contact_value'] !== null
        ) {
            $input['additional_business_contact_value'] = ContactValueNormalizer::contact(
                $input['additional_business_contact_type'],
                $input['additional_business_contact_value'],
            );
        }

        $input['country_code'] = strtoupper(trim(
            (string) ($input['country_code'] ?? '')
        ));

        foreach ([
            'name', 'location_name', 'timezone',
            'business_contact_label',
        ] as $field) {
            if (isset($input[$field]) && is_string($input[$field])) {
                $input[$field] = trim($input[$field]);
            }
        }

        foreach ([
            'legal_name', 'description', 'administrative_area',
            'locality', 'district', 'street_address', 'address_notes',
        ] as $field) {
            if (isset($input[$field]) && is_string($input[$field])) {
                $input[$field] = trim($input[$field]) ?: null;
            }
        }

        foreach (['latitude', 'longitude'] as $field) {
            if (
                ! isset($input[$field]) ||
                trim((string) $input[$field]) === ''
            ) {
                $input[$field] = null;
            }
        }

        $contactRules = match ($input['business_contact_type'] ?? null) {
            'phone', 'whatsapp' => ['regex:/^\+[1-9]\d{7,14}$/'],
            'email' => ['email:rfc'],
            'website' => ['url:http,https'],
            default => [],
        };

        $additionalContactRules = match ($input['additional_business_contact_type'] ?? null) {
            'phone', 'whatsapp' => ['regex:/^\+[1-9]\d{7,14}$/'],
            'email' => ['email:rfc'],
            'website' => ['url:http,https'],
            default => [],
        };

        $data = Validator::make($input, [
            'category_ids' => ['required', 'array', 'size:1'],
            'category_ids.*' => ['required', 'uuid', 'distinct'],
            'name' => ['required', 'string', 'min:2', 'max:200'],
            'legal_name' => ['nullable', 'string', 'max:250'],
            'description' => ['nullable', 'string', 'max:5000'],
            'location_name' => ['required', 'string', 'min:2', 'max:160'],
            'location_type' => [
                'required',
                Rule::in(['branch', 'office', 'warehouse', 'store']),
            ],
            'timezone' => ['required', 'string', 'timezone', 'max:64'],
            'country_code' => ['required', 'string', 'size:2', 'alpha'],
            'administrative_area' => ['required', 'string', 'min:2', 'max:160'],
            'locality' => ['required', 'string', 'min:2', 'max:160'],
            'district' => ['nullable', 'string', 'max:160'],
            'street_address' => ['nullable', 'string', 'max:300'],
            'address_notes' => ['nullable', 'string', 'max:2000'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'business_contact_type' => [
                'nullable',
                'required_with:business_contact_value,additional_business_contact_type,additional_business_contact_value',
                Rule::in(['phone', 'whatsapp', 'email', 'website']),
            ],
            'business_contact_value' => [
                'nullable',
                'required_with:business_contact_type,additional_business_contact_type,additional_business_contact_value',
                'string', 'max:500', ...$contactRules,
            ],
            'business_contact_label' => ['nullable', 'string', 'max:120'],
            'additional_business_contact_type' => [
                'nullable', 'required_with:additional_business_contact_value',
                Rule::in(['phone', 'whatsapp', 'email', 'website']),
            ],
            'additional_business_contact_value' => [
                'nullable', 'required_with:additional_business_contact_type',
                'string', 'max:500', ...$additionalContactRules,
            ],
            'additional_business_contact_label' => ['nullable', 'string', 'max:120'],
        ])->validate();

        $verificationType = $capability === 'supplier'
            ? 'supplier_approval'
            : 'shop_approval';

        return DB::transaction(function () use (
            $admin,
            $user,
            $data,
            $capability,
            $verificationType,
        ): Business {
            Gate::forUser($admin)->authorize('manageUsers');

            if (! BusinessRole::query()
                ->where('code', 'owner')
                ->where('is_active', true)
                ->exists()) {
                throw new RuntimeException('Active owner role is missing.');
            }

            if (! DB::table('business_capabilities')
                ->where('code', $capability)
                ->whereNull('retired_at')
                ->exists()) {
                throw new RuntimeException('Requested business capability is missing.');
            }

            if (! DB::table('verification_types')
                ->where('code', $verificationType)
                ->where('subject_kind', 'business')
                ->whereNull('retired_at')
                ->exists()) {
                throw new RuntimeException('Required business approval type is missing.');
            }

            $business = $this->onboarding->create($user, [
                'category_ids' => $data['category_ids'],
                'name' => $data['name'],
                'legal_name' => $data['legal_name'] ?? null,
                'description' => $data['description'] ?? null,
                'capabilities' => [$capability],
                'location' => [
                    'name' => $data['location_name'],
                    'type' => $data['location_type'],
                    'timezone' => $data['timezone'],
                    'country_code' => $data['country_code'],
                    'administrative_area' => $data['administrative_area'] ?? null,
                    'locality' => $data['locality'] ?? null,
                    'district' => $data['district'] ?? null,
                    'street_address' => $data['street_address'] ?? null,
                    'address_notes' => $data['address_notes'] ?? null,
                    'latitude' => $data['latitude'] ?? null,
                    'longitude' => $data['longitude'] ?? null,
                ],
                ...(isset($data['business_contact_type'], $data['business_contact_value']) ? [
                    'contact' => [
                        'type' => $data['business_contact_type'],
                        'value' => $data['business_contact_value'],
                        'label' => $data['business_contact_label'] ?? null,
                    ],
                ] : []),
            ]);

            if (($data['additional_business_contact_value'] ?? null) !== null) {
                $additionalType = $data['additional_business_contact_type'];
                $additionalValue = $data['additional_business_contact_value'];

                $primaryComparable = $data['business_contact_type'] === 'email'
                    ? strtolower($data['business_contact_value'])
                    : $data['business_contact_value'];
                $additionalComparable = $additionalType === 'email'
                    ? strtolower($additionalValue)
                    : $additionalValue;

                if (
                    $additionalType === $data['business_contact_type']
                    && $additionalComparable === $primaryComparable
                ) {
                    throw ValidationException::withMessages([
                        'additional_business_contact_value' => 'يجب أن يختلف الاتصال التجاري الإضافي عن الأساسي.',
                    ]);
                }

                $business->contacts()->create([
                    'type' => $additionalType,
                    'value' => $additionalValue,
                    'label' => $data['additional_business_contact_label'] ?? null,
                    'is_primary' => false,
                    'verified_at' => null,
                ]);
            }

            if (! $business->verifications()
                ->where('verification_type_code', $verificationType)
                ->where('status', 'pending')
                ->exists()) {
                throw new RuntimeException('Pending business approval was not created.');
            }

            if ($business->capabilities()
                ->where('business_capabilities.code', $capability)
                ->exists()) {
                throw new RuntimeException('Commercial capability was enabled before approval.');
            }

            return $business;
        }, 3);
    }

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
            'category_ids' => ['required', 'array', 'size:1'],
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
