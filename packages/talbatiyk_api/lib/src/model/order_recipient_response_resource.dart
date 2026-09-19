//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/order_recipient_item_response_resource.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_recipient_response_resource.g.dart';

/// OrderRecipientResponseResource
///
/// Properties:
/// * [id] 
/// * [orderRecipientId] 
/// * [items] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class OrderRecipientResponseResource implements Built<OrderRecipientResponseResource, OrderRecipientResponseResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'order_recipient_id')
  String get orderRecipientId;

  @BuiltValueField(wireName: r'items')
  BuiltList<OrderRecipientItemResponseResource> get items;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  OrderRecipientResponseResource._();

  factory OrderRecipientResponseResource([void updates(OrderRecipientResponseResourceBuilder b)]) = _$OrderRecipientResponseResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderRecipientResponseResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderRecipientResponseResource> get serializer => _$OrderRecipientResponseResourceSerializer();
}

class _$OrderRecipientResponseResourceSerializer implements PrimitiveSerializer<OrderRecipientResponseResource> {
  @override
  final Iterable<Type> types = const [OrderRecipientResponseResource, _$OrderRecipientResponseResource];

  @override
  final String wireName = r'OrderRecipientResponseResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderRecipientResponseResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'order_recipient_id';
    yield serializers.serialize(
      object.orderRecipientId,
      specifiedType: const FullType(String),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(OrderRecipientItemResponseResource)]),
    );
    yield r'created_at';
    yield object.createdAt == null ? null : serializers.serialize(
      object.createdAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'updated_at';
    yield object.updatedAt == null ? null : serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderRecipientResponseResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderRecipientResponseResourceBuilder result,
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
        case r'order_recipient_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderRecipientId = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OrderRecipientItemResponseResource)]),
          ) as BuiltList<OrderRecipientItemResponseResource>;
          result.items.replace(valueDes);
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderRecipientResponseResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderRecipientResponseResourceBuilder();
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

