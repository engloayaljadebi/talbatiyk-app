// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_aggregate_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OrderAggregateStatus _$pendingResponses =
    const OrderAggregateStatus._('pendingResponses');
const OrderAggregateStatus _$responsesReceived =
    const OrderAggregateStatus._('responsesReceived');
const OrderAggregateStatus _$suppliersSelected =
    const OrderAggregateStatus._('suppliersSelected');
const OrderAggregateStatus _$inFulfillment =
    const OrderAggregateStatus._('inFulfillment');
const OrderAggregateStatus _$partiallyCompleted =
    const OrderAggregateStatus._('partiallyCompleted');
const OrderAggregateStatus _$completed =
    const OrderAggregateStatus._('completed');
const OrderAggregateStatus _$cancelled =
    const OrderAggregateStatus._('cancelled');
const OrderAggregateStatus _$expired = const OrderAggregateStatus._('expired');

OrderAggregateStatus _$valueOf(String name) {
  switch (name) {
    case 'pendingResponses':
      return _$pendingResponses;
    case 'responsesReceived':
      return _$responsesReceived;
    case 'suppliersSelected':
      return _$suppliersSelected;
    case 'inFulfillment':
      return _$inFulfillment;
    case 'partiallyCompleted':
      return _$partiallyCompleted;
    case 'completed':
      return _$completed;
    case 'cancelled':
      return _$cancelled;
    case 'expired':
      return _$expired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OrderAggregateStatus> _$values =
    BuiltSet<OrderAggregateStatus>(const <OrderAggregateStatus>[
  _$pendingResponses,
  _$responsesReceived,
  _$suppliersSelected,
  _$inFulfillment,
  _$partiallyCompleted,
  _$completed,
  _$cancelled,
  _$expired,
]);

class _$OrderAggregateStatusMeta {
  const _$OrderAggregateStatusMeta();
  OrderAggregateStatus get pendingResponses => _$pendingResponses;
  OrderAggregateStatus get responsesReceived => _$responsesReceived;
  OrderAggregateStatus get suppliersSelected => _$suppliersSelected;
  OrderAggregateStatus get inFulfillment => _$inFulfillment;
  OrderAggregateStatus get partiallyCompleted => _$partiallyCompleted;
  OrderAggregateStatus get completed => _$completed;
  OrderAggregateStatus get cancelled => _$cancelled;
  OrderAggregateStatus get expired => _$expired;
  OrderAggregateStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<OrderAggregateStatus> get values => _$values;
}

abstract class _$OrderAggregateStatusMixin {
  // ignore: non_constant_identifier_names
  _$OrderAggregateStatusMeta get OrderAggregateStatus =>
      const _$OrderAggregateStatusMeta();
}

Serializer<OrderAggregateStatus> _$orderAggregateStatusSerializer =
    _$OrderAggregateStatusSerializer();

class _$OrderAggregateStatusSerializer
    implements PrimitiveSerializer<OrderAggregateStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pendingResponses': 'pending_responses',
    'responsesReceived': 'responses_received',
    'suppliersSelected': 'suppliers_selected',
    'inFulfillment': 'in_fulfillment',
    'partiallyCompleted': 'partially_completed',
    'completed': 'completed',
    'cancelled': 'cancelled',
    'expired': 'expired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending_responses': 'pendingResponses',
    'responses_received': 'responsesReceived',
    'suppliers_selected': 'suppliersSelected',
    'in_fulfillment': 'inFulfillment',
    'partially_completed': 'partiallyCompleted',
    'completed': 'completed',
    'cancelled': 'cancelled',
    'expired': 'expired',
  };

  @override
  final Iterable<Type> types = const <Type>[OrderAggregateStatus];
  @override
  final String wireName = 'OrderAggregateStatus';

  @override
  Object serialize(Serializers serializers, OrderAggregateStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OrderAggregateStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OrderAggregateStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
