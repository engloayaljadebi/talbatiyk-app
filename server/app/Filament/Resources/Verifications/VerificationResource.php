<?php

declare(strict_types=1);

namespace App\Filament\Resources\Verifications;

use App\Filament\Resources\Verifications\Pages\ManageVerifications;
use App\Models\User;
use App\Models\Verification;
use App\Services\Business\SupplierApprovalReviewService;
use Filament\Actions\Action;
use Filament\Actions\ViewAction;
use Filament\Facades\Filament;
use Filament\Forms\Components\Textarea;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;

final class VerificationResource extends Resource
{
    protected static ?string $model = Verification::class;

    protected static ?string $navigationLabel = 'طلبات اعتماد الأنشطة التجارية';

    protected static ?string $modelLabel = 'طلب اعتماد نشاط';

    protected static ?string $pluralModelLabel = 'طلبات اعتماد الأنشطة';

    public static function canViewAny(): bool
    {
        $user = Filament::auth()->user();

        return $user !== null
            && Gate::forUser($user)->allows('reviewSupplierApprovals');
    }

    public static function canView(Model $record): bool
    {
        return static::canViewAny()
            && $record instanceof Verification
            && in_array(
                $record->verification_type_code,
                ['supplier_approval', 'shop_approval'],
                true,
            );
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
        abort_unless(static::canViewAny(), 403);

        return parent::getEloquentQuery()
            ->whereIn('verification_type_code', ['supplier_approval', 'shop_approval'])
            ->with([
                'business.contacts',
                'business.locations',
                'requestedBy',
                'reviewedBy',
            ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->components([
            TextEntry::make('verification_type_code')
                ->label('نوع الاعتماد')
                ->formatStateUsing(fn (string $state): string => static::typeLabel($state)),
            TextEntry::make('business.name')->label('النشاط'),
            TextEntry::make('business.legal_name')->label('الاسم القانوني'),
            TextEntry::make('business.description')->label('الوصف'),
            TextEntry::make('requestedBy.display_name')->label('مقدم الطلب'),
            TextEntry::make('requestedBy.username')->label('اسم المستخدم'),
            TextEntry::make('status')
                ->label('الحالة')
                ->formatStateUsing(fn (string $state): string => static::statusLabel($state)),
            TextEntry::make('requested_at')->label('تاريخ التقديم')->dateTime(),
            RepeatableEntry::make('business.contacts')
                ->label('وسائل اتصال النشاط')
                ->schema([
                    TextEntry::make('type')->label('النوع'),
                    TextEntry::make('value')->label('القيمة'),
                    TextEntry::make('label')->label('الوصف'),
                ]),
            RepeatableEntry::make('business.locations')
                ->label('مواقع النشاط')
                ->schema([
                    TextEntry::make('name')->label('الموقع'),
                    TextEntry::make('country_code')->label('الدولة'),
                    TextEntry::make('administrative_area')->label('المحافظة'),
                    TextEntry::make('locality')->label('المدينة'),
                    TextEntry::make('district')->label('الحي'),
                    TextEntry::make('street_address')->label('العنوان'),
                ]),
            TextEntry::make('reviewedBy.display_name')->label('المراجع'),
            TextEntry::make('reviewed_at')->label('وقت المراجعة')->dateTime(),
            TextEntry::make('review_note')->label('ملاحظة القرار'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('requested_at', 'desc')
            ->columns([
                TextColumn::make('verification_type_code')
                    ->label('نوع الاعتماد')
                    ->formatStateUsing(fn (string $state): string => static::typeLabel($state)),
                TextColumn::make('business.name')
                    ->label('النشاط')
                    ->searchable(),
                TextColumn::make('requestedBy.display_name')
                    ->label('مقدم الطلب')
                    ->searchable(),
                TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => static::statusLabel($state))
                    ->color(fn (string $state): string => match ($state) {
                        'approved' => 'success',
                        'rejected' => 'danger',
                        'pending' => 'warning',
                        default => 'gray',
                    }),
                TextColumn::make('requested_at')
                    ->label('تاريخ التقديم')
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('reviewedBy.display_name')->label('المراجع'),
                TextColumn::make('reviewed_at')->label('وقت القرار')->dateTime(),
            ])
            ->filters([
                SelectFilter::make('status')->label('الحالة')->options([
                    'pending' => 'قيد المراجعة',
                    'approved' => 'مقبول',
                    'rejected' => 'مرفوض',
                    'revoked' => 'ملغى',
                    'expired' => 'منتهي',
                ]),
            ])
            ->recordActions([
                ViewAction::make()->label('التفاصيل'),
                static::decisionAction('approve', 'موافقة', 'success'),
                static::decisionAction('reject', 'رفض', 'danger'),
            ])
            ->toolbarActions([]);
    }

    private static function decisionAction(
        string $name,
        string $label,
        string $color,
    ): Action {
        return Action::make($name)
            ->label($label)
            ->color($color)
            ->requiresConfirmation()
            ->authorize(fn (): bool => static::canViewAny())
            ->visible(fn (Verification $record): bool => $record->status === 'pending')
            ->schema([
                Textarea::make('review_note')
                    ->label($name === 'reject' ? 'سبب الرفض' : 'ملاحظة الموافقة')
                    ->required($name === 'reject')
                    ->maxLength(2000),
            ])
            ->action(function (Verification $record, array $data) use ($name): void {
                abort_unless(static::canView($record), 403);

                $reviewer = Filament::auth()->user();
                abort_unless($reviewer instanceof User, 403);

                $service = app(SupplierApprovalReviewService::class);
                $note = (string) ($data['review_note'] ?? '');

                try {
                    if ($name === 'approve') {
                        $service->approve($record->id, $reviewer, $note);
                    } else {
                        $service->reject($record->id, $reviewer, $note);
                    }
                } catch (ConflictHttpException) {
                    throw ValidationException::withMessages([
                        'review_note' => 'تعذر تنفيذ القرار لأن حالة الطلب أو النشاط تغيرت. أغلق النافذة وحدّث القائمة.',
                    ]);
                }

                $target = $record->verification_type_code === 'shop_approval'
                    ? 'المتجر'
                    : 'المورد';

                Notification::make()
                    ->title($name === 'approve' ? 'تم اعتماد '.$target : 'تم رفض طلب '.$target)
                    ->success()
                    ->send();
            });
    }

    private static function typeLabel(string $state): string
    {
        return match ($state) {
            'shop_approval' => 'اعتماد متجر / عميل',
            'supplier_approval' => 'اعتماد مورد',
            default => $state,
        };
    }

    private static function statusLabel(string $state): string
    {
        return match ($state) {
            'pending' => 'قيد المراجعة',
            'approved' => 'مقبول',
            'rejected' => 'مرفوض',
            'revoked' => 'ملغى',
            'expired' => 'منتهي',
            default => $state,
        };
    }

    public static function getPages(): array
    {
        return [
            'index' => ManageVerifications::route('/'),
        ];
    }
}