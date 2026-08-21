# talbatiyk_api.api.ProductApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**productIndex**](ProductApi.md#productindex) | **GET** /products | 


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

