# talbatiyk_api.model.CreateOrderRequestItemsInner

## Load the model package
```dart
import 'package:talbatiyk_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**itemType** | **String** | Omitted or null means catalog. The value is intentionally not injected into the validated data so that the idempotency payload hash of existing clients stays unchanged. | [optional] 
**productId** | **String** | Catalog items only. Product existence is commercial state and must be validated after idempotency replay lookup inside OrderService. | [optional] 
**quantity** | **int** |  | 
**expectedUnitPrice** | **num** | Catalog items only. This is the price Flutter observed when the user confirmed. Laravel compares it with Product.price and never stores it as the authoritative order price. | [optional] 
**expectedSupplierId** | **String** | Catalog items only. This is a concurrency expectation, not the authoritative supplier. Laravel resolves the real supplier from Product. | [optional] 
**name** | **String** | Manual items only. The name is stored in order_items.product_name and the price in order_items.unit_price. A manual item has one price only. | [optional] 
**unitPrice** | **num** |  | [optional] 
**unit** | **String** |  | [optional] 
**note** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


