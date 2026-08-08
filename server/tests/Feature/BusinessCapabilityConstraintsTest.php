<?php

/*
|--------------------------------------------------------------------------
| اختبارات قدرات النشاط التجاري
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التأكد من إمكانية جعل النشاط موردًا.
| - التأكد من إمكانية جعل النشاط متجرًا.
| - السماح للنشاط بأن يكون موردًا ومتجرًا معًا.
| - منع تكرار نفس القدرة للنشاط نفسه.
| - السماح لنفس القدرة بالارتباط بعدة أنشطة مختلفة.
|
*/

namespace Tests\Feature;

use App\Models\Business;
use App\Models\BusinessCapability;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BusinessCapabilityConstraintsTest extends TestCase
{
    use RefreshDatabase;

    /**
     * يمكن للنشاط امتلاك قدرة المورد.
     */
    public function test_business_can_be_supplier(): void
    {
        $business = Business::create([
            'name' => 'مورد اختبار',
        ]);

        $supplier = BusinessCapability::create([
            'code' => 'supplier',
        ]);

        $business->capabilities()->attach(
            $supplier->code,
            ['enabled_at' => now()],
        );

        $this->assertTrue(
            $business->capabilities()
                ->where('code', 'supplier')
                ->exists(),
        );
    }

    /**
     * يمكن للنشاط أن يكون موردًا ومتجرًا معًا.
     */
    public function test_business_can_be_supplier_and_shop(): void
    {
        $business = Business::create([
            'name' => 'نشاط متعدد القدرات',
        ]);

        $supplier = BusinessCapability::create([
            'code' => 'supplier',
        ]);

        $shop = BusinessCapability::create([
            'code' => 'shop',
        ]);

        $business->capabilities()->attach(
            $supplier->code,
            ['enabled_at' => now()],
        );

        $business->capabilities()->attach(
            $shop->code,
            ['enabled_at' => now()],
        );

        $this->assertSame(
            2,
            $business->capabilities()->count(),
        );
    }

    /**
     * لا يسمح بتكرار نفس القدرة للنشاط نفسه.
     */
    public function test_same_capability_cannot_be_assigned_twice(): void
    {
        $business = Business::create([
            'name' => 'نشاط اختبار التكرار',
        ]);

        $supplier = BusinessCapability::create([
            'code' => 'supplier',
        ]);

        $business->capabilities()->attach(
            $supplier->code,
            ['enabled_at' => now()],
        );

        $this->expectException(QueryException::class);

        $business->capabilities()->attach(
            $supplier->code,
            ['enabled_at' => now()],
        );
    }

    /**
     * يمكن لنفس القدرة الارتباط بأكثر من نشاط.
     */
    public function test_capability_can_belong_to_multiple_businesses(): void
    {
        $supplier = BusinessCapability::create([
            'code' => 'supplier',
        ]);

        $firstBusiness = Business::create([
            'name' => 'المورد الأول',
        ]);

        $secondBusiness = Business::create([
            'name' => 'المورد الثاني',
        ]);

        $firstBusiness->capabilities()->attach(
            $supplier->code,
            ['enabled_at' => now()],
        );

        $secondBusiness->capabilities()->attach(
            $supplier->code,
            ['enabled_at' => now()],
        );

        $this->assertSame(
            2,
            $supplier->businesses()->count(),
        );
    }
}
