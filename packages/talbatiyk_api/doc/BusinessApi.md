# talbatiyk_api.api.BusinessApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**businessIndex**](BusinessApi.md#businessindex) | **GET** /businesses | إرجاع جميع الأنشطة التي لدى المستخدم الحالي عضوية نشطة فيها
[**businessShow**](BusinessApi.md#businessshow) | **GET** /businesses/{business} | قراءة نشاط واحد بشرط أن تكون للمستخدم الحالي عضوية نشطة فيه
[**businessStore**](BusinessApi.md#businessstore) | **POST** /businesses | إنشاء نشاط تجاري جديد للمستخدم الحالي
[**businessUpdate**](BusinessApi.md#businessupdate) | **PATCH** /businesses/{business} | تعديل البيانات الأساسية لنشاط تجاري


# **businessIndex**
> BusinessIndex200Response businessIndex()

إرجاع جميع الأنشطة التي لدى المستخدم الحالي عضوية نشطة فيها

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessApi();

try {
    final response = api.businessIndex();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessApi->businessIndex: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BusinessIndex200Response**](BusinessIndex200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessShow**
> BusinessStore201Response businessShow(business)

قراءة نشاط واحد بشرط أن تكون للمستخدم الحالي عضوية نشطة فيه

عند عدم وجود النشاط أو عدم امتلاك العضوية سيعيد BusinessQueryService استجابة 404.

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessApi();
final String business = business_example; // String | 

try {
    final response = api.businessShow(business);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessApi->businessShow: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 

### Return type

[**BusinessStore201Response**](BusinessStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessStore**
> BusinessStore201Response businessStore(createBusinessRequest)

إنشاء نشاط تجاري جديد للمستخدم الحالي

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessApi();
final CreateBusinessRequest createBusinessRequest = ; // CreateBusinessRequest | 

try {
    final response = api.businessStore(createBusinessRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessApi->businessStore: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createBusinessRequest** | [**CreateBusinessRequest**](CreateBusinessRequest.md)|  | 

### Return type

[**BusinessStore201Response**](BusinessStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessUpdate**
> BusinessStore201Response businessUpdate(business, updateBusinessRequest)

تعديل البيانات الأساسية لنشاط تجاري

يسمح بالتعديل فقط للمستخدم الذي: - لديه عضوية active. - يحمل دور owner أو manager.  BusinessAccessService يتولى التحقق من الصلاحيات.

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessApi();
final String business = business_example; // String | 
final UpdateBusinessRequest updateBusinessRequest = ; // UpdateBusinessRequest | 

try {
    final response = api.businessUpdate(business, updateBusinessRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessApi->businessUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **updateBusinessRequest** | [**UpdateBusinessRequest**](UpdateBusinessRequest.md)|  | [optional] 

### Return type

[**BusinessStore201Response**](BusinessStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

