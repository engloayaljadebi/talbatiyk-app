//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/order_item_resource.dart';
import 'package:talbatiyk_api/src/model/order_aggregate_status.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_resource.g.dart';

/// OrderResource
///
/// Properties:
/// * [id] 
/// * [status] 
/// * [aggregateStatus] 
/// * [notes] 
/// * [items] - OrderService يحمّل items قبل إنشاء الـ Resource، لذلك العناصر جزء إلزامي من Create Order response.
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class OrderResource implements Built<OrderResource, OrderResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'aggregate_status')
  OrderAggregateStatus get aggregateStatus;
  // enum aggregateStatusEnum {  pending_responses,  responses_received,  suppliers_selected,  in_fulfillment,  partially_completed,  completed,  cancelled,  expired,  };

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// OrderService يحمّل items قبل إنشاء الـ Resource، لذلك العناصر جزء إلزامي من Create Order response.
  @BuiltValueField(wireName: r'items')
  BuiltList<OrderItemResource> get items;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  OrderResource._();

  factory OrderResource([void updates(OrderResourceBuilder b)]) = _$OrderResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderResource> get serializer => _$OrderResourceSerializer();
}

class _$OrderResourceSerializer implements PrimitiveSerializer<OrderResource> {
  @override
  final Iterable<Type> types = const [OrderResource, _$OrderResource];

  @override
  final String wireName = r'OrderResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'aggregate_status';
    yield serializers.serialize(
      object.aggregateStatus,
      specifiedType: const FullType(OrderAggregateStatus),
    );
    yield r'notes';
    yield object.notes == null ? null : serializers.serialize(
      object.notes,
      specifiedType: const FullType.nullable(String),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(OrderItemResource)]),
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
    OrderResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderResourceBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'aggregate_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OrderAggregateStatus),
          ) as OrderAggregateStatus;
          result.aggregateStatus = valueDes;
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
            specifiedType: const FullType(BuiltList, [FullType(OrderItemResource)]),
          ) as BuiltList<OrderItemResource>;
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
  OrderResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderResourceBuilder();
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

