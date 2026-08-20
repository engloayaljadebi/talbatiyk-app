//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_item_resource.g.dart';

/// OrderItemResource
///
/// Properties:
/// * [id]
/// * [productId]
/// * [productName]
/// * [unitPrice] - decimal cast ظپظٹ Eloquent ظٹط¹ظٹط¯ string ظ„ظ„ط­ظپط§ط¸ ط¹ظ„ظ‰ ط§ظ„ط¯ظ‚ط©.
/// * [quantity]
/// * [supplierId]
/// * [supplierName]
/// * [imageUrl]
@BuiltValue()
abstract class OrderItemResource implements Built<OrderItemResource, OrderItemResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'product_id')
  String get productId;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  /// decimal cast ظپظٹ Eloquent ظٹط¹ظٹط¯ string ظ„ظ„ط­ظپط§ط¸ ط¹ظ„ظ‰ ط§ظ„ط¯ظ‚ط©.
  @BuiltValueField(wireName: r'unit_price')
  String get unitPrice;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  @BuiltValueField(wireName: r'supplier_id')
  String get supplierId;

  @BuiltValueField(wireName: r'supplier_name')
  String get supplierName;

  @BuiltValueField(wireName: r'image_url')
  String? get imageUrl;

  OrderItemResource._();

  factory OrderItemResource([void updates(OrderItemResourceBuilder b)]) = _$OrderItemResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderItemResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderItemResource> get serializer => _$OrderItemResourceSerializer();
}

class _$OrderItemResourceSerializer implements PrimitiveSerializer<OrderItemResource> {
  @override
  final Iterable<Type> types = const [OrderItemResource, _$OrderItemResource];

  @override
  final String wireName = r'OrderItemResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderItemResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'product_id';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(String),
    );
    yield r'product_name';
    yield serializers.serialize(
      object.productName,
      specifiedType: const FullType(String),
    );
    yield r'unit_price';
    yield serializers.serialize(
      object.unitPrice,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
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
    yield r'image_url';
    yield object.imageUrl == null ? null : serializers.serialize(
      object.imageUrl,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderItemResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderItemResourceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.productId = valueDes;
          break;
        case r'product_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.productName = valueDes;
          break;
        case r'unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unitPrice = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
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
        case r'image_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.imageUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderItemResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderItemResourceBuilder();
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
