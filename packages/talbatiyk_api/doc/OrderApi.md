# talbatiyk_api.api.OrderApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**orderIndex**](OrderApi.md#orderindex) | **GET** /orders | Return orders owned by the authenticated customer
[**orderStore**](OrderApi.md#orderstore) | **POST** /orders | Create a new order for the authenticated user


# **orderIndex**
> OrderIndex200Response orderIndex()

Return orders owned by the authenticated customer

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getOrderApi();

try {
    final response = api.orderIndex();
    print(response);
} on DioException catch (e) {
    print('Exception when calling OrderApi->orderIndex: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**OrderIndex200Response**](OrderIndex200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **orderStore**
> OrderStore201Response orderStore(idempotencyKey, createOrderRequest)

Create a new order for the authenticated user

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getOrderApi();
final String idempotencyKey = 550e8400-e29b-41d4-a716-446655440000; // String | Stable UUID reused for retries of the same logical order creation.
final CreateOrderRequest createOrderRequest = ; // CreateOrderRequest | 

try {
    final response = api.orderStore(idempotencyKey, createOrderRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OrderApi->orderStore: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Stable UUID reused for retries of the same logical order creation. | 
 **createOrderRequest** | [**CreateOrderRequest**](CreateOrderRequest.md)|  | 

### Return type

[**OrderStore201Response**](OrderStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

