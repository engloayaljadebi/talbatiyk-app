<?php

namespace App\Services\Product;

use App\Models\Business;
use App\Models\Product;
use App\Models\User;
use App\Services\Business\BusinessAccessService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use RuntimeException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Throwable;

class ProductMutationService
{
    public function __construct(
        private readonly BusinessAccessService $businessAccessService,
    ) {}

    public function update(
        User $user,
        string $businessId,
        string $productId,
        array $attributes,
    ): Product {
        $business = $this->resolveEligibleSupplier(
            $user,
            $businessId,
        );

        return DB::transaction(function () use (
            $business,
            $productId,
            $attributes,
        ): Product {
            $product = Product::query()
                ->whereKey($productId)
                ->where('supplier_id', $business->id)
                ->lockForUpdate()
                ->firstOrFail();

            /*
             * A lost-response retry is successful when the server already
             * contains the exact requested final state.
             */
            if ($this->metadataAlreadyMatches($product, $attributes)) {
                return $this->loadRelations($product);
            }

            $this->assertExpectedVersion(
                $product,
                (int) $attributes['expected_version'],
            );

            $product->name = trim(
                (string) $attributes['name'],
            );

            $product->description = $this->nullableTrimmed(
                $attributes['description'] ?? null,
            );

            $product->category = trim(
                (string) $attributes['category'],
            );

            $product->brand = trim(
                (string) ($attributes['brand'] ?? ''),
            );

            $product->price = $attributes['price'];
            $product->quantity = (int) $attributes['quantity'];
            $product->is_available = (bool) $attributes['is_available'];

            if (($attributes['remove_image'] ?? false) === true) {
                /*
                 * Only clear the current Product reference.
                 * Historical files remain because Order snapshots can still
                 * point to their immutable relative paths.
                 */
                $product->image_url = null;
            }

            $product->version = ((int) $product->version) + 1;
            $product->save();

            return $this->loadRelations($product);
        });
    }

    public function updateImage(
        User $user,
        string $businessId,
        string $productId,
        array $attributes,
    ): Product {
        $business = $this->resolveEligibleSupplier(
            $user,
            $businessId,
        );

        /** @var UploadedFile $image */
        $image = $attributes['image'];

        $hash = $this->imageContentHash($image);

        $extension = strtolower(
            trim(
                (string) $image->extension(),
            ),
        );

        if ($extension === '') {
            throw new RuntimeException(
                'Unable to determine product image extension.',
            );
        }

        $directory = "products/{$business->id}/products/{$productId}";
        $filename = "{$hash}.{$extension}";
        $path = "{$directory}/{$filename}";

        $disk = Storage::disk('public');

        $fileExistedBeforeAttempt = $disk->exists($path);
        $fileCreatedByAttempt = false;

        try {
            return DB::transaction(function () use (
                $business,
                $productId,
                $attributes,
                $image,
                $directory,
                $filename,
                $path,
                $disk,
                $fileExistedBeforeAttempt,
                &$fileCreatedByAttempt,
            ): Product {
                $product = Product::query()
                    ->whereKey($productId)
                    ->where('supplier_id', $business->id)
                    ->lockForUpdate()
                    ->firstOrFail();

                /*
                 * Same content path means the logical image mutation already
                 * succeeded. Restore missing bytes if necessary.
                 */
                if ($product->image_url === $path) {
                    if (! $disk->exists($path)) {
                        $storedPath = $image->storePubliclyAs(
                            $directory,
                            $filename,
                            'public',
                        );

                        if (
                            ! is_string($storedPath)
                            || $storedPath !== $path
                        ) {
                            throw new RuntimeException(
                                'Unable to restore product image.',
                            );
                        }

                        $fileCreatedByAttempt = ! $fileExistedBeforeAttempt;
                    }

                    return $this->loadRelations($product);
                }

                $this->assertExpectedVersion(
                    $product,
                    (int) $attributes['expected_version'],
                );

                if (! $disk->exists($path)) {
                    $storedPath = $image->storePubliclyAs(
                        $directory,
                        $filename,
                        'public',
                    );

                    if (
                        ! is_string($storedPath)
                        || $storedPath !== $path
                    ) {
                        throw new RuntimeException(
                            'Unable to store product image.',
                        );
                    }

                    $fileCreatedByAttempt = ! $fileExistedBeforeAttempt;
                }

                $product->image_url = $path;
                $product->version = ((int) $product->version) + 1;
                $product->save();

                return $this->loadRelations($product);
            });
        } catch (Throwable $exception) {
            if (
                $fileCreatedByAttempt
                && ! $fileExistedBeforeAttempt
                && $disk->exists($path)
            ) {
                $disk->delete($path);
            }

            throw $exception;
        }
    }

    public function delete(
        User $user,
        string $businessId,
        string $productId,
        int $expectedVersion,
    ): void {
        $business = $this->resolveEligibleSupplier(
            $user,
            $businessId,
        );

        DB::transaction(function () use (
            $business,
            $productId,
            $expectedVersion,
        ): void {
            $product = Product::query()
                ->withTrashed()
                ->whereKey($productId)
                ->where('supplier_id', $business->id)
                ->lockForUpdate()
                ->firstOrFail();

            /*
             * Ambiguous DELETE retry is idempotent.
             */
            if ($product->trashed()) {
                return;
            }

            $this->assertExpectedVersion(
                $product,
                $expectedVersion,
            );

            /*
             * Soft-delete only.
             * Historical image files intentionally remain available.
             */
            $product->delete();
        });
    }

    private function resolveEligibleSupplier(
        User $user,
        string $businessId,
    ): Business {
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        $business = Business::query()
            ->whereKey($businessId)
            ->where('status', 'active')
            ->firstOrFail();

        $hasSupplierCapability = $business
            ->capabilities()
            ->where(
                'business_capabilities.code',
                'supplier',
            )
            ->whereNull(
                'business_capabilities.retired_at',
            )
            ->wherePivotNull('disabled_at')
            ->exists();

        if (! $hasSupplierCapability) {
            throw new AuthorizationException(
                'This business is not enabled as a supplier.',
            );
        }

        return $business;
    }

    private function assertExpectedVersion(
        Product $product,
        int $expectedVersion,
    ): void {
        if ((int) $product->version !== $expectedVersion) {
            throw new ConflictHttpException(
                'Product changed since the client snapshot was loaded.',
            );
        }
    }

    private function metadataAlreadyMatches(
        Product $product,
        array $attributes,
    ): bool {
        $description = $this->nullableTrimmed(
            $attributes['description'] ?? null,
        );

        $removeImage = ($attributes['remove_image'] ?? false) === true;

        if (
            trim((string) $product->name)
                !== trim((string) $attributes['name'])
        ) {
            return false;
        }

        if (
            $this->nullableTrimmed($product->description)
                !== $description
        ) {
            return false;
        }

        if (
            trim((string) $product->category)
                !== trim((string) $attributes['category'])
        ) {
            return false;
        }

        if (
            trim((string) $product->brand)
                !== trim((string) ($attributes['brand'] ?? ''))
        ) {
            return false;
        }

        if (
            number_format((float) $product->price, 2, '.', '')
                !== number_format(
                    (float) $attributes['price'],
                    2,
                    '.',
                    '',
                )
        ) {
            return false;
        }

        if (
            (int) $product->quantity
                !== (int) $attributes['quantity']
        ) {
            return false;
        }

        if (
            (bool) $product->is_available
                !== (bool) $attributes['is_available']
        ) {
            return false;
        }

        if (
            $removeImage
            && $product->image_url !== null
            && trim((string) $product->image_url) !== ''
        ) {
            return false;
        }

        return true;
    }

    private function nullableTrimmed(
        mixed $value,
    ): ?string {
        if ($value === null) {
            return null;
        }

        $normalized = trim(
            (string) $value,
        );

        return $normalized === ''
            ? null
            : $normalized;
    }

    private function imageContentHash(
        UploadedFile $image,
    ): string {
        $realPath = $image->getRealPath();

        if (
            ! is_string($realPath)
            || $realPath === ''
        ) {
            throw new RuntimeException(
                'Unable to read product image.',
            );
        }

        $hash = hash_file(
            'sha256',
            $realPath,
        );

        if (
            ! is_string($hash)
            || $hash === ''
        ) {
            throw new RuntimeException(
                'Unable to hash product image.',
            );
        }

        return $hash;
    }

    private function loadRelations(
        Product $product,
    ): Product {
        return $product->loadMissing([
            'supplier:id,name',
            'supplier.locations',
        ]);
    }
}
