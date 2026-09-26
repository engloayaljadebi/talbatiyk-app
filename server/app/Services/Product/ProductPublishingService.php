<?php

namespace App\Services\Product;

use App\Models\Business;
use App\Models\Product;
use App\Models\User;
use App\Services\Business\BusinessAccessService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use RuntimeException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Throwable;

class ProductPublishingService
{
    public function __construct(
        private readonly BusinessAccessService $businessAccessService,
    ) {}

    public function publish(
        User $user,
        string $businessId,
        array $attributes,
        string $idempotencyKey,
    ): Product {
        /*
         * Authorization remains server-side.
         */
        $this->businessAccessService->ensureCanUpdate(
            $user,
            $businessId,
        );

        /*
         * Resolve the supplier identity first.
         *
         * withTrashed Product replay below ensures an old successful
         * idempotency key can never create another Product later.
         */
        /*
         * Current commercial eligibility is required for BOTH:
         *
         * - a new logical publication;
         * - an idempotent replay of an older publication.
         *
         * A historical key must not bypass a business closure or a
         * disabled/retired supplier capability.
         */
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
                'هذا النشاط غير مفعّل كمورد.',
            );
        }

        $image = $attributes['image'] ?? null;

        $imageHash = $image instanceof UploadedFile
            ? $this->imageContentHash($image)
            : null;

        $payloadHash = $this->payloadHash(
            $attributes,
            $imageHash,
        );

        /*
         * Fast replay is deliberately AFTER the current authorization
         * and supplier-eligibility gates.
         */
        $existingProduct = Product::query()
            ->withTrashed()
            ->where(
                'supplier_id',
                $business->id,
            )
            ->where(
                'idempotency_key',
                $idempotencyKey,
            )
            ->first();

        if ($existingProduct !== null) {
            return $this->resolveIdempotentProduct(
                $existingProduct,
                $payloadHash,
            );
        }

        $name = trim(
            (string) $attributes['name'],
        );

        $description = isset(
            $attributes['description'],
        )
            ? trim(
                (string) $attributes['description'],
            )
            : null;

        $category = trim(
            (string) $attributes['category'],
        );

        $brand = trim(
            (string) (
                $attributes['brand'] ?? ''
            ),
        );

        /*
         * We calculate the final deterministic location before creation,
         * but we DO NOT write the file yet.
         */
        $imageDirectory = null;
        $imageFilename = null;
        $imagePath = null;
        $imageUrl = null;

        if ($image instanceof UploadedFile) {
            if ($imageHash === null) {
                throw new RuntimeException(
                    'تعذر حساب بصمة صورة المنتج.',
                );
            }

            $extension = strtolower(
                trim(
                    (string) $image->extension(),
                ),
            );

            if ($extension === '') {
                throw new RuntimeException(
                    'تعذر تحديد امتداد صورة المنتج.',
                );
            }

            $imageDirectory =
                "products/{$business->id}/idempotency/{$idempotencyKey}";

            $imageFilename =
                "{$imageHash}.{$extension}";

            $imagePath =
                "{$imageDirectory}/{$imageFilename}";

            $imageUrl = Storage::disk(
                'public',
            )->url(
                $imagePath,
            );
        }

        /*
         * PostgreSQL UNIQUE(supplier_id, idempotency_key) is the final
         * duplicate-prevention authority.
         *
         * Laravel firstOrCreate/createOrFirst resolves the concurrent
         * unique-key race back to the winning row.
         */
        $imageWriteAttempted = false;

        try {
            $product = DB::transaction(
                function () use (
                    $business,
                    $idempotencyKey,
                    $payloadHash,
                    $name,
                    $description,
                    $category,
                    $brand,
                    $attributes,
                    $image,
                    $imageDirectory,
                    $imageFilename,
                    $imagePath,
                    $imageUrl,
                    &$imageWriteAttempted,
                ): Product {
                    $product = Product::query()
                        ->withTrashed()
                        ->firstOrCreate(
                            [
                                'supplier_id' => $business->id,
                                'idempotency_key' => $idempotencyKey,
                            ],
                            [
                                'idempotency_payload_hash' => $payloadHash,

                                'name' => $name,
                                'description' => $description,
                                'category' => $category,
                                'brand' => $brand,

                                'price' => $attributes['price'],

                                'quantity' => (int) $attributes[
                                    'quantity'
                                ],

                                'is_available' => (bool) $attributes[
                                    'is_available'
                                ],

                                'image_url' => $imageUrl,

                                'colors' => [],
                                'discount' => 0,
                                'rating' => 0,
                            ],
                        );

                    /*
                     * A concurrent request already won.
                     *
                     * Do NOT store the image from this request.
                     */
                    if (! $product->wasRecentlyCreated) {
                        return $this->resolveIdempotentProduct(
                            $product,
                            $payloadHash,
                        );
                    }

                    /*
                     * Only the request that created the Product row may write
                     * the image.
                     *
                     * If storage fails, this transaction is rolled back.
                     */
                    if ($image instanceof UploadedFile) {
                        if (
                            $imageDirectory === null
                            || $imageFilename === null
                            || $imagePath === null
                        ) {
                            throw new RuntimeException(
                                'بيانات مسار صورة المنتج غير مكتملة.',
                            );
                        }

                        $imageWriteAttempted = true;

                        try {
                            $storedPath = $image->storePubliclyAs(
                                $imageDirectory,
                                $imageFilename,
                                'public',
                            );
                        } catch (Throwable $exception) {
                            throw new RuntimeException(
                                'تعذر حفظ صورة المنتج.',
                                previous: $exception,
                            );
                        }

                        if (
                            ! is_string($storedPath)
                            || $storedPath === ''
                            || $storedPath !== $imagePath
                        ) {
                            throw new RuntimeException(
                                'تعذر حفظ صورة المنتج في المسار المتوقع.',
                            );
                        }
                    }

                    return $product;
                },
            );
        } catch (Throwable $exception) {
            /*
             * Filesystem writes do not participate in the database
             * transaction.
             *
             * If the image was physically written and the DB
             * transaction later failed, compensate by removing it.
             *
             * Before deletion, check whether another concurrent
             * request committed the same supplier/key. In that case,
             * the deterministic image path belongs to the winner and
             * must be preserved.
             *
             * Cleanup failure must never replace the original publish
             * exception.
             */
            if (
                $imageWriteAttempted
                && $imagePath !== null
            ) {
                try {
                    $committedWinnerExists = Product::query()
                        ->withTrashed()
                        ->where(
                            'supplier_id',
                            $business->id,
                        )
                        ->where(
                            'idempotency_key',
                            $idempotencyKey,
                        )
                        ->exists();

                    if (! $committedWinnerExists) {
                        $disk = Storage::disk('public');

                        if (
                            $disk->exists($imagePath)
                            && ! $disk->delete($imagePath)
                        ) {
                            Log::warning(
                                'Product publish image cleanup returned false.',
                                [
                                    'supplier_id' => $business->id,
                                    'idempotency_key' => $idempotencyKey,
                                    'image_path' => $imagePath,
                                    'original_exception' => $exception::class,
                                ],
                            );
                        }
                    }
                } catch (Throwable $cleanupException) {
                    Log::error(
                        'Product publish image cleanup failed.',
                        [
                            'supplier_id' => $business->id,
                            'idempotency_key' => $idempotencyKey,
                            'image_path' => $imagePath,
                            'original_exception' => $exception::class,
                            'cleanup_exception' => $cleanupException::class,
                            'cleanup_message' => $cleanupException->getMessage(),
                        ],
                    );
                }
            }

            throw $exception;
        }

        return $product->loadMissing([
            'supplier:id,name',
            'supplier.locations',
        ]);
    }

    private function resolveIdempotentProduct(
        Product $product,
        string $payloadHash,
    ): Product {
        $storedHash = $product->idempotency_payload_hash;

        if (
            ! is_string($storedHash)
            || ! hash_equals(
                $storedHash,
                $payloadHash,
            )
        ) {
            throw new ConflictHttpException(
                'The Idempotency-Key was already used for a different product payload.',
            );
        }

        if ($product->trashed()) {
            throw new ConflictHttpException(
                'The Idempotency-Key belongs to a deleted product.',
            );
        }

        return $product->loadMissing([
            'supplier:id,name',
            'supplier.locations',
        ]);
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
                'تعذر قراءة صورة المنتج.',
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
                'تعذر حساب بصمة صورة المنتج.',
            );
        }

        return $hash;
    }

    private function payloadHash(
        array $attributes,
        ?string $imageHash,
    ): string {
        /*
         * Fingerprint logical values, not raw multipart encoding.
         */
        $payload = [
            'name' => trim(
                (string) $attributes['name'],
            ),

            'description' => isset(
                $attributes['description'],
            )
                ? trim(
                    (string) $attributes['description'],
                )
                : null,

            'category' => trim(
                (string) $attributes['category'],
            ),

            'brand' => trim(
                (string) (
                    $attributes['brand'] ?? ''
                ),
            ),

            /*
             * Follow the same minor-unit strategy already used by Orders.
             */
            'price_minor_units' => $this->moneyInMinorUnits(
                $attributes['price'],
            ),

            'quantity' => (int) $attributes[
                'quantity'
            ],

            'is_available' => (bool) $attributes[
                'is_available'
            ],

            'image_sha256' => $imageHash,
        ];

        return hash(
            'sha256',
            json_encode(
                $payload,
                JSON_THROW_ON_ERROR
                | JSON_PRESERVE_ZERO_FRACTION,
            ),
        );
    }

    private function moneyInMinorUnits(
        mixed $value,
    ): int {
        return (int) round(
            ((float) $value) * 100,
        );
    }
}
