# talbatiyk_api.api.BusinessContactApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**businessContactDestroyBusiness**](BusinessContactApi.md#businesscontactdestroybusiness) | **DELETE** /businesses/{business}/contacts/{contact} | حذف وسيلة اتصال عامة
[**businessContactDestroyLocation**](BusinessContactApi.md#businesscontactdestroylocation) | **DELETE** /businesses/{business}/locations/{location}/contacts/{contact} | حذف وسيلة اتصال خاصة بفرع
[**businessContactIndexBusiness**](BusinessContactApi.md#businesscontactindexbusiness) | **GET** /businesses/{business}/contacts | عرض وسائل الاتصال العامة للنشاط
[**businessContactIndexLocation**](BusinessContactApi.md#businesscontactindexlocation) | **GET** /businesses/{business}/locations/{location}/contacts | عرض وسائل الاتصال الخاصة بفرع
[**businessContactSetPrimaryBusiness**](BusinessContactApi.md#businesscontactsetprimarybusiness) | **POST** /businesses/{business}/contacts/{contact}/primary | تعيين وسيلة اتصال عامة كوسيلة رئيسية من نوعها
[**businessContactSetPrimaryLocation**](BusinessContactApi.md#businesscontactsetprimarylocation) | **POST** /businesses/{business}/locations/{location}/contacts/{contact}/primary | تعيين وسيلة اتصال فرع كوسيلة رئيسية من نوعها
[**businessContactShowBusiness**](BusinessContactApi.md#businesscontactshowbusiness) | **GET** /businesses/{business}/contacts/{contact} | عرض وسيلة اتصال عامة واحدة
[**businessContactShowLocation**](BusinessContactApi.md#businesscontactshowlocation) | **GET** /businesses/{business}/locations/{location}/contacts/{contact} | عرض وسيلة اتصال خاصة بفرع
[**businessContactStoreBusiness**](BusinessContactApi.md#businesscontactstorebusiness) | **POST** /businesses/{business}/contacts | إنشاء وسيلة اتصال عامة
[**businessContactStoreLocation**](BusinessContactApi.md#businesscontactstorelocation) | **POST** /businesses/{business}/locations/{location}/contacts | إنشاء وسيلة اتصال خاصة بفرع
[**businessContactUpdateBusiness**](BusinessContactApi.md#businesscontactupdatebusiness) | **PATCH** /businesses/{business}/contacts/{contact} | تعديل وسيلة اتصال عامة
[**businessContactUpdateLocation**](BusinessContactApi.md#businesscontactupdatelocation) | **PATCH** /businesses/{business}/locations/{location}/contacts/{contact} | تعديل وسيلة اتصال خاصة بفرع


# **businessContactDestroyBusiness**
> businessContactDestroyBusiness(business, contact)

حذف وسيلة اتصال عامة

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 
final String contact = contact_example; // String | 

try {
    api.businessContactDestroyBusiness(business, contact);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactDestroyBusiness: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **contact** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessContactDestroyLocation**
> businessContactDestroyLocation(business, location, contact)

حذف وسيلة اتصال خاصة بفرع

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 
final String location = location_example; // String | 
final String contact = contact_example; // String | 

try {
    api.businessContactDestroyLocation(business, location, contact);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactDestroyLocation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **location** | **String**|  | 
 **contact** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessContactIndexBusiness**
> BusinessContactIndexBusiness200Response businessContactIndexBusiness(business)

عرض وسائل الاتصال العامة للنشاط

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 

try {
    final response = api.businessContactIndexBusiness(business);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactIndexBusiness: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 

### Return type

[**BusinessContactIndexBusiness200Response**](BusinessContactIndexBusiness200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessContactIndexLocation**
> BusinessContactIndexBusiness200Response businessContactIndexLocation(business, location)

عرض وسائل الاتصال الخاصة بفرع

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 
final String location = location_example; // String | 

try {
    final response = api.businessContactIndexLocation(business, location);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactIndexLocation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **location** | **String**|  | 

### Return type

[**BusinessContactIndexBusiness200Response**](BusinessContactIndexBusiness200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessContactSetPrimaryBusiness**
> BusinessContactStoreBusiness201Response businessContactSetPrimaryBusiness(business, contact)

تعيين وسيلة اتصال عامة كوسيلة رئيسية من نوعها

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 
final String contact = contact_example; // String | 

try {
    final response = api.businessContactSetPrimaryBusiness(business, contact);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactSetPrimaryBusiness: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **contact** | **String**|  | 

### Return type

[**BusinessContactStoreBusiness201Response**](BusinessContactStoreBusiness201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessContactSetPrimaryLocation**
> BusinessContactStoreBusiness201Response businessContactSetPrimaryLocation(business, location, contact)

تعيين وسيلة اتصال فرع كوسيلة رئيسية من نوعها

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 
final String location = location_example; // String | 
final String contact = contact_example; // String | 

try {
    final response = api.businessContactSetPrimaryLocation(business, location, contact);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactSetPrimaryLocation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **location** | **String**|  | 
 **contact** | **String**|  | 

### Return type

[**BusinessContactStoreBusiness201Response**](BusinessContactStoreBusiness201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessContactShowBusiness**
> BusinessContactStoreBusiness201Response businessContactShowBusiness(business, contact)

عرض وسيلة اتصال عامة واحدة

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 
final String contact = contact_example; // String | 

try {
    final response = api.businessContactShowBusiness(business, contact);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactShowBusiness: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **contact** | **String**|  | 

### Return type

[**BusinessContactStoreBusiness201Response**](BusinessContactStoreBusiness201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessContactShowLocation**
> BusinessContactStoreBusiness201Response businessContactShowLocation(business, location, contact)

عرض وسيلة اتصال خاصة بفرع

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 
final String location = location_example; // String | 
final String contact = contact_example; // String | 

try {
    final response = api.businessContactShowLocation(business, location, contact);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactShowLocation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **location** | **String**|  | 
 **contact** | **String**|  | 

### Return type

[**BusinessContactStoreBusiness201Response**](BusinessContactStoreBusiness201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessContactStoreBusiness**
> BusinessContactStoreBusiness201Response businessContactStoreBusiness(business, createBusinessContactRequest)

إنشاء وسيلة اتصال عامة

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 
final CreateBusinessContactRequest createBusinessContactRequest = ; // CreateBusinessContactRequest | 

try {
    final response = api.businessContactStoreBusiness(business, createBusinessContactRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactStoreBusiness: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **createBusinessContactRequest** | [**CreateBusinessContactRequest**](CreateBusinessContactRequest.md)|  | 

### Return type

[**BusinessContactStoreBusiness201Response**](BusinessContactStoreBusiness201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessContactStoreLocation**
> BusinessContactStoreBusiness201Response businessContactStoreLocation(business, location, createBusinessContactRequest)

إنشاء وسيلة اتصال خاصة بفرع

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 
final String location = location_example; // String | 
final CreateBusinessContactRequest createBusinessContactRequest = ; // CreateBusinessContactRequest | 

try {
    final response = api.businessContactStoreLocation(business, location, createBusinessContactRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactStoreLocation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **location** | **String**|  | 
 **createBusinessContactRequest** | [**CreateBusinessContactRequest**](CreateBusinessContactRequest.md)|  | 

### Return type

[**BusinessContactStoreBusiness201Response**](BusinessContactStoreBusiness201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessContactUpdateBusiness**
> BusinessContactStoreBusiness201Response businessContactUpdateBusiness(business, contact, updateBusinessContactRequest)

تعديل وسيلة اتصال عامة

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 
final String contact = contact_example; // String | 
final UpdateBusinessContactRequest updateBusinessContactRequest = ; // UpdateBusinessContactRequest | 

try {
    final response = api.businessContactUpdateBusiness(business, contact, updateBusinessContactRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactUpdateBusiness: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **contact** | **String**|  | 
 **updateBusinessContactRequest** | [**UpdateBusinessContactRequest**](UpdateBusinessContactRequest.md)|  | [optional] 

### Return type

[**BusinessContactStoreBusiness201Response**](BusinessContactStoreBusiness201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **businessContactUpdateLocation**
> BusinessContactStoreBusiness201Response businessContactUpdateLocation(business, location, contact, updateBusinessContactRequest)

تعديل وسيلة اتصال خاصة بفرع

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getBusinessContactApi();
final String business = business_example; // String | 
final String location = location_example; // String | 
final String contact = contact_example; // String | 
final UpdateBusinessContactRequest updateBusinessContactRequest = ; // UpdateBusinessContactRequest | 

try {
    final response = api.businessContactUpdateLocation(business, location, contact, updateBusinessContactRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BusinessContactApi->businessContactUpdateLocation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **location** | **String**|  | 
 **contact** | **String**|  | 
 **updateBusinessContactRequest** | [**UpdateBusinessContactRequest**](UpdateBusinessContactRequest.md)|  | [optional] 

### Return type

[**BusinessContactStoreBusiness201Response**](BusinessContactStoreBusiness201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

