//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/availability_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_recipient_item_response_resource.g.dart';

/// OrderRecipientItemResponseResource
///
/// Properties:
/// * [id] 
/// * [orderRecipientItemId] 
/// * [requestedQuantity] 
/// * [availableQuantity] 
/// * [availabilityStatus] 
/// * [offeredUnitPrice] 
/// * [responseNotes] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class OrderRecipientItemResponseResource implements Built<OrderRecipientItemResponseResource, OrderRecipientItemResponseResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'order_recipient_item_id')
  String get orderRecipientItemId;

  @BuiltValueField(wireName: r'requested_quantity')
  int get requestedQuantity;

  @BuiltValueField(wireName: r'available_quantity')
  int get availableQuantity;

  @BuiltValueField(wireName: r'availability_status')
  AvailabilityStatus get availabilityStatus;
  // enum availabilityStatusEnum {  full,  partial,  unavailable,  };

  @BuiltValueField(wireName: r'offered_unit_price')
  String? get offeredUnitPrice;

  @BuiltValueField(wireName: r'response_notes')
  String? get responseNotes;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  OrderRecipientItemResponseResource._();

  factory OrderRecipientItemResponseResource([void updates(OrderRecipientItemResponseResourceBuilder b)]) = _$OrderRecipientItemResponseResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderRecipientItemResponseResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderRecipientItemResponseResource> get serializer => _$OrderRecipientItemResponseResourceSerializer();
}

class _$OrderRecipientItemResponseResourceSerializer implements PrimitiveSerializer<OrderRecipientItemResponseResource> {
  @override
  final Iterable<Type> types = const [OrderRecipientItemResponseResource, _$OrderRecipientItemResponseResource];

  @override
  final String wireName = r'OrderRecipientItemResponseResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderRecipientItemResponseResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'order_recipient_item_id';
    yield serializers.serialize(
      object.orderRecipientItemId,
      specifiedType: const FullType(String),
    );
    yield r'requested_quantity';
    yield serializers.serialize(
      object.requestedQuantity,
      specifiedType: const FullType(int),
    );
    yield r'available_quantity';
    yield serializers.serialize(
      object.availableQuantity,
      specifiedType: const FullType(int),
    );
    yield r'availability_status';
    yield serializers.serialize(
      object.availabilityStatus,
      specifiedType: const FullType(AvailabilityStatus),
    );
    yield r'offered_unit_price';
    yield object.offeredUnitPrice == null ? null : serializers.serialize(
      object.offeredUnitPrice,
      specifiedType: const FullType.nullable(String),
    );
    yield r'response_notes';
    yield object.responseNotes == null ? null : serializers.serialize(
      object.responseNotes,
      specifiedType: const FullType.nullable(String),
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
    OrderRecipientItemResponseResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderRecipientItemResponseResourceBuilder result,
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
        case r'order_recipient_item_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderRecipientItemId = valueDes;
          break;
        case r'requested_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.requestedQuantity = valueDes;
          break;
        case r'available_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.availableQuantity = valueDes;
          break;
        case r'availability_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AvailabilityStatus),
          ) as AvailabilityStatus;
          result.availabilityStatus = valueDes;
          break;
        case r'offered_unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.offeredUnitPrice = valueDes;
          break;
        case r'response_notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.responseNotes = valueDes;
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
  OrderRecipientItemResponseResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderRecipientItemResponseResourceBuilder();
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

