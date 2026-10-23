<?php

namespace App\Filament\Resources\BusinessCategories\Pages;

use App\Filament\Resources\BusinessCategories\BusinessCategoryResource;
use App\Models\User;
use App\Services\Business\BusinessCategoryManagementService;
use Filament\Actions\Action;
use Filament\Facades\Filament;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ManageRecords;
use Illuminate\Support\Facades\Gate;

final class ManageBusinessCategories extends ManageRecords
{
    protected static string $resource = BusinessCategoryResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('createCategory')
                ->label('إضافة فئة')
                ->color('primary')
                ->visible(
                    fn (): bool => Gate::allows('manageBusinessCategories')
                )
                ->authorize(
                    fn (): bool => Gate::allows('manageBusinessCategories')
                )
                ->modalHeading('إضافة فئة نشاط تجاري')
                ->modalSubmitActionLabel('حفظ الفئة')
                ->schema([
                    TextInput::make('code')
                        ->label('الرمز البرمجي')
                        ->helperText(
                            'أحرف إنجليزية صغيرة وأرقام وشرطة سفلية، ويبدأ بحرف.'
                        )
                        ->required()
                        ->maxLength(80),

                    TextInput::make('name_ar')
                        ->label('اسم الفئة بالعربية')
                        ->required()
                        ->minLength(2)
                        ->maxLength(150),

                    Select::make('parent_id')
                        ->label('الفئة الرئيسية')
                        ->placeholder('فئة رئيسية جديدة')
                        ->options(
                            fn (): array => BusinessCategoryResource::parentOptions()
                        )
                        ->searchable()
                        ->preload(),

                    TextInput::make('sort_order')
                        ->label('ترتيب العرض')
                        ->numeric()
                        ->minValue(0)
                        ->default(0)
                        ->required(),

                    Toggle::make('is_active')
                        ->label('الفئة نشطة')
                        ->default(true),
                ])
                ->action(function (array $data): void {
                    $admin = Filament::auth()->user();
                    abort_unless($admin instanceof User, 403);

                    app(BusinessCategoryManagementService::class)
                        ->create($admin, $data);

                    Notification::make()
                        ->title('تم إنشاء فئة النشاط')
                        ->success()
                        ->send();
                }),
        ];
    }
}
