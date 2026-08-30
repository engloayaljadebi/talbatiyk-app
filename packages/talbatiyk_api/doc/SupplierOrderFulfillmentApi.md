# talbatiyk_api.api.SupplierOrderFulfillmentApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**supplierOrderFulfillmentUpdate**](SupplierOrderFulfillmentApi.md#supplierorderfulfillmentupdate) | **PATCH** /businesses/{business}/received-orders/{recipient}/fulfillment | Advance one supplier Recipient through its fulfillment lifecycle


# **supplierOrderFulfillmentUpdate**
> SupplierOrderFulfillmentUpdate200Response supplierOrderFulfillmentUpdate(business, recipient, updateSupplierFulfillmentRequest)

Advance one supplier Recipient through its fulfillment lifecycle

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getSupplierOrderFulfillmentApi();
final String business = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | The business ID
final String recipient = recipient_example; // String | 
final UpdateSupplierFulfillmentRequest updateSupplierFulfillmentRequest = ; // UpdateSupplierFulfillmentRequest | 

try {
    final response = api.supplierOrderFulfillmentUpdate(business, recipient, updateSupplierFulfillmentRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupplierOrderFulfillmentApi->supplierOrderFulfillmentUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**| The business ID | 
 **recipient** | **String**|  | 
 **updateSupplierFulfillmentRequest** | [**UpdateSupplierFulfillmentRequest**](UpdateSupplierFulfillmentRequest.md)|  | 

### Return type

[**SupplierOrderFulfillmentUpdate200Response**](SupplierOrderFulfillmentUpdate200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

