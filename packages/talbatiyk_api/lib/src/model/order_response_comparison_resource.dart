//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/order_aggregate_status.dart';
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/order_response_comparison_item_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_response_comparison_resource.g.dart';

/// OrderResponseComparisonResource
///
/// Properties:
/// * [id] 
/// * [version] 
/// * [status] 
/// * [aggregateStatus] 
/// * [notes] 
/// * [items] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class OrderResponseComparisonResource implements Built<OrderResponseComparisonResource, OrderResponseComparisonResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'aggregate_status')
  OrderAggregateStatus get aggregateStatus;
  // enum aggregateStatusEnum {  pending_responses,  responses_received,  suppliers_selected,  in_fulfillment,  partially_completed,  completed,  cancelled,  expired,  };

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'items')
  BuiltList<OrderResponseComparisonItemResource> get items;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  OrderResponseComparisonResource._();

  factory OrderResponseComparisonResource([void updates(OrderResponseComparisonResourceBuilder b)]) = _$OrderResponseComparisonResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderResponseComparisonResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderResponseComparisonResource> get serializer => _$OrderResponseComparisonResourceSerializer();
}

class _$OrderResponseComparisonResourceSerializer implements PrimitiveSerializer<OrderResponseComparisonResource> {
  @override
  final Iterable<Type> types = const [OrderResponseComparisonResource, _$OrderResponseComparisonResource];

  @override
  final String wireName = r'OrderResponseComparisonResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderResponseComparisonResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
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
      specifiedType: const FullType(BuiltList, [FullType(OrderResponseComparisonItemResource)]),
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
    OrderResponseComparisonResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderResponseComparisonResourceBuilder result,
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
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
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
            specifiedType: const FullType(BuiltList, [FullType(OrderResponseComparisonItemResource)]),
          ) as BuiltList<OrderResponseComparisonItemResource>;
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
  OrderResponseComparisonResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderResponseComparisonResourceBuilder();
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

