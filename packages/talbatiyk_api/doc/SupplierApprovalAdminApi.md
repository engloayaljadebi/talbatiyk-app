# talbatiyk_api.api.SupplierApprovalAdminApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**supplierApprovalAdminApprove**](SupplierApprovalAdminApi.md#supplierapprovaladminapprove) | **POST** /platform/supplier-approvals/{verification}/approve | Approve exactly one pending supplier application
[**supplierApprovalAdminIndex**](SupplierApprovalAdminApi.md#supplierapprovaladminindex) | **GET** /platform/supplier-approvals | List pending supplier applications for authorized platform staff
[**supplierApprovalAdminReject**](SupplierApprovalAdminApi.md#supplierapprovaladminreject) | **POST** /platform/supplier-approvals/{verification}/reject | Reject exactly one pending supplier application. A meaningful reason is mandatory


# **supplierApprovalAdminApprove**
> SupplierApprovalAdminApprove200Response supplierApprovalAdminApprove(verification, supplierApprovalAdminApproveRequest)

Approve exactly one pending supplier application

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getSupplierApprovalAdminApi();
final String verification = verification_example; // String | 
final SupplierApprovalAdminApproveRequest supplierApprovalAdminApproveRequest = ; // SupplierApprovalAdminApproveRequest | 

try {
    final response = api.supplierApprovalAdminApprove(verification, supplierApprovalAdminApproveRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupplierApprovalAdminApi->supplierApprovalAdminApprove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verification** | **String**|  | 
 **supplierApprovalAdminApproveRequest** | [**SupplierApprovalAdminApproveRequest**](SupplierApprovalAdminApproveRequest.md)|  | [optional] 

### Return type

[**SupplierApprovalAdminApprove200Response**](SupplierApprovalAdminApprove200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **supplierApprovalAdminIndex**
> SupplierApprovalAdminIndex200Response supplierApprovalAdminIndex(perPage)

List pending supplier applications for authorized platform staff

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getSupplierApprovalAdminApi();
final int perPage = 56; // int | 

try {
    final response = api.supplierApprovalAdminIndex(perPage);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupplierApprovalAdminApi->supplierApprovalAdminIndex: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**|  | [optional] 

### Return type

[**SupplierApprovalAdminIndex200Response**](SupplierApprovalAdminIndex200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **supplierApprovalAdminReject**
> SupplierApprovalAdminApprove200Response supplierApprovalAdminReject(verification, supplierApprovalAdminRejectRequest)

Reject exactly one pending supplier application. A meaningful reason is mandatory

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getSupplierApprovalAdminApi();
final String verification = verification_example; // String | 
final SupplierApprovalAdminRejectRequest supplierApprovalAdminRejectRequest = ; // SupplierApprovalAdminRejectRequest | 

try {
    final response = api.supplierApprovalAdminReject(verification, supplierApprovalAdminRejectRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupplierApprovalAdminApi->supplierApprovalAdminReject: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verification** | **String**|  | 
 **supplierApprovalAdminRejectRequest** | [**SupplierApprovalAdminRejectRequest**](SupplierApprovalAdminRejectRequest.md)|  | 

### Return type

[**SupplierApprovalAdminApprove200Response**](SupplierApprovalAdminApprove200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

