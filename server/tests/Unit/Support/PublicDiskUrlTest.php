<?php

namespace Tests\Unit\Support;

use App\Support\PublicDiskUrl;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class PublicDiskUrlTest extends TestCase
{
    public function test_null_and_blank_values_resolve_to_null(): void
    {
        Storage::fake('public');

        $this->assertNull(
            PublicDiskUrl::resolve(null),
        );

        $this->assertNull(
            PublicDiskUrl::resolve(''),
        );

        $this->assertNull(
            PublicDiskUrl::resolve('   '),
        );
    }

    public function test_relative_public_disk_path_is_resolved(): void
    {
        Storage::fake('public');

        $path = 'products/example.jpg';

        $this->assertSame(
            Storage::disk('public')->url($path),
            PublicDiskUrl::resolve($path),
        );
    }

    public function test_storage_prefixed_relative_path_does_not_duplicate_storage_segment(): void
    {
        Storage::fake('public');

        $this->assertSame(
            Storage::disk('public')->url(
                'products/example.jpg',
            ),
            PublicDiskUrl::resolve(
                'storage/products/example.jpg',
            ),
        );
    }

    public function test_leading_slash_is_normalized(): void
    {
        Storage::fake('public');

        $this->assertSame(
            Storage::disk('public')->url(
                'products/example.jpg',
            ),
            PublicDiskUrl::resolve(
                '/products/example.jpg',
            ),
        );
    }

    public function test_legacy_absolute_http_url_is_preserved(): void
    {
        Storage::fake('public');

        $url =
            'http://legacy.example.test/storage/products/example.jpg';

        $this->assertSame(
            $url,
            PublicDiskUrl::resolve($url),
        );
    }

    public function test_legacy_absolute_https_url_is_preserved(): void
    {
        Storage::fake('public');

        $url =
            'https://cdn.example.test/products/example.jpg';

        $this->assertSame(
            $url,
            PublicDiskUrl::resolve($url),
        );
    }
}
