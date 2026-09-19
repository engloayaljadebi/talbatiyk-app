// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fulfillment_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FulfillmentStatus _$confirmed = const FulfillmentStatus._('confirmed');
const FulfillmentStatus _$preparing = const FulfillmentStatus._('preparing');
const FulfillmentStatus _$readyForDelivery =
    const FulfillmentStatus._('readyForDelivery');
const FulfillmentStatus _$outForDelivery =
    const FulfillmentStatus._('outForDelivery');
const FulfillmentStatus _$delivered = const FulfillmentStatus._('delivered');

FulfillmentStatus _$valueOf(String name) {
  switch (name) {
    case 'confirmed':
      return _$confirmed;
    case 'preparing':
      return _$preparing;
    case 'readyForDelivery':
      return _$readyForDelivery;
    case 'outForDelivery':
      return _$outForDelivery;
    case 'delivered':
      return _$delivered;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FulfillmentStatus> _$values =
    BuiltSet<FulfillmentStatus>(const <FulfillmentStatus>[
  _$confirmed,
  _$preparing,
  _$readyForDelivery,
  _$outForDelivery,
  _$delivered,
]);

class _$FulfillmentStatusMeta {
  const _$FulfillmentStatusMeta();
  FulfillmentStatus get confirmed => _$confirmed;
  FulfillmentStatus get preparing => _$preparing;
  FulfillmentStatus get readyForDelivery => _$readyForDelivery;
  FulfillmentStatus get outForDelivery => _$outForDelivery;
  FulfillmentStatus get delivered => _$delivered;
  FulfillmentStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<FulfillmentStatus> get values => _$values;
}

abstract class _$FulfillmentStatusMixin {
  // ignore: non_constant_identifier_names
  _$FulfillmentStatusMeta get FulfillmentStatus =>
      const _$FulfillmentStatusMeta();
}

Serializer<FulfillmentStatus> _$fulfillmentStatusSerializer =
    _$FulfillmentStatusSerializer();

class _$FulfillmentStatusSerializer
    implements PrimitiveSerializer<FulfillmentStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'confirmed': 'confirmed',
    'preparing': 'preparing',
    'readyForDelivery': 'ready_for_delivery',
    'outForDelivery': 'out_for_delivery',
    'delivered': 'delivered',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'confirmed': 'confirmed',
    'preparing': 'preparing',
    'ready_for_delivery': 'readyForDelivery',
    'out_for_delivery': 'outForDelivery',
    'delivered': 'delivered',
  };

  @override
  final Iterable<Type> types = const <Type>[FulfillmentStatus];
  @override
  final String wireName = 'FulfillmentStatus';

  @override
  Object serialize(Serializers serializers, FulfillmentStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FulfillmentStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FulfillmentStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
