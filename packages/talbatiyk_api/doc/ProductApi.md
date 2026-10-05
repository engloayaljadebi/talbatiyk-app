# talbatiyk_api.api.ProductApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**productBusinessIndex**](ProductApi.md#productbusinessindex) | **GET** /businesses/{business}/products | 
[**productDestroy**](ProductApi.md#productdestroy) | **DELETE** /businesses/{business}/products/{product} | 
[**productIndex**](ProductApi.md#productindex) | **GET** /products | 
[**productStore**](ProductApi.md#productstore) | **POST** /businesses/{business}/products | 
[**productUpdate**](ProductApi.md#productupdate) | **PUT** /businesses/{business}/products/{product} | 
[**productUpdateImage**](ProductApi.md#productupdateimage) | **POST** /businesses/{business}/products/{product}/image | 


# **productBusinessIndex**
> ProductIndex200Response productBusinessIndex(business, page, perPage)



### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getProductApi();
final String business = business_example; // String | 
final int page = 56; // int | 
final int perPage = 56; // int | 

try {
    final response = api.productBusinessIndex(business, page, perPage);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProductApi->productBusinessIndex: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **page** | **int**|  | [optional] 
 **perPage** | **int**|  | [optional] 

### Return type

[**ProductIndex200Response**](ProductIndex200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **productDestroy**
> productDestroy(business, product, expectedVersion)



### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getProductApi();
final String business = business_example; // String | 
final String product = product_example; // String | 
final int expectedVersion = 56; // int | 

try {
    api.productDestroy(business, product, expectedVersion);
} on DioException catch (e) {
    print('Exception when calling ProductApi->productDestroy: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **product** | **String**|  | 
 **expectedVersion** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **productIndex**
> ProductIndex200Response productIndex(page, perPage)



### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getProductApi();
final int page = 56; // int | 
final int perPage = 56; // int | 

try {
    final response = api.productIndex(page, perPage);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProductApi->productIndex: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | [optional] 
 **perPage** | **int**|  | [optional] 

### Return type

[**ProductIndex200Response**](ProductIndex200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **productStore**
> ProductStore201Response productStore(business, idempotencyKey, name, category, price, quantity, isAvailable, brand, description, image)



### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getProductApi();
final String business = business_example; // String | 
final String idempotencyKey = 550e8400-e29b-41d4-a716-446655440000; // String | Stable UUID reused for retries of the same logical product publication.
final String name = name_example; // String | 
final String category = category_example; // String | 
final num price = 8.14; // num | 
final int quantity = 56; // int | 
final bool isAvailable = true; // bool | 
final String brand = brand_example; // String | 
final String description = description_example; // String | 
final MultipartFile image = BINARY_DATA_HERE; // MultipartFile | Maximum file size: 5120 kilobytes.

try {
    final response = api.productStore(business, idempotencyKey, name, category, price, quantity, isAvailable, brand, description, image);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProductApi->productStore: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **idempotencyKey** | **String**| Stable UUID reused for retries of the same logical product publication. | 
 **name** | **String**|  | 
 **category** | **String**|  | 
 **price** | **num**|  | 
 **quantity** | **int**|  | 
 **isAvailable** | **bool**|  | 
 **brand** | **String**|  | [optional] 
 **description** | **String**|  | [optional] 
 **image** | **MultipartFile**| Maximum file size: 5120 kilobytes. | [optional] 

### Return type

[**ProductStore201Response**](ProductStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **productUpdate**
> ProductStore201Response productUpdate(business, product, updateProductRequest)



### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getProductApi();
final String business = business_example; // String | 
final String product = product_example; // String | 
final UpdateProductRequest updateProductRequest = ; // UpdateProductRequest | 

try {
    final response = api.productUpdate(business, product, updateProductRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProductApi->productUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **product** | **String**|  | 
 **updateProductRequest** | [**UpdateProductRequest**](UpdateProductRequest.md)|  | 

### Return type

[**ProductStore201Response**](ProductStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **productUpdateImage**
> ProductStore201Response productUpdateImage(business, product, expectedVersion, image)



### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getProductApi();
final String business = business_example; // String | 
final String product = product_example; // String | 
final int expectedVersion = 56; // int | 
final MultipartFile image = BINARY_DATA_HERE; // MultipartFile | Maximum file size: 5120 kilobytes.

try {
    final response = api.productUpdateImage(business, product, expectedVersion, image);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProductApi->productUpdateImage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | **String**|  | 
 **product** | **String**|  | 
 **expectedVersion** | **int**|  | 
 **image** | **MultipartFile**| Maximum file size: 5120 kilobytes. | 

### Return type

[**ProductStore201Response**](ProductStore201Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

