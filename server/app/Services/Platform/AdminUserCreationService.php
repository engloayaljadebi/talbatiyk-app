<?php

declare(strict_types=1);

namespace App\Services\Platform;

use App\Models\User;
use App\Models\UserContact;
use App\Rules\MaxBytes;
use App\Services\User\UserIdentityCreationService;
use App\Services\User\UserProfileService;
use App\Support\ContactValueNormalizer;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Components\Utilities\Set;

final class AdminUserCreationService
{
    public function __construct(
        private readonly UserIdentityCreationService $identityCreation,
        private readonly UserProfileService $profiles,
        private readonly AdminSupplierCreationService $businessCreation,
    ) {
    }

    /** @param array<string, mixed> $input */
    public function create(User $admin, array $input): User
    {
        Gate::forUser($admin)->authorize('manageUsers');

        $assetStorage = app(\App\Services\User\PrivateUserAssetStorage::class);

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

        $additionalContactType = strtolower(trim(
            (string) ($input['additional_contact_type'] ?? '')
        ));
        $input['additional_contact_type'] = $additionalContactType === ''
            ? null
            : $additionalContactType;

        $additionalContactValue = trim(
            (string) ($input['additional_contact_value'] ?? '')
        );
        $input['additional_contact_value'] = $additionalContactValue === ''
            ? null
            : $additionalContactValue;

        if (
            in_array($input['additional_contact_type'], ['phone', 'email'], true)
            && $input['additional_contact_value'] !== null
        ) {
            $input['additional_contact_value'] = ContactValueNormalizer::contact(
                $input['additional_contact_type'],
                $input['additional_contact_value'],
            );
        }

        $country = $input['nationality_country_code'] ?? null;

        if (is_string($country)) {
            $country = strtoupper(trim($country));
            $country = $country === '' ? null : $country;
        }

        $input['nationality_country_code'] = $country;

        $birthDate = $input['birth_date'] ?? null;
        $input['birth_date'] = $birthDate === '' ? null : $birthDate;

        $identityDocumentType = trim((string) ($input['identity_document_type'] ?? ''));
        $input['identity_document_type'] = $identityDocumentType === '' ? null : $identityDocumentType;

        $identityDocumentNumber = trim((string) ($input['identity_document_number'] ?? ''));
        $input['identity_document_number'] = $identityDocumentNumber === '' ? null : $identityDocumentNumber;

        try {
            $data = Validator::make($input, [
                'account_type' => [
                    'required',
                    Rule::in(['shop', 'supplier']),
                ],
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
                    'required',
                    'string',
                    'max:320',

                    ...($input['contact_type'] === 'email'
                        ? ['email:rfc']
                        : ['regex:/^[0-9]{9}$/']),
                ],
                'additional_contact_type' => [
                    'nullable', 'required_with:additional_contact_value',
                    Rule::in(['phone', 'email']),
                ],
                'additional_contact_value' => [
                    'nullable', 'required_with:additional_contact_type',
                    'string', 'max:320',
                    ...(($input['additional_contact_type'] ?? null) === 'email'
                        ? ['email:rfc']
                        : ((($input['additional_contact_type'] ?? null) === 'phone')
                            ? ['regex:/^\+[1-9]\d{7,14}$/']
                            : [])),
                ],
                'nationality_country_code' => [
                    'nullable', 'string', 'size:2', 'regex:/^[A-Z]{2}$/',
                ],
                'birth_date' => [
                    'nullable', 'date_format:Y-m-d', 'before_or_equal:today',
                ],
                'identity_document_type' => [
                    'nullable',
                    'required_with:identity_document_number,identity_document_front,identity_document_back',
                    Rule::in(['national_id', 'passport']),
                ],
                'identity_document_number' => [
                    'nullable',
                    'required_with:identity_document_type,identity_document_front,identity_document_back',
                    'string', 'max:100',
                ],
                'profile_photo' => ['nullable', 'string', 'max:255'],
                'identity_document_front' => ['nullable', 'string', 'max:255'],
                'identity_document_back' => ['nullable', 'string', 'max:255'],
                'business_logo' => ['nullable', 'string', 'max:255'],
            ])->validate();
        } catch (\Throwable $exception) {
            $assetStorage->cleanupStaging($input);
            throw $exception;
        }

        $storedAssetPaths = [];
        $hasAssetPayload = false;
        foreach ([
            'profile_photo',
            'identity_document_type',
            'identity_document_number',
            'identity_document_front',
            'identity_document_back',
            'business_logo',
        ] as $assetField) {
            if (isset($input[$assetField]) && $input[$assetField] !== '') {
                $hasAssetPayload = true;
                break;
            }
        }

        try {
            return DB::transaction(function () use ($admin, $data, $input, $assetStorage, &$storedAssetPaths): User {
                Gate::forUser($admin)->authorize('manageUsers');

                // Supplier creation retains the previous review-permission requirement.
                if (($data['account_type'] ?? null) === 'supplier') {
                    Gate::forUser($admin)->authorize('reviewSupplierApprovals');
                }

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

                if (($data['additional_contact_value'] ?? null) !== null) {
                    $additionalType = $data['additional_contact_type'];
                    $additionalValue = $data['additional_contact_value'];

                    $primaryComparable = $data['contact_type'] === 'email'
                        ? strtolower($data['contact_value'])
                        : $data['contact_value'];
                    $additionalComparable = $additionalType === 'email'
                        ? strtolower($additionalValue)
                        : $additionalValue;

                    if (
                        $additionalType === $data['contact_type']
                        && $additionalComparable === $primaryComparable
                    ) {
                        throw ValidationException::withMessages([
                            'additional_contact_value' => 'يجب أن تختلف وسيلة الاتصال الإضافية عن الأساسية.',
                        ]);
                    }

                    $additionalContacts = UserContact::withTrashed()
                        ->where('type', $additionalType);

                    if ($additionalType === 'email') {
                        $additionalContacts->whereRaw('LOWER(value) = ?', [strtolower($additionalValue)]);
                    } else {
                        $additionalContacts->where('value', $additionalValue);
                    }

                    if ($additionalContacts->exists()) {
                        throw ValidationException::withMessages([
                            'additional_contact_value' => 'وسيلة الاتصال الإضافية مستخدمة مسبقًا.',
                        ]);
                    }
                }

                $user = $this->identityCreation->create($data);

                if (($data['additional_contact_value'] ?? null) !== null) {
                    $user->contacts()->create([
                        'type' => $data['additional_contact_type'],
                        'value' => $data['additional_contact_value'],
                        'is_primary' => false,
                        'verified_at' => null,
                    ]);
                }

                $profileData = [
                    'nationality_country_code' => $data['nationality_country_code'] ?? null,
                    'birth_date' => $data['birth_date'] ?? null,
                ];

                if (
                    $profileData['nationality_country_code'] !== null
                    || $profileData['birth_date'] !== null
                ) {
                    $this->profiles->savePersonalDetails($user, $profileData);
                }

                $businessInput = [
                    'category_ids' => [$input['category_id'] ?? null],
                    'name' => $input['name'] ?? null,
                    'legal_name' => $input['legal_name'] ?? null,
                    'description' => $input['description'] ?? null,
                    'location_name' => $input['location_name'] ?? null,
                    'location_type' => $input['location_type']
                        ?? ($data['account_type'] === 'supplier' ? 'warehouse' : 'store'),
                    'timezone' => $input['timezone'] ?? 'Asia/Aden',
                    'country_code' => $input['country_code'] ?? 'YE',
                    'administrative_area' => $input['administrative_area'] ?? null,
                    'locality' => $input['locality'] ?? null,
                    'district' => $input['district'] ?? null,
                    'street_address' => $input['street_address'] ?? null,
                    'address_notes' => $input['address_notes'] ?? null,
                    'latitude' => $input['latitude'] ?? null,
                    'longitude' => $input['longitude'] ?? null,
                    'business_contact_type' => $input['business_contact_type'] ?? null,
                    'business_contact_value' => $input['business_contact_value'] ?? null,
                    'business_contact_label' => $input['business_contact_label'] ?? null,
                    'additional_business_contact_type' => $input['additional_business_contact_type'] ?? null,
                    'additional_business_contact_value' => $input['additional_business_contact_value'] ?? null,
                    'additional_business_contact_label' => $input['additional_business_contact_label'] ?? null,
                ];

                $business = $this->businessCreation->createForExistingUser(
                    $admin,
                    $user,
                    $businessInput,
                    $data['account_type'],
                );

                $storedAssetPaths = $assetStorage->store($user, $business, $input);

                return $user->refresh();
            }, $hasAssetPayload ? 1 : 3);
        } catch (UniqueConstraintViolationException $exception) {
            $assetStorage->cleanup($storedAssetPaths);
            $assetStorage->cleanupStaging($input);

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
        } catch (\Throwable $exception) {
            $assetStorage->cleanup($storedAssetPaths);
            $assetStorage->cleanupStaging($input);
            throw $exception;
        }
    }
}
