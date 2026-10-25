<?php

declare(strict_types=1);

namespace App\Filament\Resources\Verifications\Pages;

use App\Filament\Resources\Verifications\VerificationResource;
use Filament\Resources\Pages\ManageRecords;

final class ManageVerifications extends ManageRecords
{
    protected static string $resource = VerificationResource::class;

    protected function getHeaderActions(): array
    {
        // Creation is centralized in Users > Create User.
        // Keep this page dedicated to reviewing existing verification requests.
        return [];
    }
}
