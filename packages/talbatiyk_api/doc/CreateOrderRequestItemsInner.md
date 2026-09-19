# talbatiyk_api.model.CreateOrderRequestItemsInner

## Load the model package
```dart
import 'package:talbatiyk_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**productId** | **String** | Product existence is commercial state and must be validated after idempotency replay lookup inside OrderService. | 
**quantity** | **int** |  | 
**expectedUnitPrice** | **num** | This is the price Flutter observed when the user confirmed. Laravel compares it with Product.price and never stores it as the authoritative order price. | 
**expectedSupplierId** | **String** | This is a concurrency expectation, not the authoritative supplier. Laravel resolves the real supplier from Product. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


