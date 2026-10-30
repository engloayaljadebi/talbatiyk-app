# talbatiyk_api.api.AuthApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authBusinessApprovals**](AuthApi.md#authbusinessapprovals) | **GET** /auth/business-approvals | Review status for active business memberships of the authenticated user. The user account itself remains active while its business is reviewed. This endpoint never exposes reviewers, private notes, or other users&#39; data
[**authLogin**](AuthApi.md#authlogin) | **POST** /auth/login | تسجيل الدخول
[**authLogout**](AuthApi.md#authlogout) | **POST** /auth/logout | تسجيل خروج الجهاز الحالي فقط
[**authMe**](AuthApi.md#authme) | **GET** /auth/me | بيانات المستخدم الحالي
[**authRegister**](AuthApi.md#authregister) | **POST** /auth/register | إنشاء حساب جديد
[**authRegistrationCategories**](AuthApi.md#authregistrationcategories) | **GET** /auth/registration-categories | Public list of selectable categories for mobile registration
[**authUpdateProfile**](AuthApi.md#authupdateprofile) | **PATCH** /auth/me | Update the authenticated user&#39;s basic profile identity


# **authBusinessApprovals**
> AuthBusinessApprovals200Response authBusinessApprovals()

Review status for active business memberships of the authenticated user. The user account itself remains active while its business is reviewed. This endpoint never exposes reviewers, private notes, or other users' data

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getAuthApi();

try {
    final response = api.authBusinessApprovals();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authBusinessApprovals: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AuthBusinessApprovals200Response**](AuthBusinessApprovals200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authLogin**
> AuthLogin200Response authLogin(loginRequest)

تسجيل الدخول

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getAuthApi();
final LoginRequest loginRequest = ; // LoginRequest | 

try {
    final response = api.authLogin(loginRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authLogin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginRequest** | [**LoginRequest**](LoginRequest.md)|  | 

### Return type

[**AuthLogin200Response**](AuthLogin200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authLogout**
> AuthLogout200Response authLogout()

تسجيل خروج الجهاز الحالي فقط

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getAuthApi();

try {
    final response = api.authLogout();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authLogout: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AuthLogout200Response**](AuthLogout200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authMe**
> AuthMe200Response authMe()

بيانات المستخدم الحالي

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getAuthApi();

try {
    final response = api.authMe();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AuthMe200Response**](AuthMe200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRegister**
> AuthRegister201Response authRegister(registerRequest)

إنشاء حساب جديد

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getAuthApi();
final RegisterRequest registerRequest = ; // RegisterRequest | 

try {
    final response = api.authRegister(registerRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authRegister: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerRequest** | [**RegisterRequest**](RegisterRequest.md)|  | 

### Return type

[**AuthRegister201Response**](AuthRegister201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRegistrationCategories**
> AuthRegistrationCategories200Response authRegistrationCategories()

Public list of selectable categories for mobile registration

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getAuthApi();

try {
    final response = api.authRegistrationCategories();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authRegistrationCategories: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AuthRegistrationCategories200Response**](AuthRegistrationCategories200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authUpdateProfile**
> AuthMe200Response authUpdateProfile(updateProfileRequest)

Update the authenticated user's basic profile identity

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getAuthApi();
final UpdateProfileRequest updateProfileRequest = ; // UpdateProfileRequest | 

try {
    final response = api.authUpdateProfile(updateProfileRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authUpdateProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateProfileRequest** | [**UpdateProfileRequest**](UpdateProfileRequest.md)|  | [optional] 

### Return type

[**AuthMe200Response**](AuthMe200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

