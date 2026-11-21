//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_aggregate_status.g.dart';

class OrderAggregateStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending_responses')
  static const OrderAggregateStatus pendingResponses = _$pendingResponses;
  @BuiltValueEnumConst(wireName: r'responses_received')
  static const OrderAggregateStatus responsesReceived = _$responsesReceived;
  @BuiltValueEnumConst(wireName: r'suppliers_selected')
  static const OrderAggregateStatus suppliersSelected = _$suppliersSelected;
  @BuiltValueEnumConst(wireName: r'in_fulfillment')
  static const OrderAggregateStatus inFulfillment = _$inFulfillment;
  @BuiltValueEnumConst(wireName: r'partially_completed')
  static const OrderAggregateStatus partiallyCompleted = _$partiallyCompleted;
  @BuiltValueEnumConst(wireName: r'completed')
  static const OrderAggregateStatus completed = _$completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const OrderAggregateStatus cancelled = _$cancelled;
  @BuiltValueEnumConst(wireName: r'expired')
  static const OrderAggregateStatus expired = _$expired;

  static Serializer<OrderAggregateStatus> get serializer => _$orderAggregateStatusSerializer;

  const OrderAggregateStatus._(String name): super(name);

  static BuiltSet<OrderAggregateStatus> get values => _$values;
  static OrderAggregateStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class OrderAggregateStatusMixin = Object with _$OrderAggregateStatusMixin;

