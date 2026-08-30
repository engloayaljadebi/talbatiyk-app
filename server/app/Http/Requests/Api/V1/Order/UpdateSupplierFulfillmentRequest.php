<?php

namespace App\Http\Requests\Api\V1\Order;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSupplierFulfillmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'expected_version' => [
                'required',
                'integer',
                'min:1',
            ],

            'status' => [
                'required',
                'string',
                'in:preparing,ready_for_delivery,out_for_delivery,delivered',
            ],
        ];
    }

    /**
     * @return array{expected_version: int, status: string}
     */
    public function fulfillmentPayload(): array
    {
        return $this->validated();
    }
}
