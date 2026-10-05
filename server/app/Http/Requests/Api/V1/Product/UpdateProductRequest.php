<?php

namespace App\Http\Requests\Api\V1\Product;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProductRequest extends FormRequest
{
    protected function prepareForValidation(): void
    {
        $normalized = [];

        foreach (['is_available', 'remove_image'] as $field) {
            $value = $this->input($field);

            if ($value === 'true' || $value === 'false') {
                $normalized[$field] = $value === 'true';
            }
        }

        if ($normalized !== []) {
            $this->merge($normalized);
        }
    }

    public function rules(): array
    {
        return [
            'expected_version' => [
                'required',
                'integer',
                'min:1',
            ],

            'name' => ['required', 'string', 'max:200'],
            'description' => ['nullable', 'string', 'max:5000'],
            'category' => ['required', 'string', 'max:150'],
            'brand' => ['nullable', 'string', 'max:150'],

            'price' => ['required', 'numeric', 'gt:0'],
            'quantity' => ['required', 'integer', 'min:0'],
            'is_available' => ['required', 'boolean'],

            'remove_image' => ['sometimes', 'boolean'],

            'supplier_id' => ['prohibited'],
            'supplier_name' => ['prohibited'],
            'image_url' => ['prohibited'],
            'version' => ['prohibited'],
            'rating' => ['prohibited'],
            'discount' => ['prohibited'],
            'colors' => ['prohibited'],
            'idempotency_key' => ['prohibited'],
            'idempotency_payload_hash' => ['prohibited'],
            'deleted_at' => ['prohibited'],
        ];
    }
}
