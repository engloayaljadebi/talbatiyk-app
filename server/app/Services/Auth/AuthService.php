<?php

/*
|--------------------------------------------------------------------------
| خدمة المصادقة - AuthService
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إنشاء الحساب داخل Transaction.
| - إنشاء وسيلة الاتصال الرئيسية.
| - إصدار Sanctum Token.
| - تسجيل الدخول باسم المستخدم أو البريد أو الهاتف.
| - تحديث last_login_at.
|
| Controller لا يحتوي على Business Logic.
|
*/

namespace App\Services\Auth;

use App\Models\User;
use App\Models\UserContact;
use App\Services\Business\BusinessOnboardingService;
use App\Services\User\UserIdentityCreationService;
use App\Services\User\UserProfileService;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\HttpException;

class AuthService
{
    public function __construct(
        private readonly UserIdentityCreationService $identityCreation,
        private readonly UserProfileService $profiles,
        private readonly BusinessOnboardingService $onboarding,
    ) {}

    /**
     * إنشاء مستخدم ووسيلة اتصاله وإصدار Token.
     *
     * @return array{user: User, token: string}
     */
    public function register(array $data): array
    {
        return DB::transaction(function () use ($data): array {
            $user = $this->identityCreation->create($data);
            $business = null;

            if (isset($data['account_type'])) {
                if (
                    ($data['nationality_country_code'] ?? null) !== null
                    || ($data['birth_date'] ?? null) !== null
                ) {
                    $this->profiles->savePersonalDetails($user, [
                        'nationality_country_code' => $data['nationality_country_code'] ?? null,
                        'birth_date' => $data['birth_date'] ?? null,
                    ]);
                }

                $businessData = [
                    'name' => $data['name'],
                    'legal_name' => $data['legal_name'] ?? null,
                    'description' => $data['description'] ?? null,
                    'category_ids' => [$data['category_id']],
                    'capabilities' => [$data['account_type']],
                    'location' => [
                        'name' => $data['location_name'],
                        'type' => $data['location_type']
                            ?? ($data['account_type'] === 'supplier' ? 'warehouse' : 'store'),
                        'timezone' => $data['timezone'] ?? 'Asia/Aden',
                        'country_code' => $data['country_code'] ?? 'YE',
                        'administrative_area' => $data['administrative_area'],
                        'locality' => $data['locality'],
                        'district' => $data['district'] ?? null,
                        'street_address' => $data['street_address'] ?? null,
                        'address_notes' => $data['address_notes'] ?? null,
                        'latitude' => $data['latitude'] ?? null,
                        'longitude' => $data['longitude'] ?? null,
                    ],
                ];

                if (isset(
                    $data['business_contact_type'],
                    $data['business_contact_value']
                )) {
                    $businessData['contact'] = [
                        'type' => $data['business_contact_type'],
                        'value' => $data['business_contact_value'],
                        'label' => $data['business_contact_label'] ?? null,
                    ];
                }

                $business = $this->onboarding->create(
                    $user,
                    $businessData,
                );
            }

            $token = $user
                ->createToken($data['device_name'])
                ->plainTextToken;

            return [
                'user' => $user->load('contacts'),
                'token' => $token,
                'business' => $business,
            ];
        });
    }

    /**
     * تسجيل الدخول وإصدار Token جديد للجهاز.
     *
     * @return array{user: User, token: string}
     *
     * @throws AuthenticationException
     */
    public function login(array $data): array
    {
        $user = $this->findUserByLogin($data['login']);

        if ($user === null || ! Hash::check($data['password'], $user->password)) {
            throw new AuthenticationException(
                'بيانات تسجيل الدخول غير صحيحة.',
            );
        }

        if ($user->status !== 'active') {
            throw new HttpException(
                403,
                'هذا الحساب غير متاح لتسجيل الدخول حاليًا.',
            );
        }

        $user->forceFill([
            'last_login_at' => now(),
        ])->save();

        $token = $user
            ->createToken($data['device_name'])
            ->plainTextToken;

        return [
            'user' => $user->load('contacts'),
            'token' => $token,
        ];
    }

    /**
     * البحث عن المستخدم بواسطة:
     * username أو email أو phone.
     */
    private function findUserByLogin(string $login): ?User
    {
        if (filter_var($login, FILTER_VALIDATE_EMAIL)) {
            return UserContact::query()
                ->where('type', 'email')
                ->whereRaw('LOWER(value) = ?', [Str::lower($login)])
                ->first()
                ?->user;
        }

        if (preg_match('/^[0-9]{9}$/D', $login) === 1) {
            $byUsername = User::query()
                ->where('username', $login)
                ->first();

            $byPhone = UserContact::query()
                ->where('type', 'phone')
                ->where('value', $login)
                ->first()
                ?->user;

            if (
                $byUsername !== null
                && $byPhone !== null
                && $byUsername->getKey() !== $byPhone->getKey()
            ) {
                return null;
            }

            return $byUsername ?? $byPhone;
        }

        if (str_starts_with($login, '+')) {
            return UserContact::query()
                ->where('type', 'phone')
                ->where('value', $login)
                ->first()
                ?->user;
        }

        return User::query()
            ->whereRaw('LOWER(username) = ?', [Str::lower($login)])
            ->first();
    }
}
