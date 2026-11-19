<?php

/*
|--------------------------------------------------------------------------
| Order item shape constraints
|--------------------------------------------------------------------------
|
| - item_type defaults to catalog.
| - A manual item may omit product and supplier.
| - A catalog item must carry product and supplier.
| - A manual item must not carry product or supplier.
| - Only catalog and manual are valid item types.
|
*/

namespace Tests\Feature;

use App\Models\Business;
use App\Models\Order;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class OrderItemShapeConstraintsTest extends TestCase
{
    use RefreshDatabase;

    private string $orderId;

    private string $supplierId;

    protected function setUp(): void
    {
        parent::setUp();

        $user = User::factory()->create();

        $this->orderId = (string) Order::query()->create([
            'user_id' => $user->id,
            'status' => 'pending',
        ])->id;

        $this->supplierId = (string) Business::query()->create([
            'name' => 'Order item shape supplier',
            'status' => 'active',
        ])->id;
    }

    public function test_item_type_defaults_to_catalog(): void
    {
        $row = $this->itemRow();

        DB::table('order_items')->insert($row);

        $this->assertSame(
            'catalog',
            DB::table('order_items')
                ->where('id', $row['id'])
                ->value('item_type'),
        );
    }

    public function test_manual_item_may_omit_product_and_supplier(): void
    {
        $row = $this->itemRow($this->manualOverrides([
            'unit' => 'piece',
            'note' => 'Manual note',
        ]));

        DB::table('order_items')->insert($row);

        $stored = DB::table('order_items')
            ->where('id', $row['id'])
            ->first();

        $this->assertNotNull($stored);
        $this->assertSame('manual', $stored->item_type);
        $this->assertNull($stored->product_id);
        $this->assertNull($stored->supplier_id);
        $this->assertNull($stored->supplier_name);
        $this->assertSame('piece', $stored->unit);
        $this->assertSame('Manual note', $stored->note);
    }

    public function test_invalid_item_shapes_are_rejected_by_the_database(): void
    {
        $cases = [
            'manual with product_id' => $this->manualOverrides([
                'product_id' => 'some-product',
            ]),
            'manual with supplier_id' => $this->manualOverrides([
                'supplier_id' => $this->supplierId,
            ]),
            'manual with supplier_name' => $this->manualOverrides([
                'supplier_name' => 'Some supplier',
            ]),
            'catalog without product_id' => [
                'item_type' => 'catalog',
                'product_id' => null,
            ],
            'catalog without supplier_id' => [
                'item_type' => 'catalog',
                'supplier_id' => null,
            ],
            'catalog without supplier_name' => [
                'item_type' => 'catalog',
                'supplier_name' => null,
            ],
            'unknown item type' => [
                'item_type' => 'service',
            ],
        ];

        foreach ($cases as $label => $overrides) {
            $row = $this->itemRow($overrides);

            try {
                DB::transaction(function () use ($row): void {
                    DB::table('order_items')->insert($row);
                });

                $this->fail(
                    'Expected a constraint violation for: '.$label,
                );
            } catch (QueryException) {
                $this->addToAssertionCount(1);
            }
        }

        $this->assertDatabaseCount('order_items', 0);
    }

    /**
     * @param  array<string, mixed>  $extra
     * @return array<string, mixed>
     */
    private function manualOverrides(array $extra = []): array
    {
        return array_merge([
            'item_type' => 'manual',
            'product_id' => null,
            'supplier_id' => null,
            'supplier_name' => null,
        ], $extra);
    }

    /**
     * @param  array<string, mixed>  $overrides
     * @return array<string, mixed>
     */
    private function itemRow(array $overrides = []): array
    {
        return array_merge([
            'id' => (string) Str::uuid(),
            'order_id' => $this->orderId,
            'product_id' => (string) Str::uuid(),
            'product_name' => 'Shape test item',
            'unit_price' => 10,
            'quantity' => 1,
            'supplier_id' => $this->supplierId,
            'supplier_name' => 'Order item shape supplier',
        ], $overrides);
    }
}
