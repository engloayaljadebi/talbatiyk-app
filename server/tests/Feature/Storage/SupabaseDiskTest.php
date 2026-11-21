<?php

namespace Tests\Feature\Storage;

use Aws\MockHandler;
use Aws\Result;
use Illuminate\Support\Facades\Storage;
use League\Flysystem\Visibility;
use Tests\TestCase;

final class SupabaseDiskTest extends TestCase
{
    public function test_public_upload_uses_bucket_visibility_and_public_asset_url(): void
    {
        $requests = new MockHandler([new Result]);
        config()->set('filesystems.disks.supabase-test', [
            'driver' => 'supabase-s3',
            'key' => 'local-test-key',
            'secret' => 'local-test-secret',
            'region' => 'us-east-1',
            'endpoint' => 'https://reference.storage.supabase.co/storage/v1/s3',
            'bucket' => 'product-images',
            'url' => 'https://reference.supabase.co/storage/v1/object/public/product-images',
            'use_path_style_endpoint' => true,
            'request_checksum_calculation' => 'when_required',
            'response_checksum_validation' => 'when_required',
            'handler' => $requests,
            'throw' => true,
        ]);

        $disk = Storage::disk('supabase-test');
        $this->assertTrue($disk->put('products/test.jpg', 'image bytes', Visibility::PUBLIC));
        $request = $requests->getLastRequest();

        $this->assertSame('PutObject', $requests->getLastCommand()->getName());
        $this->assertFalse($request->hasHeader('x-amz-acl'));
        $this->assertSame('/storage/v1/s3/product-images/products/test.jpg', $request->getUri()->getPath());
        $this->assertSame(
            'https://reference.supabase.co/storage/v1/object/public/product-images/products/test.jpg',
            $disk->url('products/test.jpg'),
        );
    }
}
