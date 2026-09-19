//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/order_recipient_response_resource.dart';
import 'package:talbatiyk_api/src/model/fulfillment_status.dart';
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/order_recipient_item_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_recipient_resource.g.dart';

/// OrderRecipientResource
///
/// Properties:
/// * [id] 
/// * [orderId] 
/// * [supplierId] 
/// * [supplierName] 
/// * [fulfillmentStatus] 
/// * [fulfillmentVersion] 
/// * [orderStatus] 
/// * [notes] 
/// * [items] 
/// * [response] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class OrderRecipientResource implements Built<OrderRecipientResource, OrderRecipientResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'order_id')
  String get orderId;

  @BuiltValueField(wireName: r'supplier_id')
  String get supplierId;

  @BuiltValueField(wireName: r'supplier_name')
  String get supplierName;

  @BuiltValueField(wireName: r'fulfillment_status')
  FulfillmentStatus? get fulfillmentStatus;
  // enum fulfillmentStatusEnum {  confirmed,  preparing,  ready_for_delivery,  out_for_delivery,  delivered,  };

  @BuiltValueField(wireName: r'fulfillment_version')
  int get fulfillmentVersion;

  @BuiltValueField(wireName: r'order_status')
  String get orderStatus;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'items')
  BuiltList<OrderRecipientItemResource> get items;

  @BuiltValueField(wireName: r'response')
  OrderRecipientResponseResource? get response;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  OrderRecipientResource._();

  factory OrderRecipientResource([void updates(OrderRecipientResourceBuilder b)]) = _$OrderRecipientResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderRecipientResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderRecipientResource> get serializer => _$OrderRecipientResourceSerializer();
}

class _$OrderRecipientResourceSerializer implements PrimitiveSerializer<OrderRecipientResource> {
  @override
  final Iterable<Type> types = const [OrderRecipientResource, _$OrderRecipientResource];

  @override
  final String wireName = r'OrderRecipientResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderRecipientResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'order_id';
    yield serializers.serialize(
      object.orderId,
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
    yield r'fulfillment_status';
    yield object.fulfillmentStatus == null ? null : serializers.serialize(
      object.fulfillmentStatus,
      specifiedType: const FullType.nullable(FulfillmentStatus),
    );
    yield r'fulfillment_version';
    yield serializers.serialize(
      object.fulfillmentVersion,
      specifiedType: const FullType(int),
    );
    yield r'order_status';
    yield serializers.serialize(
      object.orderStatus,
      specifiedType: const FullType(String),
    );
    yield r'notes';
    yield object.notes == null ? null : serializers.serialize(
      object.notes,
      specifiedType: const FullType.nullable(String),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(OrderRecipientItemResource)]),
    );
    if (object.response != null) {
      yield r'response';
      yield serializers.serialize(
        object.response,
        specifiedType: const FullType(OrderRecipientResponseResource),
      );
    }
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
    OrderRecipientResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderRecipientResourceBuilder result,
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
        case r'order_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderId = valueDes;
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
        case r'fulfillment_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(FulfillmentStatus),
          ) as FulfillmentStatus?;
          if (valueDes == null) continue;
          result.fulfillmentStatus = valueDes;
          break;
        case r'fulfillment_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.fulfillmentVersion = valueDes;
          break;
        case r'order_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderStatus = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OrderRecipientItemResource)]),
          ) as BuiltList<OrderRecipientItemResource>;
          result.items.replace(valueDes);
          break;
        case r'response':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OrderRecipientResponseResource),
          ) as OrderRecipientResponseResource;
          result.response.replace(valueDes);
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
  OrderRecipientResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderRecipientResourceBuilder();
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

