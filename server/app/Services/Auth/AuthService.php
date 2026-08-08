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
use Illuminate\Auth\AuthenticationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\HttpException;

class AuthService
{
    /**
     * إنشاء مستخدم ووسيلة اتصاله وإصدار Token.
     *
     * @return array{user: User, token: string}
     */
    public function register(array $data): array
    {
        return DB::transaction(function () use ($data): array {
            $user = User::create([
                'username' => $data['username'],
                'display_name' => $data['display_name'],
                'password' => $data['password'],
                'status' => 'active',
            ]);

            $user->contacts()->create([
                'type' => $data['contact_type'],
                'value' => $data['contact_value'],
                'is_primary' => true,
            ]);

            $token = $user
                ->createToken($data['device_name'])
                ->plainTextToken;

            return [
                'user' => $user->load('contacts'),
                'token' => $token,
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
