<?php

declare(strict_types=1);

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use App\Models\User;
use App\Services\Platform\AdminUserCreationService;
use Filament\Actions\Action;
use Filament\Facades\Filament;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ManageRecords;
use Filament\Schemas\Components\Section;
use Illuminate\Support\Facades\Gate;

final class ManageUsers extends ManageRecords
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('createUser')
                ->label('إنشاء مستخدم')
                ->color('primary')
                ->visible(
                    fn (): bool => Gate::allows('manageUsers')
                )
                ->modalHeading('إنشاء حساب مستخدم جديد')
                ->modalSubmitActionLabel('إنشاء المستخدم')
                ->schema([
                    Section::make('بيانات الحساب')->schema([
                        TextInput::make('username')
                            ->label('اسم المستخدم')
                            ->required()
                            ->minLength(3)
                            ->maxLength(50),

                        TextInput::make('display_name')
                            ->label('الاسم الظاهر')
                            ->required()
                            ->minLength(2)
                            ->maxLength(160),

                        TextInput::make('password')
                            ->label('كلمة المرور')
                            ->password()
                            ->revealable()
                            ->required()
                            ->minLength(8),

                        TextInput::make('password_confirmation')
                            ->label('تأكيد كلمة المرور')
                            ->password()
                            ->required()
                            ->same('password'),
                    ])->columns(2),

                    Section::make('وسيلة الاتصال')->schema([
                        Select::make('contact_type')
                            ->label('نوع الاتصال')
                            ->options([
                                'phone' => 'هاتف',
                                'email' => 'بريد إلكتروني',
                            ])
                            ->default('phone')
                            ->required(),

                        TextInput::make('contact_value')
                            ->label('رقم الهاتف أو البريد الإلكتروني')
                            ->helperText('مثال للهاتف: +967777123456')
                            ->required(),
                    ])->columns(2),
                ])
                ->action(function (array $data): void {
                    $admin = Filament::auth()->user();

                    abort_unless($admin instanceof User, 403);

                    $created = app(AdminUserCreationService::class)
                        ->create($admin, $data);

                    Notification::make()
                        ->title('تم إنشاء المستخدم بنجاح')
                        ->body('اسم المستخدم: '.$created->username)
                        ->success()
                        ->send();
                }),
        ];
    }
}