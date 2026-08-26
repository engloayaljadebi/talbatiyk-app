<?php

namespace App\Http\Requests\Api\V1\Order;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Support\Str;
use Illuminate\Validation\Validator;

class CreateOrderRequest extends FormRequest
{
    /**
     * المستخدم يجب أن يكون موثقًا بواسطة middleware.
     */
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

            'items' => [
                'required',
                'array',
                'min:1',
            ],

            'items.*' => [
                'required',
                'array',
            ],

            'items.*.product_id' => [
                'required',
                'string',
                'max:255',
            ],

            'items.*.product_name' => [
                'required',
                'string',
                'max:255',
            ],

            'items.*.unit_price' => [
                'required',
                'numeric',
                'min:0',
            ],

            'items.*.quantity' => [
                'required',
                'integer',
                'min:1',
            ],

            'items.*.supplier_id' => [
                'required',
                'uuid',
                Rule::exists('businesses', 'id')
                    ->whereNull('deleted_at'),
            ],

            'items.*.supplier_name' => [
                'required',
                'string',
                'max:200',
            ],

            'items.*.image_url' => [
                'nullable',
                'string',
                'max:2048',
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

                if (!Str::isUuid($idempotencyKey)) {
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
