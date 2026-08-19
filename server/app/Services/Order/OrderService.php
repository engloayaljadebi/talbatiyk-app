<?php

namespace App\Services\Order;

use App\Models\Business;
use App\Models\Order;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OrderService
{
    /**
     * Create a new order for the authenticated user.
     *
     * @param array{
     *     notes?: string|null,
     *     items: array<int, array{
     *         product_id: string,
     *         product_name: string,
     *         unit_price: numeric-string|int|float,
     *         quantity: int,
     *         supplier_id: string,
     *         supplier_name: string,
     *         image_url?: string|null
     *     }>
     * } $data
     */
    public function create(User $user, array $data): Order
    {
        $this->validateSuppliers($data['items']);

        return DB::transaction(function () use ($user, $data): Order {
            $order = $user->orders()->create([
                'status' => 'pending',
                'notes' => $data['notes'] ?? null,
            ]);

            foreach ($data['items'] as $item) {
                $order->items()->create([
                    'product_id' => $item['product_id'],
                    'product_name' => $item['product_name'],
                    'unit_price' => $item['unit_price'],
                    'quantity' => $item['quantity'],
                    'supplier_id' => $item['supplier_id'],
                    'supplier_name' => $item['supplier_name'],
                    'image_url' => $item['image_url'] ?? null,
                ]);
            }

            return $order->load('items');
        });
    }

    /**
     * Ensure every supplier exists and currently has
     * the active "supplier" capability.
     *
     * @param  array<int, array<string, mixed>>  $items
     */
    private function validateSuppliers(array $items): void
    {
        $supplierIds = collect($items)
            ->pluck('supplier_id')
            ->unique()
            ->values();

        $validSupplierIds = Business::query()
            ->whereIn('id', $supplierIds)
            ->whereHas('capabilities', function ($query): void {
                $query
                    ->where('business_capabilities.code', 'supplier')
                    ->whereNull('business_capability_assignments.disabled_at');
            })
            ->pluck('id');

        $invalidSupplierIds = $supplierIds->diff($validSupplierIds);

        if ($invalidSupplierIds->isNotEmpty()) {
            throw ValidationException::withMessages([
                'items' => [
                    'One or more suppliers are invalid or do not have an active supplier capability.',
                ],
            ]);
        }
    }
}
