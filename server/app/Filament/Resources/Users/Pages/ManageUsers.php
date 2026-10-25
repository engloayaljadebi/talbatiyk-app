<?php

declare(strict_types=1);

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use App\Models\User;
use App\Services\Business\BusinessCategorySelectionService;
use App\Services\Platform\AdminUserCreationService;
use Filament\Actions\Action;
use Filament\Facades\Filament;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ManageRecords;
use Filament\Schemas\Components\Section;
use Filament\Support\Enums\Width;
use Illuminate\Support\Facades\Gate;
use Symfony\Component\Intl\Countries;

final class ManageUsers extends ManageRecords
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('createUser')
                ->label('إنشاء مستخدم')
                ->color('primary')
                ->visible(fn (): bool => Gate::allows('manageUsers'))
                ->modalHeading('إنشاء حساب ونشاط تجاري')
                ->modalDescription('سيُنشأ طلب اعتماد للمتجر أو المورد، ولن تُفعّل القدرة التجارية قبل الموافقة.')
                ->modalSubmitActionLabel('إنشاء الحساب والنشاط')
                ->modalWidth(Width::FiveExtraLarge)
                ->schema([
                    Section::make('البيانات الأساسية')
                        ->schema([
                            Select::make('account_type')
                                ->label('نوع الحساب')
                                ->options(fn (): array => array_filter([
                                    'shop' => 'عميل (متجر)',
                                    'supplier' => Gate::allows('reviewSupplierApprovals') ? 'مورد' : null,
                                ]))
                                ->required(),

                            TextInput::make('username')
                                ->label('اسم المستخدم')
                                ->required()
                                ->minLength(3)
                                ->maxLength(50),

                            TextInput::make('display_name')
                                ->label('الاسم الكامل للمستخدم')
                                ->required()
                                ->minLength(2)
                                ->maxLength(160),

                            TextInput::make('password')
                                ->label('كلمة المرور')
                                ->password()
                                ->revealable()
                                ->required()
                                ->minLength(8)
                                ->maxLength(72),

                            TextInput::make('password_confirmation')
                                ->label('تأكيد كلمة المرور')
                                ->password()
                                ->required()
                                ->same('password'),
                        ])
                        ->columns(2),

                    Section::make('وسائل الاتصال الشخصية')
                        ->schema([
                            Select::make('contact_type')
                                ->label('نوع الاتصال الأساسي')
                                ->options([
                                    'phone' => 'هاتف',
                                    'email' => 'بريد إلكتروني',
                                ])
                                ->required(),

                            TextInput::make('contact_value')
                                ->label('رقم الهاتف الدولي أو البريد الإلكتروني')
                                ->required()
                                ->maxLength(320),
                        ])
                        ->columns(2),

                    Section::make('البيانات الشخصية')
                        ->schema([
                            Select::make('nationality_country_code')
                                ->label('الجنسية')
                                ->options(fn (): array => class_exists(Countries::class)
                                    ? Countries::getNames('ar')
                                    : ['YE' => 'اليمن', 'SA' => 'السعودية'])
                                ->searchable()
                                ->preload(),

                            DatePicker::make('birth_date')
                                ->label('تاريخ الميلاد')
                                ->maxDate(now()),

                            FileUpload::make('profile_photo')
                                ->label('الصورة الشخصية')
                                ->image()
                                ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/webp'])
                                ->disk('talbatiyk_private')
                                ->directory('staging/admin-user-creation')
                                ->visibility('private')
                                ->maxSize(5120),

                            Select::make('identity_document_type')
                                ->label('نوع وثيقة الهوية')
                                ->options([
                                    'national_id' => 'بطاقة هوية',
                                    'passport' => 'جواز سفر',
                                ])
                                ->placeholder('اختر نوع الوثيقة'),

                            TextInput::make('identity_document_number')
                                ->label('رقم الهوية أو جواز السفر')
                                ->maxLength(100),

                            FileUpload::make('identity_document_front')
                                ->label('صورة الوثيقة من الأمام (عند الحاجة)')
                                ->image()
                                ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/webp'])
                                ->disk('talbatiyk_private')
                                ->directory('staging/admin-user-creation')
                                ->visibility('private')
                                ->maxSize(5120),

                            FileUpload::make('identity_document_back')
                                ->label('صورة الوثيقة من الخلف (عند الحاجة)')
                                ->image()
                                ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/webp'])
                                ->disk('talbatiyk_private')
                                ->directory('staging/admin-user-creation')
                                ->visibility('private')
                                ->maxSize(5120),
                        ])
                        ->columns(2),

                    Section::make('بيانات النشاط التجاري')
                        ->schema([
                            TextInput::make('name')
                                ->label('اسم النشاط التجاري')
                                ->required()
                                ->minLength(2)
                                ->maxLength(200),

                            Select::make('category_id')
                                ->label('فئة النشاط التجاري')
                                ->searchable()
                                ->preload()
                                ->options(fn (): array => app(BusinessCategorySelectionService::class)->selectableLeafOptions())
                                ->required()
                                ->helperText('اختر فئة نهائية نشطة واحدة فقط.')
                                ->columnSpanFull(),

                            Textarea::make('description')
                                ->label('وصف النشاط')
                                ->maxLength(5000)
                                ->columnSpanFull(),

                            FileUpload::make('business_logo')
                                ->label('شعار النشاط التجاري')
                                ->image()
                                ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/webp'])
                                ->disk('talbatiyk_private')
                                ->directory('staging/admin-user-creation')
                                ->visibility('private')
                                ->maxSize(5120),
                        ])
                        ->columns(2),

                    Section::make('بيانات الموقع')
                        ->schema([
                            TextInput::make('location_name')
                                ->label('اسم الموقع')
                                ->required()
                                ->minLength(2)
                                ->maxLength(160),

                            TextInput::make('administrative_area')
                                ->label('المحافظة أو المنطقة الإدارية')
                                ->required()
                                ->minLength(2)
                                ->maxLength(160),

                            TextInput::make('locality')
                                ->label('المدينة')
                                ->required()
                                ->minLength(2)
                                ->maxLength(160),
                        ])
                        ->columns(2),
                ])
                ->action(function (array $data): void {
                    $admin = Filament::auth()->user();

                    abort_unless($admin instanceof User, 403);

                    $created = app(AdminUserCreationService::class)
                        ->create($admin, $data);

                    $accountLabel = $data['account_type'] === 'shop'
                        ? 'العميل (المتجر)'
                        : 'المورد';

                    Notification::make()
                        ->title('تم إنشاء الحساب والنشاط وإرسال طلب الاعتماد')
                        ->body('اسم المستخدم: '.$created->username.' — النوع: '.$accountLabel.' — بانتظار المراجعة.')
                        ->success()
                        ->send();
                }),
        ];
    }
}
