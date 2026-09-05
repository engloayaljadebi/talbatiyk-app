<?php

namespace Tests\Feature\Api\V1\Security;

use App\Http\Requests\Api\V1\Order\CreateOrderRequest;
use App\Http\Requests\Api\V1\Order\SelectOrderSupplierResponsesRequest;
use App\Http\Requests\Api\V1\Order\SubmitSupplierOrderResponseRequest;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Tests\TestCase;

class OrderRequestCardinalityLimitTest extends TestCase
{
    public function test_order_supplier_ids_allow_ten_and_reject_eleven(): void
    {
        $payload = [
            'supplier_ids' => $this->uuids(10),
            'items' => [$this->orderItem()],
        ];

        $this->assertFalse(
            Validator::make(
                $payload,
                (new CreateOrderRequest())->rules(),
            )->fails(),
        );

        $payload['supplier_ids'][] = (string) Str::uuid();

        $validator = Validator::make(
            $payload,
            (new CreateOrderRequest())->rules(),
        );

        $this->assertTrue($validator->fails());
        $this->assertArrayHasKey(
            'supplier_ids',
            $validator->errors()->toArray(),
        );
    }

    public function test_order_items_allow_fifty_and_reject_fifty_one(): void
    {
        $payload = [
            'supplier_ids' => [(string) Str::uuid()],
            'items' => array_map(
                fn (): array => $this->orderItem(),
                range(1, 50),
            ),
        ];

        $this->assertFalse(
            Validator::make(
                $payload,
                (new CreateOrderRequest())->rules(),
            )->fails(),
        );

        $payload['items'][] = $this->orderItem();

        $validator = Validator::make(
            $payload,
            (new CreateOrderRequest())->rules(),
        );

        $this->assertTrue($validator->fails());
        $this->assertArrayHasKey(
            'items',
            $validator->errors()->toArray(),
        );
    }

    public function test_supplier_response_items_allow_fifty_and_reject_fifty_one(): void
    {
        $payload = [
            'items' => array_map(
                fn (): array => $this->responseItem(),
                range(1, 50),
            ),
        ];

        $this->assertFalse(
            Validator::make(
                $payload,
                (new SubmitSupplierOrderResponseRequest())->rules(),
            )->fails(),
        );

        $payload['items'][] = $this->responseItem();

        $validator = Validator::make(
            $payload,
            (new SubmitSupplierOrderResponseRequest())->rules(),
        );

        $this->assertTrue($validator->fails());
        $this->assertArrayHasKey(
            'items',
            $validator->errors()->toArray(),
        );
    }

    public function test_selections_allow_fifty_and_reject_fifty_one(): void
    {
        $payload = [
            'expected_version' => 1,
            'selections' => array_map(
                fn (): array => $this->selection(),
                range(1, 50),
            ),
        ];

        $this->assertFalse(
            Validator::make(
                $payload,
                (new SelectOrderSupplierResponsesRequest())->rules(),
            )->fails(),
        );

        $payload['selections'][] = $this->selection();

        $validator = Validator::make(
            $payload,
            (new SelectOrderSupplierResponsesRequest())->rules(),
        );

        $this->assertTrue($validator->fails());
        $this->assertArrayHasKey(
            'selections',
            $validator->errors()->toArray(),
        );
    }

    /**
     * @return array<int, string>
     */
    private function uuids(int $count): array
    {
        return array_map(
            static fn (): string => (string) Str::uuid(),
            range(1, $count),
        );
    }

    /**
     * @return array<string, mixed>
     */
    private function orderItem(): array
    {
        return [
            'product_id' => (string) Str::uuid(),
            'quantity' => 1,
            'expected_unit_price' => 1,
            'expected_supplier_id' => (string) Str::uuid(),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function responseItem(): array
    {
        return [
            'order_recipient_item_id' => (string) Str::uuid(),
            'availability_status' => 'unavailable',
            'available_quantity' => 0,
            'offered_unit_price' => null,
            'response_notes' => null,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function selection(): array
    {
        return [
            'order_recipient_item_response_id' => (string) Str::uuid(),
            'selected_quantity' => 1,
        ];
    }
}
