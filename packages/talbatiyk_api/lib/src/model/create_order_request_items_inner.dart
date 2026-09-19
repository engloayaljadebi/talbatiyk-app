//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_order_request_items_inner.g.dart';

/// CreateOrderRequestItemsInner
///
/// Properties:
/// * [productId] - Product existence is commercial state and must be validated after idempotency replay lookup inside OrderService.
/// * [quantity] 
/// * [expectedUnitPrice] - This is the price Flutter observed when the user confirmed. Laravel compares it with Product.price and never stores it as the authoritative order price.
/// * [expectedSupplierId] - This is a concurrency expectation, not the authoritative supplier. Laravel resolves the real supplier from Product.
@BuiltValue()
abstract class CreateOrderRequestItemsInner implements Built<CreateOrderRequestItemsInner, CreateOrderRequestItemsInnerBuilder> {
  /// Product existence is commercial state and must be validated after idempotency replay lookup inside OrderService.
  @BuiltValueField(wireName: r'product_id')
  String get productId;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  /// This is the price Flutter observed when the user confirmed. Laravel compares it with Product.price and never stores it as the authoritative order price.
  @BuiltValueField(wireName: r'expected_unit_price')
  num get expectedUnitPrice;

  /// This is a concurrency expectation, not the authoritative supplier. Laravel resolves the real supplier from Product.
  @BuiltValueField(wireName: r'expected_supplier_id')
  String get expectedSupplierId;

  CreateOrderRequestItemsInner._();

  factory CreateOrderRequestItemsInner([void updates(CreateOrderRequestItemsInnerBuilder b)]) = _$CreateOrderRequestItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateOrderRequestItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateOrderRequestItemsInner> get serializer => _$CreateOrderRequestItemsInnerSerializer();
}

class _$CreateOrderRequestItemsInnerSerializer implements PrimitiveSerializer<CreateOrderRequestItemsInner> {
  @override
  final Iterable<Type> types = const [CreateOrderRequestItemsInner, _$CreateOrderRequestItemsInner];

  @override
  final String wireName = r'CreateOrderRequestItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateOrderRequestItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product_id';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
    yield r'expected_unit_price';
    yield serializers.serialize(
      object.expectedUnitPrice,
      specifiedType: const FullType(num),
    );
    yield r'expected_supplier_id';
    yield serializers.serialize(
      object.expectedSupplierId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateOrderRequestItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateOrderRequestItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.productId = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        case r'expected_unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.expectedUnitPrice = valueDes;
          break;
        case r'expected_supplier_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expectedSupplierId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateOrderRequestItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateOrderRequestItemsInnerBuilder();
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

