<?php

declare(strict_types=1);

namespace App\Filament\Resources\Users;

use App\Filament\Resources\Users\Pages\ManageUsers;
use App\Models\User;
use Filament\Actions\Action;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use App\Services\Platform\AdminUserUpdateService;
use Filament\Facades\Filament;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Gate;

final class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationLabel = 'إدارة المستخدمين';

    protected static ?string $modelLabel = 'مستخدم';

    protected static ?string $pluralModelLabel = 'المستخدمون';

    public static function canViewAny(): bool
    {
        $admin = Filament::auth()->user();

        return $admin instanceof User
            && Gate::forUser($admin)->allows('manageUsers');
    }

    public static function canCreate(): bool
    {
        // Account creation uses the protected header action.
        return false;
    }

    public static function canEdit(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function canDelete(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function canDeleteAny(): bool
    {
        return false;
    }

    public static function getEloquentQuery(): Builder
    {
        abort_unless(static::canViewAny(), 403);

        return parent::getEloquentQuery();
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('username')
                    ->label('اسم المستخدم')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('display_name')
                    ->label('الاسم الظاهر')
                    ->searchable(),

                TextColumn::make('status')
                    ->label('حالة الحساب')
                    ->badge()
                    ->formatStateUsing(
                        fn (string $state): string => match ($state) {
                            'active' => 'نشط',
                            'suspended' => 'موقوف مؤقتًا',
                            'disabled' => 'معطّل',
                            default => $state,
                        }
                    )
                    ->color(
                        fn (string $state): string => match ($state) {
                            'active' => 'success',
                            'suspended' => 'warning',
                            'disabled' => 'danger',
                            default => 'gray',
                        }
                    ),

                TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->sortable(),
            ])
            ->recordActions([
                Action::make('editAccount')
                    ->label('تعديل البيانات')
                    ->color('gray')
                    ->authorize(
                        fn (User $record): bool =>
                            static::canView($record)
                    )
                    ->modalHeading('تعديل بيانات المستخدم')
                    ->modalSubmitActionLabel('حفظ التعديلات')
                    ->fillForm(
                        fn (User $record): array => [
                            'username' => $record->username,
                            'display_name' => $record->display_name,
                            'nationality_country_code' =>
                                $record->profile?->nationality_country_code,
                            'birth_date' =>
                                $record->profile?->birth_date?->format('Y-m-d'),
                        ]
                    )
                    ->schema([
                        Section::make('بيانات الحساب')
                            ->schema([
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
                            ])
                            ->columns(2),

                        Section::make('البيانات الشخصية')
                            ->schema([
                                TextInput::make('nationality_country_code')
                                    ->label('رمز دولة الجنسية')
                                    ->helperText(
                                        'رمز الدولة من حرفين مثل YE أو SA'
                                    )
                                    ->maxLength(2),

                                DatePicker::make('birth_date')
                                    ->label('تاريخ الميلاد')
                                    ->maxDate(now()),
                            ])
                            ->columns(2),
                    ])
                    ->action(function (
                        User $record,
                        array $data,
                    ): void {
                        $admin = Filament::auth()->user();

                        abort_unless($admin instanceof User, 403);

                        app(AdminUserUpdateService::class)
                            ->update($admin, $record, $data);

                        Notification::make()
                            ->title('تم تحديث بيانات المستخدم')
                            ->success()
                            ->send();
                    }),
                ViewAction::make()
                    ->label('التفاصيل')
                    ->authorize(
                        fn (User $record): bool =>
                            static::canViewAny()
                    ),
            ])
            ->toolbarActions([]);
    }

    public static function canView(
        \Illuminate\Database\Eloquent\Model $record
    ): bool {
        return $record instanceof User && static::canViewAny();
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->components([
            Section::make('بيانات الحساب')
                ->schema([
                    TextEntry::make('username')
                        ->label('اسم المستخدم'),

                    TextEntry::make('display_name')
                        ->label('الاسم الظاهر'),

                    TextEntry::make('status')
                        ->label('حالة الحساب')
                        ->formatStateUsing(
                            fn (?string $state): string => match ($state) {
                                'active' => 'نشط',
                                'suspended' => 'موقوف مؤقتًا',
                                'disabled' => 'معطّل',
                                default => $state ?? 'غير محدد',
                            }
                        ),

                    TextEntry::make('created_at')
                        ->label('تاريخ إنشاء الحساب')
                        ->dateTime(),
                ])
                ->columns(2),

            Section::make('وسائل الاتصال')
                ->schema([
                    RepeatableEntry::make('contacts')
                        ->label('وسائل الاتصال المسجلة')
                        ->schema([
                            TextEntry::make('type')
                                ->label('نوع الاتصال')
                                ->formatStateUsing(
                                    fn (?string $state): string =>
                                        match ($state) {
                                            'phone' => 'هاتف',
                                            'email' => 'بريد إلكتروني',
                                            default => $state ?? 'غير محدد',
                                        }
                                ),

                            TextEntry::make('value')
                                ->label('وسيلة الاتصال'),

                            TextEntry::make('is_primary')
                                ->label('الاتصال الرئيسي')
                                ->formatStateUsing(
                                    fn (?bool $state): string =>
                                        $state ? 'نعم' : 'لا'
                                ),

                            TextEntry::make('verified_at')
                                ->label('تاريخ التوثيق')
                                ->dateTime()
                                ->placeholder('غير موثق'),
                        ])
                        ->columns(2),
                ]),

            Section::make('الملف الشخصي')
                ->schema([
                    TextEntry::make('profile.nationality_country_code')
                        ->label('رمز دولة الجنسية')
                        ->placeholder('غير مسجل'),

                    TextEntry::make('profile.birth_date')
                        ->label('تاريخ الميلاد')
                        ->date('Y-m-d')
                        ->placeholder('غير مسجل'),
                ])
                ->columns(2),

            Section::make('العلاقات التجارية')
                ->schema([
                    TextEntry::make('memberships_count')
                        ->label('عدد العضويات')
                        ->state(
                            fn (User $record): int =>
                                $record->memberships()->count()
                        ),

                    TextEntry::make('verifications_count')
                        ->label('عدد عمليات التوثيق')
                        ->state(
                            fn (User $record): int =>
                                $record->verifications()->count()
                        ),
                ])
                ->columns(2),
        ]);
    }
    public static function getPages(): array
    {
        return [
            'index' => ManageUsers::route('/'),
        ];
    }
}