<?php

/*
|--------------------------------------------------------------------------
| اختبارات دوام مواقع الأنشطة
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التأكد من ربط الدوام بالموقع.
| - السماح بأكثر من فترة في اليوم نفسه.
| - دعم الدوام بعد منتصف الليل.
| - منع الفترات الزمنية غير الصحيحة.
| - منع الأيام خارج النطاق 1 إلى 7.
| - منع تكرار الفترة نفسها حرفيًا.
|
*/

namespace Tests\Feature;

use App\Models\Business;
use App\Models\BusinessLocation;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BusinessHourConstraintsTest extends TestCase
{
    use RefreshDatabase;

    /**
     * إنشاء موقع جاهز لاختبارات الدوام.
     */
    private function createLocation(): BusinessLocation
    {
        $business = Business::create([
            'name' => 'نشاط اختبار الدوام',
        ]);

        return $business->locations()->create([
            'name' => 'الفرع الرئيسي',
            'type' => 'branch',
            'timezone' => 'Asia/Aden',
            'country_code' => 'YE',
        ]);
    }

    /**
     * يمكن إنشاء فترة دوام مرتبطة بالموقع.
     */
    public function test_location_can_have_business_hours(): void
    {
        $location = $this->createLocation();

        $hour = $location->hours()->create([
            'day_of_week' => 6,
            'opens_at' => '08:00:00',
            'closes_at' => '12:00:00',
            'end_day_offset' => 0,
        ]);

        $this->assertTrue($hour->location->is($location));

        $this->assertTrue(
            $location->hours()->whereKey($hour->id)->exists(),
        );
    }

    /**
     * يمكن لليوم نفسه امتلاك أكثر من فترة.
     *
     * مثال:
     * 08:00 - 12:00
     * 16:00 - 22:00
     */
    public function test_day_can_have_multiple_intervals(): void
    {
        $location = $this->createLocation();

        $location->hours()->create([
            'day_of_week' => 6,
            'opens_at' => '08:00:00',
            'closes_at' => '12:00:00',
            'end_day_offset' => 0,
        ]);

        $location->hours()->create([
            'day_of_week' => 6,
            'opens_at' => '16:00:00',
            'closes_at' => '22:00:00',
            'end_day_offset' => 0,
        ]);

        $this->assertSame(
            2,
            $location->hours()
                ->where('day_of_week', 6)
                ->count(),
        );
    }

    /**
     * يدعم الدوام الممتد بعد منتصف الليل.
     *
     * مثال:
     * 20:00 مساءً حتى 02:00 صباح اليوم التالي.
     */
    public function test_overnight_interval_is_allowed(): void
    {
        $location = $this->createLocation();

        $hour = $location->hours()->create([
            'day_of_week' => 6,
            'opens_at' => '20:00:00',
            'closes_at' => '02:00:00',
            'end_day_offset' => 1,
        ]);

        $this->assertSame(1, $hour->end_day_offset);
    }

    /**
     * في اليوم نفسه لا يمكن أن تكون النهاية قبل البداية.
     */
    public function test_invalid_same_day_interval_is_rejected(): void
    {
        $location = $this->createLocation();

        $this->expectException(QueryException::class);

        $location->hours()->create([
            'day_of_week' => 6,
            'opens_at' => '20:00:00',
            'closes_at' => '02:00:00',
            'end_day_offset' => 0,
        ]);
    }

    /**
     * رقم اليوم يجب أن يكون من 1 إلى 7.
     */
    public function test_invalid_day_of_week_is_rejected(): void
    {
        $location = $this->createLocation();

        $this->expectException(QueryException::class);

        $location->hours()->create([
            'day_of_week' => 8,
            'opens_at' => '08:00:00',
            'closes_at' => '12:00:00',
            'end_day_offset' => 0,
        ]);
    }

    /**
     * لا يسمح بتكرار الفترة نفسها حرفيًا للموقع واليوم.
     */
    public function test_exact_duplicate_interval_is_rejected(): void
    {
        $location = $this->createLocation();

        $data = [
            'day_of_week' => 6,
            'opens_at' => '08:00:00',
            'closes_at' => '12:00:00',
            'end_day_offset' => 0,
        ];

        $location->hours()->create($data);

        $this->expectException(QueryException::class);

        $location->hours()->create($data);
    }
}
