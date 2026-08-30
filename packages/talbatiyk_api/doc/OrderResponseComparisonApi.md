# talbatiyk_api.api.OrderResponseComparisonApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**orderResponseComparisonShow**](OrderResponseComparisonApi.md#orderresponsecomparisonshow) | **GET** /orders/{order}/supplier-responses | Compare all final supplier responses for one owned Order
[**orderResponseComparisonUpdate**](OrderResponseComparisonApi.md#orderresponsecomparisonupdate) | **PUT** /orders/{order}/supplier-selection | Replace the customer&#39;s supplier-response selection atomically


# **orderResponseComparisonShow**
> OrderResponseComparisonShow200Response orderResponseComparisonShow(order)

Compare all final supplier responses for one owned Order

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getOrderResponseComparisonApi();
final String order = order_example; // String | 

try {
    final response = api.orderResponseComparisonShow(order);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OrderResponseComparisonApi->orderResponseComparisonShow: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **order** | **String**|  | 

### Return type

[**OrderResponseComparisonShow200Response**](OrderResponseComparisonShow200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **orderResponseComparisonUpdate**
> OrderResponseComparisonShow200Response orderResponseComparisonUpdate(order, selectOrderSupplierResponsesRequest)

Replace the customer's supplier-response selection atomically

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getOrderResponseComparisonApi();
final String order = order_example; // String | 
final SelectOrderSupplierResponsesRequest selectOrderSupplierResponsesRequest = ; // SelectOrderSupplierResponsesRequest | 

try {
    final response = api.orderResponseComparisonUpdate(order, selectOrderSupplierResponsesRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OrderResponseComparisonApi->orderResponseComparisonUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **order** | **String**|  | 
 **selectOrderSupplierResponsesRequest** | [**SelectOrderSupplierResponsesRequest**](SelectOrderSupplierResponsesRequest.md)|  | 

### Return type

[**OrderResponseComparisonShow200Response**](OrderResponseComparisonShow200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

