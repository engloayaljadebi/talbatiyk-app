<?php

namespace App\Http\Requests\Api\V1\Order;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Str;
use Illuminate\Validation\Validator;

/*
|--------------------------------------------------------------------------
| Create Order Request
|--------------------------------------------------------------------------
|
| Validates order intent and the commercial values observed by Flutter.
| Product name, supplier name and image are server-authoritative snapshots
| and therefore are not required from the client.
|
*/
class CreateOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'notes' => [
                'nullable',
                'string',
                'max:2000',
            ],

            'supplier_ids' => [
                'required',
                'array',
                'min:1',
                'max:10',
            ],

            'supplier_ids.*' => [
                'required',
                'uuid',
                'distinct',
            ],
            'items' => [
                'required',
                'array',
                'min:1',
                'max:50',
            ],

            'items.*' => [
                'required',
                'array',
            ],

            /*
             * Product existence is commercial state and must be validated
             * after idempotency replay lookup inside OrderService.
             */
            'items.*.product_id' => [
                'required',
                'uuid',
            ],

            'items.*.quantity' => [
                'required',
                'integer',
                'min:1',
            ],

            /*
             * This is the price Flutter observed when the user confirmed.
             * Laravel compares it with Product.price and never stores it
             * as the authoritative order price.
             */
            'items.*.expected_unit_price' => [
                'required',
                'numeric',
                'decimal:0,2',
                'min:0',
                'lt:10000000000',
            ],

            /*
             * This is a concurrency expectation, not the authoritative
             * supplier. Laravel resolves the real supplier from Product.
             */
            'items.*.expected_supplier_id' => [
                'required',
                'uuid',
            ],
        ];
    }

    /**
     * Validate the idempotency header separately from the JSON body.
     *
     * @return array<int, callable>
     */
    public function after(): array
    {
        return [
            function (Validator $validator): void {
                $idempotencyKey = trim(
                    (string) $this->header('Idempotency-Key', ''),
                );

                if ($idempotencyKey === '') {
                    $validator->errors()->add(
                        'Idempotency-Key',
                        'The Idempotency-Key header is required.',
                    );

                    return;
                }

                if (! Str::isUuid($idempotencyKey)) {
                    $validator->errors()->add(
                        'Idempotency-Key',
                        'The Idempotency-Key header must be a valid UUID.',
                    );
                }
            },
        ];
    }

    public function idempotencyKey(): string
    {
        return trim((string) $this->header('Idempotency-Key'));
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'notes' => $this->filled('notes')
                ? trim((string) $this->input('notes'))
                : null,
        ]);
    }
}
