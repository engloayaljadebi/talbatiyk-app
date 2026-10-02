<?php

namespace App\Http\Requests\Api\V1\Product;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Str;
use Illuminate\Validation\Validator;

class CreateProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        /*
         * Authorization الخاص بالنشاط والمورد يبقى داخل
         * ProductPublishingService حتى لا تتكرر قواعد الأعمال هنا.
         */
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => [
                'required',
                'string',
                'max:200',
            ],

            'category' => [
                'required',
                'string',
                'max:160',
            ],

            'brand' => [
                'nullable',
                'string',
                'max:160',
            ],

            'price' => [
                'required',
                'numeric',
                'gt:0',
            ],

            'quantity' => [
                'required',
                'integer',
                'min:0',
            ],

            'description' => [
                'nullable',
                'string',
                'max:5000',
            ],

            'is_available' => [
                'required',
                'boolean',
            ],

            'image' => [
                'nullable',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120',
            ],
        ];
    }

    /**
     * Validate Idempotency-Key separately from multipart fields.
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
        return trim(
            (string) $this->header('Idempotency-Key'),
        );
    }
}
