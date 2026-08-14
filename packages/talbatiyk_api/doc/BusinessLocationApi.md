# talbatiyk_api.api.BusinessLocationApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**businessLocationDestroy**](BusinessLocationApi.md#businesslocationdestroy) | **DELETE** /businesses/{business}/locations/{location} | حذف موقع حذفًا منطقيًا
[**businessLocationIndex**](BusinessLocationApi.md#businesslocationindex) | **GET** /businesses/{business}/locations | عرض جميع مواقع النشاط
[**businessLocationSetPrimary**](BusinessLocationApi.md#businesslocationsetprimary) | **POST** /businesses/{business}/locations/{location}/primary | تعيين موقع باعتباره الموقع الرئيسي
[**businessLocationShow**](BusinessLocationApi.md#businesslocationshow) | **GET** /businesses/{business}/locations/{location} | عرض موقع واحد تابع للنشاط
[**businessLocationStore**](BusinessLocationApi.md#businesslocationstore) | **POST** /businesses/{business}/locations | إنشاء موقع جديد
[**businessLocationUpdate**](BusinessLocationApi.md#businesslocationupdate) | **PATCH** /businesses/{business}/locations/{location} | تعديل موقع موجود


# **businessLocationDestroy**
> businessLocationDestroy(business, location)

حذف موقع حذفًا منطقيًا

الموقع الرئيسي لا يمكن حذفه قبل تعيين موقع رئيسي آخر.

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessLocationApi();
final String business = business_example; // String | 
final String location = location_example; // String | 

try {
    api.businessLocationDestroy(business, location);
} on DioException catch (e) {
    print('Exception when calling BusinessLocationApi->businessLocationDestroy: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **location** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessLocationIndex**
> BusinessLocationIndex200Response businessLocationIndex(business)

عرض جميع مواقع النشاط

أي عضو active يستطيع القراءة.

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessLocationApi();
final String business = business_example; // String | 

try {
    final response = api.businessLocationIndex(business);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessLocationApi->businessLocationIndex: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 

### Return type

[**BusinessLocationIndex200Response**](BusinessLocationIndex200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessLocationSetPrimary**
> BusinessLocationStore201Response businessLocationSetPrimary(business, location)

تعيين موقع باعتباره الموقع الرئيسي

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessLocationApi();
final String business = business_example; // String | 
final String location = location_example; // String | 

try {
    final response = api.businessLocationSetPrimary(business, location);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessLocationApi->businessLocationSetPrimary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **location** | **String**|  | 

### Return type

[**BusinessLocationStore201Response**](BusinessLocationStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessLocationShow**
> BusinessLocationStore201Response businessLocationShow(business, location)

عرض موقع واحد تابع للنشاط

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessLocationApi();
final String business = business_example; // String | 
final String location = location_example; // String | 

try {
    final response = api.businessLocationShow(business, location);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessLocationApi->businessLocationShow: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **location** | **String**|  | 

### Return type

[**BusinessLocationStore201Response**](BusinessLocationStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessLocationStore**
> BusinessLocationStore201Response businessLocationStore(business, createBusinessLocationRequest)

إنشاء موقع جديد

owner أو manager فقط.

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessLocationApi();
final String business = business_example; // String | 
final CreateBusinessLocationRequest createBusinessLocationRequest = ; // CreateBusinessLocationRequest | 

try {
    final response = api.businessLocationStore(business, createBusinessLocationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessLocationApi->businessLocationStore: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **createBusinessLocationRequest** | [**CreateBusinessLocationRequest**](CreateBusinessLocationRequest.md)|  | 

### Return type

[**BusinessLocationStore201Response**](BusinessLocationStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessLocationUpdate**
> BusinessLocationStore201Response businessLocationUpdate(business, location, updateBusinessLocationRequest)

تعديل موقع موجود

owner أو manager فقط.

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessLocationApi();
final String business = business_example; // String | 
final String location = location_example; // String | 
final UpdateBusinessLocationRequest updateBusinessLocationRequest = ; // UpdateBusinessLocationRequest | 

try {
    final response = api.businessLocationUpdate(business, location, updateBusinessLocationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessLocationApi->businessLocationUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **location** | **String**|  | 
 **updateBusinessLocationRequest** | [**UpdateBusinessLocationRequest**](UpdateBusinessLocationRequest.md)|  | [optional] 

### Return type

[**BusinessLocationStore201Response**](BusinessLocationStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

