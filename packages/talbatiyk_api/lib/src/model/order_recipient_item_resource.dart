//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_recipient_item_resource.g.dart';

/// OrderRecipientItemResource
///
/// Properties:
/// * [id] 
/// * [productId] 
/// * [productName] 
/// * [unitPrice] 
/// * [requestedQuantity] 
/// * [selectedQuantity] 
/// * [imageUrl] 
@BuiltValue()
abstract class OrderRecipientItemResource implements Built<OrderRecipientItemResource, OrderRecipientItemResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'product_id')
  String get productId;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  @BuiltValueField(wireName: r'unit_price')
  String get unitPrice;

  @BuiltValueField(wireName: r'requested_quantity')
  int get requestedQuantity;

  @BuiltValueField(wireName: r'selected_quantity')
  int? get selectedQuantity;

  @BuiltValueField(wireName: r'image_url')
  String? get imageUrl;

  OrderRecipientItemResource._();

  factory OrderRecipientItemResource([void updates(OrderRecipientItemResourceBuilder b)]) = _$OrderRecipientItemResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderRecipientItemResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderRecipientItemResource> get serializer => _$OrderRecipientItemResourceSerializer();
}

class _$OrderRecipientItemResourceSerializer implements PrimitiveSerializer<OrderRecipientItemResource> {
  @override
  final Iterable<Type> types = const [OrderRecipientItemResource, _$OrderRecipientItemResource];

  @override
  final String wireName = r'OrderRecipientItemResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderRecipientItemResource object, {
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
    yield r'requested_quantity';
    yield serializers.serialize(
      object.requestedQuantity,
      specifiedType: const FullType(int),
    );
    yield r'selected_quantity';
    yield object.selectedQuantity == null ? null : serializers.serialize(
      object.selectedQuantity,
      specifiedType: const FullType.nullable(int),
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
    OrderRecipientItemResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderRecipientItemResourceBuilder result,
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
        case r'requested_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.requestedQuantity = valueDes;
          break;
        case r'selected_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.selectedQuantity = valueDes;
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
  OrderRecipientItemResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderRecipientItemResourceBuilder();
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

