# talbatiyk_api.api.SupplierOrderApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**supplierOrderIndex**](SupplierOrderApi.md#supplierorderindex) | **GET** /businesses/{business}/received-orders | List orders received by one supplier Business


# **supplierOrderIndex**
> SupplierOrderIndex200Response supplierOrderIndex(business)

List orders received by one supplier Business

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getSupplierOrderApi();
final String business = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | The business ID

try {
    final response = api.supplierOrderIndex(business);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupplierOrderApi->supplierOrderIndex: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**| The business ID | 

### Return type

[**SupplierOrderIndex200Response**](SupplierOrderIndex200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

