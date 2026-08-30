//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fulfillment_status.g.dart';

class FulfillmentStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'confirmed')
  static const FulfillmentStatus confirmed = _$confirmed;
  @BuiltValueEnumConst(wireName: r'preparing')
  static const FulfillmentStatus preparing = _$preparing;
  @BuiltValueEnumConst(wireName: r'ready_for_delivery')
  static const FulfillmentStatus readyForDelivery = _$readyForDelivery;
  @BuiltValueEnumConst(wireName: r'out_for_delivery')
  static const FulfillmentStatus outForDelivery = _$outForDelivery;
  @BuiltValueEnumConst(wireName: r'delivered')
  static const FulfillmentStatus delivered = _$delivered;

  static Serializer<FulfillmentStatus> get serializer => _$fulfillmentStatusSerializer;

  const FulfillmentStatus._(String name): super(name);

  static BuiltSet<FulfillmentStatus> get values => _$values;
  static FulfillmentStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class FulfillmentStatusMixin = Object with _$FulfillmentStatusMixin;

