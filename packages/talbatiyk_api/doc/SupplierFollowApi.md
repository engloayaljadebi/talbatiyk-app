# talbatiyk_api.api.SupplierFollowApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**supplierFollowDestroy**](SupplierFollowApi.md#supplierfollowdestroy) | **DELETE** /businesses/{business}/follow | إلغاء متابعة المورد
[**supplierFollowShow**](SupplierFollowApi.md#supplierfollowshow) | **GET** /businesses/{business}/follow | حالة متابعة المستخدم الحالي للمورد
[**supplierFollowStore**](SupplierFollowApi.md#supplierfollowstore) | **POST** /businesses/{business}/follow | متابعة المورد


# **supplierFollowDestroy**
> SupplierFollowShow200Response supplierFollowDestroy(business)

إلغاء متابعة المورد

العملية idempotent؛ إلغاء متابعة غير موجودة لا يعتبر خطأ.

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getSupplierFollowApi();
final String business = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | The business ID

try {
    final response = api.supplierFollowDestroy(business);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupplierFollowApi->supplierFollowDestroy: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**| The business ID | 

### Return type

[**SupplierFollowShow200Response**](SupplierFollowShow200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **supplierFollowShow**
> SupplierFollowShow200Response supplierFollowShow(business)

حالة متابعة المستخدم الحالي للمورد

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getSupplierFollowApi();
final String business = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | The business ID

try {
    final response = api.supplierFollowShow(business);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupplierFollowApi->supplierFollowShow: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**| The business ID | 

### Return type

[**SupplierFollowShow200Response**](SupplierFollowShow200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **supplierFollowStore**
> SupplierFollowShow200Response supplierFollowStore(business)

متابعة المورد

العملية idempotent؛ تكرار الطلب لا ينشئ علاقة ثانية.

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getSupplierFollowApi();
final String business = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | The business ID

try {
    final response = api.supplierFollowStore(business);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupplierFollowApi->supplierFollowStore: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**| The business ID | 

### Return type

[**SupplierFollowShow200Response**](SupplierFollowShow200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

