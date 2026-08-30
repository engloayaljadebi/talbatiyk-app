# talbatiyk_api.model.OrderResource

## Load the model package
```dart
import 'package:talbatiyk_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**status** | **String** |  | 
**aggregateStatus** | [**OrderAggregateStatus**](OrderAggregateStatus.md) |  | 
**notes** | **String** |  | 
**items** | [**BuiltList&lt;OrderItemResource&gt;**](OrderItemResource.md) | OrderService يحمّل items قبل إنشاء الـ Resource، لذلك العناصر جزء إلزامي من Create Order response. | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


