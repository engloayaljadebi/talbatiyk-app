<?php

namespace App\Support;

use Illuminate\Support\Facades\Storage;

final class PublicDiskUrl
{
    public static function resolve(
        ?string $storedValue,
    ): ?string {
        $value = trim(
            (string) ($storedValue ?? ''),
        );

        if ($value === '') {
            return null;
        }

        /*
         * Historical absolute URLs remain valid as-is.
         *
         * New application-owned files are persisted as stable
         * public-disk relative paths and resolved at API time.
         */
        if (
            str_starts_with($value, 'http://')
            || str_starts_with($value, 'https://')
        ) {
            return $value;
        }

        $publicDiskPath = ltrim(
            $value,
            '/',
        );

        /*
         * Tolerate historical relative values such as:
         *
         * storage/products/example.jpg
         *
         * without producing:
         *
         * /storage/storage/products/example.jpg
         */
        if (str_starts_with($publicDiskPath, 'storage/')) {
            $publicDiskPath = substr(
                $publicDiskPath,
                strlen('storage/'),
            );
        }

        return Storage::disk('public')->url(
            $publicDiskPath,
        );
    }
}
