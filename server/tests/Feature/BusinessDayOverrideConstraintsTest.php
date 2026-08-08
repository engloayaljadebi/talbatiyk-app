<?php

/*
|--------------------------------------------------------------------------
| اختبارات استثناءات دوام المواقع
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - دعم الإغلاق الكامل لتاريخ معين.
| - دعم ساعات عمل مخصصة لتاريخ معين.
| - منع إضافة فترة عمل إلى يوم مغلق.
| - منع تحويل يوم يحتوي فترات إلى closed.
| - منع تكرار الاستثناء لنفس الموقع والتاريخ.
| - اختبار الدوام الاستثنائي الممتد بعد منتصف الليل.
|
*/

namespace Tests\Feature;

use App\Models\Business;
use App\Models\BusinessDayOverride;
use App\Models\BusinessLocation;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BusinessDayOverrideConstraintsTest extends TestCase
{
    use RefreshDatabase;

    /**
     * إنشاء موقع جاهز للاختبارات.
     */
    private function createLocation(): BusinessLocation
    {
        $business = Business::create([
            'name' => 'نشاط اختبار الاستثناءات',
        ]);

        return $business->locations()->create([
            'name' => 'الفرع الرئيسي',
            'type' => 'branch',
            'timezone' => 'Asia/Aden',
            'country_code' => 'YE',
        ]);
    }

    /**
     * يمكن إغلاق الموقع بالكامل في تاريخ محدد.
     */
    public function test_location_can_be_closed_on_specific_date(): void
    {
        $location = $this->createLocation();

        $override = $location->dayOverrides()->create([
            'date' => '2026-08-10',
            'mode' => 'closed',
            'reason' => 'إجازة',
        ]);

        $this->assertTrue($override->location->is($location));
        $this->assertSame('closed', $override->mode);
        $this->assertSame(0, $override->intervals()->count());
    }

    /**
     * يمكن تحديد ساعات مخصصة ليوم معين.
     */
    public function test_custom_hours_override_can_have_intervals(): void
    {
        $location = $this->createLocation();

        $override = $location->dayOverrides()->create([
            'date' => '2026-08-11',
            'mode' => 'custom_hours',
            'reason' => 'دوام خاص',
        ]);

        $interval = $override->intervals()->create([
            'opens_at' => '09:00:00',
            'closes_at' => '13:00:00',
            'end_day_offset' => 0,
        ]);

        $this->assertTrue($interval->override->is($override));
        $this->assertSame(1, $override->intervals()->count());
    }

    /**
     * قاعدة البيانات تمنع إضافة فترة عمل ليوم مغلق.
     */
    public function test_closed_override_cannot_have_intervals(): void
    {
        $location = $this->createLocation();

        $override = $location->dayOverrides()->create([
            'date' => '2026-08-12',
            'mode' => 'closed',
        ]);

        $this->expectException(QueryException::class);

        $override->intervals()->create([
            'opens_at' => '08:00:00',
            'closes_at' => '12:00:00',
            'end_day_offset' => 0,
        ]);
    }

    /**
     * لا يمكن تحويل يوم إلى closed
     * بينما ما زالت لديه فترات عمل.
     */
    public function test_custom_hours_with_intervals_cannot_be_changed_to_closed(): void
    {
        $location = $this->createLocation();

        $override = $location->dayOverrides()->create([
            'date' => '2026-08-13',
            'mode' => 'custom_hours',
        ]);

        $override->intervals()->create([
            'opens_at' => '10:00:00',
            'closes_at' => '14:00:00',
            'end_day_offset' => 0,
        ]);

        $this->expectException(QueryException::class);

        $override->update([
            'mode' => 'closed',
        ]);
    }

    /**
     * لا يسمح باستثناءين لنفس الموقع والتاريخ.
     */
    public function test_location_cannot_have_duplicate_override_for_same_date(): void
    {
        $location = $this->createLocation();

        BusinessDayOverride::create([
            'business_location_id' => $location->id,
            'date' => '2026-08-14',
            'mode' => 'closed',
        ]);

        $this->expectException(QueryException::class);

        BusinessDayOverride::create([
            'business_location_id' => $location->id,
            'date' => '2026-08-14',
            'mode' => 'custom_hours',
        ]);
    }

    /**
     * الدوام الاستثنائي يمكن أن يمتد بعد منتصف الليل.
     */
    public function test_custom_interval_can_continue_to_next_day(): void
    {
        $location = $this->createLocation();

        $override = $location->dayOverrides()->create([
            'date' => '2026-08-15',
            'mode' => 'custom_hours',
        ]);

        $interval = $override->intervals()->create([
            'opens_at' => '20:00:00',
            'closes_at' => '02:00:00',
            'end_day_offset' => 1,
        ]);

        $this->assertSame(1, $interval->end_day_offset);
    }
}
