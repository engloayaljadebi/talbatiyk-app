//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_response_comparison_selection_resource.g.dart';

/// OrderResponseComparisonSelectionResource
///
/// Properties:
/// * [id] 
/// * [orderRecipientItemResponseId] 
/// * [selectedQuantity] 
@BuiltValue()
abstract class OrderResponseComparisonSelectionResource implements Built<OrderResponseComparisonSelectionResource, OrderResponseComparisonSelectionResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'order_recipient_item_response_id')
  String get orderRecipientItemResponseId;

  @BuiltValueField(wireName: r'selected_quantity')
  int get selectedQuantity;

  OrderResponseComparisonSelectionResource._();

  factory OrderResponseComparisonSelectionResource([void updates(OrderResponseComparisonSelectionResourceBuilder b)]) = _$OrderResponseComparisonSelectionResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderResponseComparisonSelectionResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderResponseComparisonSelectionResource> get serializer => _$OrderResponseComparisonSelectionResourceSerializer();
}

class _$OrderResponseComparisonSelectionResourceSerializer implements PrimitiveSerializer<OrderResponseComparisonSelectionResource> {
  @override
  final Iterable<Type> types = const [OrderResponseComparisonSelectionResource, _$OrderResponseComparisonSelectionResource];

  @override
  final String wireName = r'OrderResponseComparisonSelectionResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderResponseComparisonSelectionResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'order_recipient_item_response_id';
    yield serializers.serialize(
      object.orderRecipientItemResponseId,
      specifiedType: const FullType(String),
    );
    yield r'selected_quantity';
    yield serializers.serialize(
      object.selectedQuantity,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderResponseComparisonSelectionResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderResponseComparisonSelectionResourceBuilder result,
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
        case r'order_recipient_item_response_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderRecipientItemResponseId = valueDes;
          break;
        case r'selected_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.selectedQuantity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderResponseComparisonSelectionResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderResponseComparisonSelectionResourceBuilder();
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

