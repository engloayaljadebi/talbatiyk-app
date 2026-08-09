<?php

/*
|--------------------------------------------------------------------------
| Seeder قدرات الأنشطة التجارية
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إنشاء القدرات التجارية الأساسية مرة واحدة.
| - عدم تكرار supplier و shop داخل جدول businesses.
| - إعادة تفعيل القدرة إذا كانت موجودة وغير مستخدمة سابقًا.
|
| القدرات الحالية:
| - supplier : مورد / موزع.
| - shop     : متجر / بائع تجزئة.
|
*/

namespace Database\Seeders;

use App\Models\BusinessCapability;
use Illuminate\Database\Seeder;

class BusinessCapabilitySeeder extends Seeder
{
    /**
     * إنشاء أو تحديث القدرات الأساسية.
     */
    public function run(): void
    {
        foreach (['supplier', 'shop'] as $code) {
            BusinessCapability::query()->updateOrCreate(
                [
                    'code' => $code,
                ],
                [
                    'retired_at' => null,
                ],
            );
        }
    }
}
