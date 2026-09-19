# talbatiyk_api.api.SupplierDiscoveryApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**supplierDiscoveryIndex**](SupplierDiscoveryApi.md#supplierdiscoveryindex) | **GET** /suppliers | 


# **supplierDiscoveryIndex**
> SupplierDiscoveryIndex200Response supplierDiscoveryIndex()



### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getSupplierDiscoveryApi();

try {
    final response = api.supplierDiscoveryIndex();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupplierDiscoveryApi->supplierDiscoveryIndex: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SupplierDiscoveryIndex200Response**](SupplierDiscoveryIndex200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

