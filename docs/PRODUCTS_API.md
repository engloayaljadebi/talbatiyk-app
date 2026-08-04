# Products API integration

The Products feature now depends on `ProductsDataSource`, not on a concrete
local implementation. The current app uses `ProductsLocalDataSource` so the UI
continues to work before the backend is available.

## Expected endpoint

Default path:

```text
GET /products
```

The remote data source accepts a JSON list directly or a list nested under
`data`, `items`, or `products`.

```json
{
  "data": {
    "products": [
      {
        "id": "product-1",
        "name": "Fast charger",
        "price": 4500,
        "image_url": "https://example.com/product.png",
        "category": "Chargers",
        "brand": "Samsung",
        "is_available": true,
        "description": "One-year warranty",
        "colors": ["black", "white"],
        "stock_quantity": 20,
        "discount": 0,
        "rating": 4.8
      }
    ]
  }
}
```

Both camelCase and snake_case are supported for `imageUrl`/`image_url` and
`isAvailable`/`is_available`.

`id`, `name`, `price`, and the availability field are required. Invalid
payloads fail fast with a `FormatException` instead of showing incorrect
products in the ordering flow.

## Switching to the backend

1. Implement the shared `ApiClient` using the selected HTTP package.
2. Create `ProductsRemoteDataSource(client: apiClient)`.
3. Override `productsDataSourceProvider` at the app's `ProviderScope`.

No changes are required in `ProductsPage`, `ProductsController`, the use case,
or the repository contract.
