# talbatiyk_api.model.BusinessResource

## Load the model package
```dart
import 'package:talbatiyk_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**name** | **String** |  | 
**legalName** | **String** |  | 
**description** | **String** |  | 
**status** | **String** |  | 
**capabilities** | [**BuiltList&lt;JsonObject&gt;**](JsonObject.md) | قدرات النشاط: supplier shop | [optional] 
**primaryLocation** | [**BusinessLocationResource**](BusinessLocationResource.md) | الموقع الرئيسي فقط في هذه الاستجابة. قائمة جميع الفروع سيكون لها Endpoint مستقل لاحقًا. | 
**primaryContact** | [**BusinessContactResource**](BusinessContactResource.md) | وسيلة الاتصال الرئيسية. | 
**membership** | [**BusinessResourceMembership**](BusinessResourceMembership.md) |  | [optional] 
**createdAt** | **String** |  | 
**updatedAt** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


