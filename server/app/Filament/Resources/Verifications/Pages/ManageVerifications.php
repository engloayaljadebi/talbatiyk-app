<?php

namespace App\Filament\Resources\Verifications\Pages;

use App\Filament\Resources\Verifications\VerificationResource;
use App\Models\User;
use App\Services\Business\BusinessCategorySelectionService;
use App\Services\Platform\AdminSupplierCreationService;
use Filament\Actions\Action;
use Filament\Facades\Filament;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ManageRecords;
use Filament\Schemas\Components\Section;
use Filament\Support\Enums\Width;
use Illuminate\Support\Facades\Gate;

class ManageVerifications extends ManageRecords
{
    protected static string $resource = VerificationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('createSupplierUser')
                ->label('إنشاء مستخدم مورد')
                ->color('primary')
                ->visible(fn (): bool => Gate::allows('reviewSupplierApprovals'))
                ->modalHeading('إنشاء مستخدم ونشاط مورد')
                ->modalDescription('يُنشأ طلب اعتماد معلّق، ولا يتم تفعيل المورد قبل موافقة الإدارة.')
                ->modalSubmitActionLabel('إنشاء المورد')
                ->modalWidth(Width::FiveExtraLarge)
                ->schema([
                    Section::make('حساب المستخدم')->schema([
                        TextInput::make('username')->label('اسم المستخدم')->required()->minLength(3)->maxLength(50),
                        TextInput::make('display_name')->label('الاسم الظاهر')->required()->minLength(2)->maxLength(160),
                        TextInput::make('password')->label('كلمة المرور')->password()->revealable()->required()->minLength(8),
                        TextInput::make('password_confirmation')->label('تأكيد كلمة المرور')->password()->required()->same('password'),
                        Select::make('contact_type')->label('نوع الاتصال الشخصي')->options([
                            'phone' => 'هاتف', 'email' => 'بريد إلكتروني',
                        ])->default('phone')->required(),
                        TextInput::make('contact_value')->label('الهاتف الدولي أو البريد')->required()
                            ->helperText('الهاتف بصيغة +967777123456'),
                    ])->columns(2),
                    Section::make('بيانات النشاط')->schema([
                        TextInput::make('name')->label('اسم النشاط')->required()->minLength(2)->maxLength(200),
                        TextInput::make('legal_name')->label('الاسم القانوني')->maxLength(250),
                        Select::make('category_id')
                            ->label('فئة النشاط التجاري')
                            ->searchable()
                            ->preload()
                            ->options(fn (): array => app(BusinessCategorySelectionService::class)->selectableLeafOptions())
                            ->required()
                            ->helperText('اختر فئة نشاط واحدة فقط.')
                            ->columnSpanFull(),
                        Textarea::make('description')->label('الوصف')->maxLength(5000)->columnSpanFull(),
                    ])->columns(2),
                    Section::make('الموقع الرئيسي')->schema([
                        TextInput::make('location_name')->label('اسم الموقع')->default('المقر الرئيسي')->required()->minLength(2)->maxLength(160),
                        Select::make('location_type')->label('نوع الموقع')->options([
                            'store' => 'متجر', 'warehouse' => 'مستودع', 'office' => 'مكتب', 'branch' => 'فرع',
                        ])->default('store')->required(),
                        TextInput::make('timezone')->label('المنطقة الزمنية')->default('Asia/Aden')->required()->maxLength(64),
                        TextInput::make('country_code')->label('رمز البلد')->default('YE')->required()->minLength(2)->maxLength(2),
                        TextInput::make('administrative_area')->label('المحافظة')->maxLength(160),
                        TextInput::make('locality')->label('المدينة')->maxLength(160),
                        TextInput::make('district')->label('الحي')->maxLength(160),
                        TextInput::make('street_address')->label('العنوان')->maxLength(300),
                    ])->columns(2),
                    Section::make('التواصل التجاري')->schema([
                        Select::make('business_contact_type')->label('نوع التواصل')->options([
                            'phone' => 'هاتف', 'whatsapp' => 'واتساب', 'email' => 'بريد إلكتروني', 'website' => 'موقع إلكتروني',
                        ])->default('whatsapp')->required(),
                        TextInput::make('business_contact_value')->label('رقم التواصل أو البريد أو الرابط')->required()->maxLength(500),
                    ])->columns(2),
                ])
                ->action(function (array $data): void {
                    $admin = Filament::auth()->user();
                    abort_unless($admin instanceof User, 403);
                    $data['category_ids'] = [$data['category_id'] ?? null];
                    unset($data['category_id']);
                    $business = app(AdminSupplierCreationService::class)->create($admin, $data);
                    Notification::make()
                        ->title('تم إنشاء المورد وإرسال طلب الاعتماد')
                        ->body('النشاط: '.$business->name.' — بانتظار المراجعة.')
                        ->success()
                        ->send();
                }),
        ];
    }
}
