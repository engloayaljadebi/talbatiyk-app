<?php

namespace Database\Seeders;

use App\Models\Business;
use App\Models\Product;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class DevelopmentCatalogSeeder extends Seeder
{
    public function run(): void
    {
        if (app()->environment('production')) {
            throw new RuntimeException(
                'DevelopmentCatalogSeeder must not run in production.'
            );
        }

        $this->call(BusinessCapabilitySeeder::class);

        DB::transaction(function (): void {
            foreach ($this->suppliers() as $supplierData) {
                $products = $supplierData['products'];
                unset($supplierData['products']);

                $supplier = Business::withTrashed()
                    ->firstOrNew([
                        'name' => $supplierData['name'],
                    ]);

                $supplier->fill([
                    'legal_name' => $supplierData['legal_name'],
                    'description' => $supplierData['description'],
                    'status' => 'active',
                ]);

                $supplier->deleted_at = null;
                $supplier->save();

                // Product Discovery requires an active supplier capability.
                $supplier->capabilities()->syncWithoutDetaching([
                    'supplier' => [
                        'enabled_at' => now(),
                        'disabled_at' => null,
                    ],
                ]);

                foreach ($products as $productData) {
                    $product = Product::withTrashed()
                        ->firstOrNew([
                            'supplier_id' => $supplier->id,
                            'name' => $productData['name'],
                        ]);

                    $product->fill([
                        'supplier_id' => $supplier->id,
                        'name' => $productData['name'],
                        'description' => $productData['description'],
                        'category' => $productData['category'],
                        'brand' => $productData['brand'],
                        'price' => $productData['price'],
                        'quantity' => $productData['quantity'],
                        'is_available' => true,
                        'image_url' => '',
                        'colors' => $productData['colors'],
                        'discount' => $productData['discount'],
                        'rating' => $productData['rating'],
                    ]);

                    $product->deleted_at = null;
                    $product->save();
                }
            }
        });

        $this->command?->info(
            'Development catalog seeded: 3 suppliers / 12 products.'
        );
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function suppliers(): array
    {
        return [
            [
                'name' => 'تقنية صنعاء',
                'legal_name' => 'تقنية صنعاء للإلكترونيات',
                'description' => 'مورد تجريبي للهواتف والإكسسوارات.',
                'products' => [
                    [
                        'name' => 'شاحن سريع USB-C 45W',
                        'description' => 'شاحن سريع مناسب للهواتف والأجهزة اللوحية.',
                        'category' => 'شواحن',
                        'brand' => 'Talbatiyk Tech',
                        'price' => 4500,
                        'quantity' => 30,
                        'colors' => ['أسود', 'أبيض'],
                        'discount' => 0,
                        'rating' => 4.8,
                    ],
                    [
                        'name' => 'كيبل USB-C بطول مترين',
                        'description' => 'كيبل شحن ونقل بيانات عالي التحمل.',
                        'category' => 'كيابل',
                        'brand' => 'Talbatiyk Tech',
                        'price' => 1800,
                        'quantity' => 60,
                        'colors' => ['أسود'],
                        'discount' => 5,
                        'rating' => 4.5,
                    ],
                    [
                        'name' => 'سماعة بلوتوث لاسلكية',
                        'description' => 'سماعة لاسلكية للاستخدام اليومي والمكالمات.',
                        'category' => 'سماعات',
                        'brand' => 'Sound Pro',
                        'price' => 8500,
                        'quantity' => 18,
                        'colors' => ['أسود', 'أبيض', 'أزرق'],
                        'discount' => 10,
                        'rating' => 4.6,
                    ],
                    [
                        'name' => 'حامل جوال للسيارة',
                        'description' => 'حامل مغناطيسي ثابت وسهل التركيب.',
                        'category' => 'إكسسوارات',
                        'brand' => 'Drive Tech',
                        'price' => 3200,
                        'quantity' => 25,
                        'colors' => ['أسود'],
                        'discount' => 0,
                        'rating' => 4.3,
                    ],
                ],
            ],

            [
                'name' => 'مركز الطاقة',
                'legal_name' => 'مركز الطاقة للتجارة',
                'description' => 'مورد تجريبي للطاقة والشحن والبطاريات.',
                'products' => [
                    [
                        'name' => 'باور بانك 10000mAh',
                        'description' => 'بطارية متنقلة مع شحن سريع ومخرجين USB.',
                        'category' => 'طاقة',
                        'brand' => 'Power Max',
                        'price' => 9500,
                        'quantity' => 20,
                        'colors' => ['أسود', 'أبيض'],
                        'discount' => 5,
                        'rating' => 4.7,
                    ],
                    [
                        'name' => 'باور بانك 20000mAh',
                        'description' => 'بطارية متنقلة بسعة كبيرة للاستخدام الطويل.',
                        'category' => 'طاقة',
                        'brand' => 'Power Max',
                        'price' => 14500,
                        'quantity' => 15,
                        'colors' => ['أسود'],
                        'discount' => 0,
                        'rating' => 4.6,
                    ],
                    [
                        'name' => 'شاحن سيارة مزدوج',
                        'description' => 'شاحن سيارة بمنفذي USB ودعم الشحن السريع.',
                        'category' => 'شواحن',
                        'brand' => 'Power Max',
                        'price' => 3800,
                        'quantity' => 35,
                        'colors' => ['أسود'],
                        'discount' => 0,
                        'rating' => 4.4,
                    ],
                    [
                        'name' => 'وصلة كهرباء ذكية',
                        'description' => 'وصلة كهربائية متعددة المخارج مع حماية.',
                        'category' => 'كهربائيات',
                        'brand' => 'Home Power',
                        'price' => 7200,
                        'quantity' => 12,
                        'colors' => ['أبيض'],
                        'discount' => 7,
                        'rating' => 4.5,
                    ],
                ],
            ],

            [
                'name' => 'بيت الجوال',
                'legal_name' => 'بيت الجوال للإلكترونيات',
                'description' => 'مورد تجريبي لإكسسوارات الهواتف.',
                'products' => [
                    [
                        'name' => 'جراب حماية شفاف',
                        'description' => 'جراب مرن لحماية الهاتف من الخدوش والصدمات.',
                        'category' => 'حماية',
                        'brand' => 'Mobile House',
                        'price' => 1500,
                        'quantity' => 80,
                        'colors' => ['شفاف'],
                        'discount' => 0,
                        'rating' => 4.2,
                    ],
                    [
                        'name' => 'حماية شاشة زجاجية',
                        'description' => 'زجاج حماية مقاوم للخدش والصدمات اليومية.',
                        'category' => 'حماية',
                        'brand' => 'Glass Pro',
                        'price' => 1200,
                        'quantity' => 100,
                        'colors' => ['شفاف'],
                        'discount' => 0,
                        'rating' => 4.4,
                    ],
                    [
                        'name' => 'ستاند جوال مكتبي',
                        'description' => 'حامل قابل للتعديل للمكتب ومشاهدة الفيديو.',
                        'category' => 'إكسسوارات',
                        'brand' => 'Mobile House',
                        'price' => 2800,
                        'quantity' => 40,
                        'colors' => ['أسود', 'فضي'],
                        'discount' => 5,
                        'rating' => 4.5,
                    ],
                    [
                        'name' => 'سماعة سلكية Type-C',
                        'description' => 'سماعة Type-C للموسيقى والمكالمات.',
                        'category' => 'سماعات',
                        'brand' => 'Mobile House',
                        'price' => 3500,
                        'quantity' => 32,
                        'colors' => ['أبيض', 'أسود'],
                        'discount' => 0,
                        'rating' => 4.3,
                    ],
                ],
            ],
        ];
    }
}
