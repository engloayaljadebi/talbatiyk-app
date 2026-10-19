<?php

namespace App\Filament\Pages\Auth;

use Filament\Auth\Pages\Login;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Component;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AdminLogin extends Login
{
    protected function getEmailFormComponent(): Component
    {
        return TextInput::make('username')
            ->label('اسم المستخدم')
            ->required()
            ->maxLength(50)
            ->autocomplete('username')
            ->autofocus();
    }

    protected function getCredentialsFromFormData(
        #[\SensitiveParameter] array $data,
    ): array {
        return [
            'username' => Str::lower(trim($data['username'])),
            'password' => $data['password'],
            'status' => 'active',
        ];
    }

    protected function throwFailureValidationException(): never
    {
        throw ValidationException::withMessages([
            'data.username' => 'بيانات الدخول غير صحيحة أو لا تملك صلاحية الإدارة.',
        ]);
    }
}
