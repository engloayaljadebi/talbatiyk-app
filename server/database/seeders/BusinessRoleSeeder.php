<?php

/*
|--------------------------------------------------------------------------
| Seeder أدوار الأنشطة التجارية
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إنشاء الأدوار الأساسية المستخدمة داخل الأنشطة.
| - الحفاظ على الأكواد كقيم مرجعية ثابتة.
| - إمكانية تشغيل Seeder أكثر من مرة بدون إنشاء تكرار.
|
| الأدوار الحالية:
| - owner   : مالك النشاط.
| - manager : مدير النشاط.
| - staff   : موظف.
|
*/

namespace Database\Seeders;

use App\Models\BusinessRole;
use Illuminate\Database\Seeder;

class BusinessRoleSeeder extends Seeder
{
    /**
     * إنشاء أو تحديث الأدوار الأساسية.
     */
    public function run(): void
    {
        $roles = [
            [
                'code' => 'owner',
                'is_active' => true,
            ],
            [
                'code' => 'manager',
                'is_active' => true,
            ],
            [
                'code' => 'staff',
                'is_active' => true,
            ],
        ];

        foreach ($roles as $role) {
            BusinessRole::query()->updateOrCreate(
                [
                    'code' => $role['code'],
                ],
                [
                    'is_active' => $role['is_active'],
                ],
            );
        }
    }
}
