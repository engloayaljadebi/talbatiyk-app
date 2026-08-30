//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_response_comparison_item_resource_supplier.g.dart';

/// OrderResponseComparisonItemResourceSupplier
///
/// Properties:
/// * [recipientId] 
/// * [supplierId] 
/// * [supplierName] 
@BuiltValue()
abstract class OrderResponseComparisonItemResourceSupplier implements Built<OrderResponseComparisonItemResourceSupplier, OrderResponseComparisonItemResourceSupplierBuilder> {
  @BuiltValueField(wireName: r'recipient_id')
  String get recipientId;

  @BuiltValueField(wireName: r'supplier_id')
  String get supplierId;

  @BuiltValueField(wireName: r'supplier_name')
  String get supplierName;

  OrderResponseComparisonItemResourceSupplier._();

  factory OrderResponseComparisonItemResourceSupplier([void updates(OrderResponseComparisonItemResourceSupplierBuilder b)]) = _$OrderResponseComparisonItemResourceSupplier;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderResponseComparisonItemResourceSupplierBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderResponseComparisonItemResourceSupplier> get serializer => _$OrderResponseComparisonItemResourceSupplierSerializer();
}

class _$OrderResponseComparisonItemResourceSupplierSerializer implements PrimitiveSerializer<OrderResponseComparisonItemResourceSupplier> {
  @override
  final Iterable<Type> types = const [OrderResponseComparisonItemResourceSupplier, _$OrderResponseComparisonItemResourceSupplier];

  @override
  final String wireName = r'OrderResponseComparisonItemResourceSupplier';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderResponseComparisonItemResourceSupplier object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'recipient_id';
    yield serializers.serialize(
      object.recipientId,
      specifiedType: const FullType(String),
    );
    yield r'supplier_id';
    yield serializers.serialize(
      object.supplierId,
      specifiedType: const FullType(String),
    );
    yield r'supplier_name';
    yield serializers.serialize(
      object.supplierName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderResponseComparisonItemResourceSupplier object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderResponseComparisonItemResourceSupplierBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'recipient_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.recipientId = valueDes;
          break;
        case r'supplier_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.supplierId = valueDes;
          break;
        case r'supplier_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.supplierName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderResponseComparisonItemResourceSupplier deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderResponseComparisonItemResourceSupplierBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

