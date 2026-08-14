# talbatiyk_api.model.CreateBusinessRequestLocation

## Load the model package
```dart
import 'package:talbatiyk_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** |  | 
**type** | **String** |  | 
**timezone** | **String** | Laravel يتحقق أن القيمة اسم Timezone صالح. مثال: Asia/Aden | 
**countryCode** | **String** | ISO 3166-1 alpha-2 اليمن: YE | 
**administrativeArea** | **String** |  | [optional] 
**locality** | **String** |  | [optional] 
**district** | **String** |  | [optional] 
**streetAddress** | **String** |  | [optional] 
**addressNotes** | **String** |  | [optional] 
**latitude** | **num** | إذا تم إرسال أحد الإحداثيين يجب إرسال الآخر أيضًا. PostgreSQL لديه كذلك CHECK constraints، لكننا نرفض الخطأ مبكرًا من طبقة API. | [optional] 
**longitude** | **num** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


