<?php

declare(strict_types=1);

namespace App\Services\User;

use App\Models\Business;
use App\Models\User;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;
use RuntimeException;
use Throwable;

final class PrivateUserAssetStorage
{
    private const DISK = 'talbatiyk_private';

    private const STAGING_PREFIX = 'staging/admin-user-creation/';

    /** @param array<string, mixed> $input
     * @return list<string>
     */
    public function store(User $user, Business $business, array $input): array
    {
        $disk = Storage::disk(self::DISK);
        $stored = [];

        try {
            $this->storeImage($disk, $input['profile_photo'] ?? null, "users/{$user->id}/profile-photo", false, 'profile_photo', $stored);
            $this->storeImage($disk, $input['identity_document_front'] ?? null, "users/{$user->id}/identity-front", true, 'identity_document_front', $stored);
            $this->storeImage($disk, $input['identity_document_back'] ?? null, "users/{$user->id}/identity-back", true, 'identity_document_back', $stored);
            $this->storeImage($disk, $input['business_logo'] ?? null, "businesses/{$business->id}/logo", false, 'business_logo', $stored);

            $documentType = $input['identity_document_type'] ?? null;
            $documentNumber = $input['identity_document_number'] ?? null;

            if ($documentType !== null && $documentNumber !== null) {
                $metadataPath = "users/{$user->id}/identity-document.enc";
                $disk->makeDirectory(dirname($metadataPath));

                $metadata = json_encode([
                    'type' => $documentType,
                    'number' => $documentNumber,
                ], JSON_THROW_ON_ERROR);

                if (! $disk->put($metadataPath, Crypt::encryptString($metadata))) {
                    throw new RuntimeException('Unable to save encrypted identity metadata.');
                }

                $stored[] = $metadataPath;
            }

            $this->cleanupStaging($input);

            return $stored;
        } catch (Throwable $exception) {
            $this->cleanup($stored);
            $this->cleanupStaging($input);
            throw $exception;
        }
    }

    /** @param list<string> $paths */
    public function cleanup(array $paths): void
    {
        $disk = Storage::disk(self::DISK);

        foreach ($paths as $path) {
            if (
                is_string($path)
                && (str_starts_with($path, 'users/') || str_starts_with($path, 'businesses/'))
            ) {
                $disk->delete($path);
            }
        }
    }

    /** @param array<string, mixed> $input */
    public function cleanupStaging(array $input): void
    {
        $disk = Storage::disk(self::DISK);

        foreach ([
            'profile_photo',
            'identity_document_front',
            'identity_document_back',
            'business_logo',
        ] as $field) {
            $path = $input[$field] ?? null;

            if (! is_string($path)) {
                continue;
            }

            $path = str_replace('\\', '/', ltrim($path, '/'));

            if (str_starts_with($path, self::STAGING_PREFIX)) {
                $disk->delete($path);
            }
        }
    }

    public function profilePhotoPath(User $user): ?string
    {
        return $this->findImagePath("users/{$user->id}", 'profile-photo');
    }

    public function businessLogoPath(Business $business): ?string
    {
        return $this->findImagePath("businesses/{$business->id}", 'logo');
    }

    /** @return array{type:string, number:string}|null */
    public function readIdentityDocument(User $user): ?array
    {
        $disk = Storage::disk(self::DISK);
        $path = "users/{$user->id}/identity-document.enc";

        if (! $disk->exists($path)) {
            return null;
        }

        return json_decode(
            Crypt::decryptString($disk->get($path)),
            true,
            512,
            JSON_THROW_ON_ERROR,
        );
    }

    public function readIdentityDocumentImage(User $user, string $side): ?string
    {
        if (! in_array($side, ['front', 'back'], true)) {
            throw new \InvalidArgumentException('Identity document side must be front or back.');
        }

        $disk = Storage::disk(self::DISK);
        $path = "users/{$user->id}/identity-{$side}.enc";

        if (! $disk->exists($path)) {
            return null;
        }

        return Crypt::decryptString($disk->get($path));
    }

    private function storeImage(
        $disk,
        mixed $source,
        string $targetBase,
        bool $encrypt,
        string $field,
        array &$stored,
    ): void {
        if ($source === null || $source === '') {
            return;
        }

        if (! is_string($source)) {
            throw ValidationException::withMessages([
                $field => 'ملف الرفع غير صالح.',
            ]);
        }

        $source = str_replace('\\', '/', ltrim($source, '/'));

        if (! str_starts_with($source, self::STAGING_PREFIX) || ! $disk->exists($source)) {
            throw ValidationException::withMessages([
                $field => 'تعذر العثور على الملف المرفوع في التخزين الخاص.',
            ]);
        }

        $mimeType = $disk->mimeType($source);
        $extensions = [
            'image/jpeg' => 'jpg',
            'image/png' => 'png',
            'image/webp' => 'webp',
        ];

        if (! is_string($mimeType) || ! isset($extensions[$mimeType])) {
            throw ValidationException::withMessages([
                $field => 'نوع الملف غير مدعوم. استخدم صورة JPG أو PNG أو WebP.',
            ]);
        }

        $extension = $extensions[$mimeType];
        $target = $encrypt ? $targetBase.'.enc' : $targetBase.'.'.$extension;
        $disk->makeDirectory(dirname($target));

        if ($encrypt) {
            $contents = $disk->get($source);
            if (! $disk->put($target, Crypt::encryptString($contents))) {
                throw new RuntimeException("Unable to encrypt and save upload for {$field}.");
            }
            $disk->delete($source);
        } else {
            if (! $disk->move($source, $target)) {
                throw new RuntimeException("Unable to move upload for {$field}.");
            }
        }

        $stored[] = $target;
    }

    private function findImagePath(string $directory, string $prefix): ?string
    {
        $disk = Storage::disk(self::DISK);

        foreach ($disk->files($directory) as $path) {
            if (str_starts_with(basename($path), $prefix.'.')) {
                return $path;
            }
        }

        return null;
    }
}
