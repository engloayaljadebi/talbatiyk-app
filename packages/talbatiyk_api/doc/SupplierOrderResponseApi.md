# talbatiyk_api.api.SupplierOrderResponseApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**supplierOrderResponseStore**](SupplierOrderResponseApi.md#supplierorderresponsestore) | **POST** /businesses/{business}/received-orders/{recipient}/response | Submit the final response for one supplier order recipient


# **supplierOrderResponseStore**
> SupplierOrderResponseStore201Response supplierOrderResponseStore(business, recipient, idempotencyKey, submitSupplierOrderResponseRequest)

Submit the final response for one supplier order recipient

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getSupplierOrderResponseApi();
final String business = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | The business ID
final String recipient = recipient_example; // String | 
final String idempotencyKey = 550e8400-e29b-41d4-a716-446655440000; // String | Stable UUID reused for retries of the same logical supplier response.
final SubmitSupplierOrderResponseRequest submitSupplierOrderResponseRequest = ; // SubmitSupplierOrderResponseRequest | 

try {
    final response = api.supplierOrderResponseStore(business, recipient, idempotencyKey, submitSupplierOrderResponseRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupplierOrderResponseApi->supplierOrderResponseStore: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**| The business ID | 
 **recipient** | **String**|  | 
 **idempotencyKey** | **String**| Stable UUID reused for retries of the same logical supplier response. | 
 **submitSupplierOrderResponseRequest** | [**SubmitSupplierOrderResponseRequest**](SubmitSupplierOrderResponseRequest.md)|  | 

### Return type

[**SupplierOrderResponseStore201Response**](SupplierOrderResponseStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

