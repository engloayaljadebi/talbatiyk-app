# talbatiyk_api.api.NotificationApi

## Load the API package
```dart
import 'package:talbatiyk_api/api.dart';
```

All URIs are relative to *http://localhost/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**notificationIndex**](NotificationApi.md#notificationindex) | **GET** /notifications | 
[**notificationMarkAllRead**](NotificationApi.md#notificationmarkallread) | **POST** /notifications/read-all | 
[**notificationMarkRead**](NotificationApi.md#notificationmarkread) | **PATCH** /notifications/{notification}/read | Mark one notification owned by the authenticated user as read
[**notificationUnreadCount**](NotificationApi.md#notificationunreadcount) | **GET** /notifications/unread-count | 


# **notificationIndex**
> NotificationIndex200Response notificationIndex(page, perPage)



### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getNotificationApi();
final int page = 56; // int | 
final int perPage = 56; // int | 

try {
    final response = api.notificationIndex(page, perPage);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationApi->notificationIndex: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | [optional] 
 **perPage** | **int**|  | [optional] 

### Return type

[**NotificationIndex200Response**](NotificationIndex200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notificationMarkAllRead**
> NotificationMarkAllRead200Response notificationMarkAllRead()



### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getNotificationApi();

try {
    final response = api.notificationMarkAllRead();
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationApi->notificationMarkAllRead: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**NotificationMarkAllRead200Response**](NotificationMarkAllRead200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notificationMarkRead**
> NotificationMarkRead200Response notificationMarkRead(notification)

Mark one notification owned by the authenticated user as read

### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getNotificationApi();
final String notification = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Notification UUID.

try {
    final response = api.notificationMarkRead(notification);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationApi->notificationMarkRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **notification** | **String**| Notification UUID. | 

### Return type

[**NotificationMarkRead200Response**](NotificationMarkRead200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notificationUnreadCount**
> NotificationUnreadCount200Response notificationUnreadCount()



### Example
```dart
import 'package:talbatiyk_api/api.dart';

final api = TalbatiykApi().getNotificationApi();

try {
    final response = api.notificationUnreadCount();
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationApi->notificationUnreadCount: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**NotificationUnreadCount200Response**](NotificationUnreadCount200Response.md)

### Authorization

[http](../README.md#http)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

