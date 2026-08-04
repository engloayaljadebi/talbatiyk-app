# Orders API integration

The cart remains local to the Flutter app. The backend receives an order only
after the user confirms the cart.

## Create an order

```text
POST /orders
```

```json
{
  "items": [
    {
      "product_id": "product-1",
      "product_name": "Fast charger",
      "unit_price": 4500,
      "quantity": 2,
      "image_url": "https://example.com/product.png"
    }
  ],
  "notes": "Call before delivery"
}
```

The server should calculate and validate the final total from current product
prices. It should not trust a total sent by the client.

## List orders

```text
GET /orders
```

Both endpoints return complete order objects:

```json
{
  "data": {
    "id": "order-1",
    "status": "pending",
    "created_at": "2026-08-04T00:00:00Z",
    "items": [
      {
        "product_id": "product-1",
        "product_name": "Fast charger",
        "unit_price": 4500,
        "quantity": 2,
        "image_url": "https://example.com/product.png"
      }
    ]
  }
}
```

The list response may contain the order list directly or under `data`, `items`,
or `orders`.

Supported statuses are:

- `pending`
- `confirmed`
- `preparing`
- `ready_for_delivery`
- `out_for_delivery`
- `delivered`
- `cancelled`

To enable the backend, implement `ApiClient`, create
`OrdersRemoteDataSource(client: apiClient)`, and override
`ordersDataSourceProvider` in the root `ProviderScope`.
