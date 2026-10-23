<?php

namespace App\Filament\Resources\BusinessCategories;

use App\Filament\Resources\BusinessCategories\Pages\ManageBusinessCategories;
use App\Models\BusinessCategory;
use App\Models\User;
use App\Services\Business\BusinessCategoryManagementService;
use Filament\Actions\Action;
use Filament\Facades\Filament;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Gate;

final class BusinessCategoryResource extends Resource
{
    protected static ?string $model = BusinessCategory::class;

    protected static ?string $navigationLabel = 'فئات الأنشطة';

    protected static ?string $modelLabel = 'فئة نشاط';

    protected static ?string $pluralModelLabel = 'فئات الأنشطة التجارية';

    public static function canViewAny(): bool
    {
        $user = Filament::auth()->user();

        return $user instanceof User
            && Gate::forUser($user)->allows('manageBusinessCategories');
    }

    public static function canView(Model $record): bool
    {
        return $record instanceof BusinessCategory
            && self::canViewAny();
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(Model $record): bool
    {
        return false;
    }

    public static function canDelete(Model $record): bool
    {
        return false;
    }

    public static function canDeleteAny(): bool
    {
        return false;
    }

    public static function getEloquentQuery(): Builder
    {
        abort_unless(self::canViewAny(), 403);

        return parent::getEloquentQuery()->with('parent');
    }

    public static function parentOptions(): array
    {
        return BusinessCategory::query()
            ->where('is_active', true)
            ->whereDoesntHave('businesses')
            ->orderBy('sort_order')
            ->orderBy('name_ar')
            ->pluck('name_ar', 'id')
            ->all();
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('sort_order')
            ->columns([
                TextColumn::make('name_ar')
                    ->label('اسم الفئة')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('code')
                    ->label('رمز الفئة')
                    ->searchable(),

                TextColumn::make('parent.name_ar')
                    ->label('الفئة الرئيسية')
                    ->placeholder('فئة رئيسية'),

                TextColumn::make('is_active')
                    ->label('الحالة')
                    ->badge()
                    ->formatStateUsing(
                        fn (bool $state): string => $state ? 'نشطة' : 'معطلة'
                    )
                    ->color(
                        fn (bool $state): string => $state ? 'success' : 'danger'
                    ),

                TextColumn::make('sort_order')
                    ->label('الترتيب')
                    ->sortable(),
            ])
            ->recordActions([
                Action::make('editCategory')
                    ->label('تعديل')
                    ->color('gray')
                    ->authorize(
                        fn (BusinessCategory $record): bool => self::canView($record)
                    )
                    ->fillForm(
                        fn (BusinessCategory $record): array => [
                            'name_ar' => $record->name_ar,
                            'sort_order' => $record->sort_order,
                            'is_active' => $record->is_active,
                        ]
                    )
                    ->schema([
                        TextInput::make('name_ar')
                            ->label('اسم الفئة بالعربية')
                            ->required()
                            ->minLength(2)
                            ->maxLength(150),

                        TextInput::make('sort_order')
                            ->label('ترتيب العرض')
                            ->numeric()
                            ->minValue(0)
                            ->required(),

                        Toggle::make('is_active')
                            ->label('الفئة نشطة'),
                    ])
                    ->action(function (
                        BusinessCategory $record,
                        array $data
                    ): void {
                        $admin = Filament::auth()->user();
                        abort_unless($admin instanceof User, 403);

                        app(BusinessCategoryManagementService::class)
                            ->update($admin, $record, $data);

                        Notification::make()
                            ->title('تم تحديث الفئة')
                            ->success()
                            ->send();
                    }),

                Action::make('moveCategory')
                    ->label('نقل الفئة')
                    ->color('gray')
                    ->authorize(
                        fn (BusinessCategory $record): bool => self::canView($record)
                    )
                    ->modalHeading('نقل الفئة إلى موقع آخر')
                    ->modalDescription(
                        'لا يمكن نقل الفئات المرتبطة بأنشطة تجارية.'
                    )
                    ->fillForm(
                        fn (BusinessCategory $record): array => [
                            'parent_id' => $record->parent_id,
                        ]
                    )
                    ->schema([
                        Select::make('parent_id')
                            ->label('الفئة الرئيسية الجديدة')
                            ->placeholder('بدون فئة رئيسية')
                            ->options(
                                fn (): array => self::parentOptions()
                            )
                            ->searchable()
                            ->preload(),
                    ])
                    ->action(function (
                        BusinessCategory $record,
                        array $data
                    ): void {
                        $admin = Filament::auth()->user();
                        abort_unless($admin instanceof User, 403);

                        app(BusinessCategoryManagementService::class)
                            ->move(
                                $admin,
                                $record,
                                $data['parent_id'] ?? null
                            );

                        Notification::make()
                            ->title('تم نقل الفئة')
                            ->success()
                            ->send();
                    }),
            ])
            ->toolbarActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ManageBusinessCategories::route('/'),
        ];
    }
}
