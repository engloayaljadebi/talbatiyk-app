<?php

namespace Tests\Unit\Http\Resources\Api\V1;

use App\Http\Resources\Api\V1\ProductResource;
use App\Models\Business;
use App\Models\BusinessLocation;
use App\Models\Product;
use Illuminate\Http\Request;
use Tests\TestCase;

class ProductResourceGovernorateTest extends TestCase
{
    public function test_product_resource_exposes_primary_supplier_governorate(): void
    {
        $supplier = new Business;
        $supplier->id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
        $supplier->name = 'مورد صنعاء';

        $secondaryLocation = new BusinessLocation;
        $secondaryLocation->administrative_area = 'عدن';
        $secondaryLocation->is_primary = false;

        $primaryLocation = new BusinessLocation;
        $primaryLocation->administrative_area = 'صنعاء';
        $primaryLocation->is_primary = true;

        $supplier->setRelation(
            'locations',
            collect([
                $secondaryLocation,
                $primaryLocation,
            ]),
        );

        $product = new Product;
        $product->id = '11111111-1111-4111-8111-111111111111';
        $product->supplier_id = $supplier->id;
        $product->name = 'منتج تجريبي';
        $product->description = null;
        $product->category = 'إلكترونيات';
        $product->brand = 'اختبار';
        $product->price = 150;
        $product->quantity = 10;
        $product->is_available = true;
        $product->image_url = null;
        $product->colors = [];
        $product->discount = 0;
        $product->rating = 0;

        $product->setRelation('supplier', $supplier);

        $payload = (new ProductResource($product))->toArray(
            Request::create('/api/v1/products', 'GET'),
        );

        $this->assertSame(
            'صنعاء',
            $payload['supplier_governorate'] ?? null,
        );
    }
}
