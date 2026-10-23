<?php

namespace Database\Seeders;

use App\Models\BusinessCategory;
use Illuminate\Database\Seeder;

final class BusinessCategorySeeder extends Seeder
{
    public function run(): void
    {
        $parents = [];

        $definitions = [
            [
                'code' => 'phones_electronics',
                'name_ar' => 'الهواتف والإلكترونيات',
                'sort_order' => 1,
            ],
            [
                'code' => 'technology_computing',
                'name_ar' => 'التقنية والحاسوب',
                'sort_order' => 2,
            ],
            [
                'code' => 'energy_electrical',
                'name_ar' => 'الطاقة والكهرباء',
                'sort_order' => 3,
            ],
        ];

        foreach ($definitions as $definition) {
            $parents[$definition['code']] = BusinessCategory::query()
                ->firstOrCreate(
                    ['code' => $definition['code']],
                    [
                        'name_ar' => $definition['name_ar'],
                        'parent_id' => null,
                        'is_active' => true,
                        'sort_order' => $definition['sort_order'],
                    ]
                );
        }

        $leaves = [
            [
                'code' => 'mobile_phones',
                'name_ar' => 'الهواتف',
                'parent' => 'phones_electronics',
                'sort_order' => 1,
            ],
            [
                'code' => 'mobile_accessories',
                'name_ar' => 'ملحقات الجوال',
                'parent' => 'phones_electronics',
                'sort_order' => 2,
            ],
            [
                'code' => 'computers',
                'name_ar' => 'أجهزة الحاسوب',
                'parent' => 'technology_computing',
                'sort_order' => 1,
            ],
            [
                'code' => 'it_services',
                'name_ar' => 'خدمات تقنية المعلومات',
                'parent' => 'technology_computing',
                'sort_order' => 2,
            ],
            [
                'code' => 'solar_energy',
                'name_ar' => 'الطاقة الشمسية',
                'parent' => 'energy_electrical',
                'sort_order' => 1,
            ],
            [
                'code' => 'batteries_inverters',
                'name_ar' => 'البطاريات والإنفرترات',
                'parent' => 'energy_electrical',
                'sort_order' => 2,
            ],
        ];

        foreach ($leaves as $leaf) {
            BusinessCategory::query()->firstOrCreate(
                ['code' => $leaf['code']],
                [
                    'name_ar' => $leaf['name_ar'],
                    'parent_id' => $parents[$leaf['parent']]->id,
                    'is_active' => true,
                    'sort_order' => $leaf['sort_order'],
                ]
            );
        }
    }
}
