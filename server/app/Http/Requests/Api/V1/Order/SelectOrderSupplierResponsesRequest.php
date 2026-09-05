<?php

namespace App\Http\Requests\Api\V1\Order;

use Illuminate\Foundation\Http\FormRequest;

class SelectOrderSupplierResponsesRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'expected_version' => [
                'required',
                'integer',
                'min:1',
            ],

            'selections' => [
                'required',
                'array',
                'min:1',
                'max:50',
            ],

            'selections.*.order_recipient_item_response_id' => [
                'required',
                'uuid',
                'distinct',
            ],

            'selections.*.selected_quantity' => [
                'required',
                'integer',
                'min:1',
            ],
        ];
    }
}
