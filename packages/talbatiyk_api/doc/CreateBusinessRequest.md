# talbatiyk_api.model.CreateBusinessRequest

## Load the model package
```dart
import 'package:talbatiyk_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** | ---------------------------------------------------------------- بيانات النشاط الأساسية ---------------------------------------------------------------- | 
**legalName** | **String** |  | [optional] 
**description** | **String** |  | [optional] 
**capabilities** | **BuiltList&lt;String&gt;** | ---------------------------------------------------------------- قدرات النشاط ---------------------------------------------------------------- مثال:  capabilities: - supplier - shop  لا نقبل قدرة متوقفة retired_at. | 
**location** | [**CreateBusinessRequestLocation**](CreateBusinessRequestLocation.md) |  | 
**contact** | [**CreateBusinessRequestContact**](CreateBusinessRequestContact.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


