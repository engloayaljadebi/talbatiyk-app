<?php

/*
|--------------------------------------------------------------------------
| Seeder الرئيسي لقاعدة البيانات
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - تشغيل البيانات المرجعية الأساسية للنظام.
| - عدم إنشاء مستخدمين تجريبيين تلقائيًا.
| - إبقاء Seeders قابلة للتشغيل في التطوير والاختبارات وCI.
|
*/

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * تشغيل Seeders الأساسية.
     */
    public function run(): void
    {
        $this->call([
            BusinessRoleSeeder::class,
            BusinessCapabilitySeeder::class,
        ]);
    }
}
