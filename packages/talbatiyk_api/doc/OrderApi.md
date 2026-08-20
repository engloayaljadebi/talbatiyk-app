# talbatiyk_api.api.OrderApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**orderStore**](OrderApi.md#orderstore) | **POST** /orders | Create a new order for the authenticated user


# **orderStore**
> OrderStore201Response orderStore(createOrderRequest)

Create a new order for the authenticated user

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getOrderApi();
final CreateOrderRequest createOrderRequest = ; // CreateOrderRequest |

try {
    final response = api.orderStore(createOrderRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OrderApi->orderStore: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createOrderRequest** | [**CreateOrderRequest**](CreateOrderRequest.md)|  |

### Return type

[**OrderStore201Response**](OrderStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
