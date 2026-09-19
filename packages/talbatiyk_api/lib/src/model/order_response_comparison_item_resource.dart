//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/order_recipient_item_response_resource.dart';
import 'package:talbatiyk_api/src/model/order_response_comparison_selection_resource.dart';
import 'package:talbatiyk_api/src/model/order_response_comparison_item_resource_supplier.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_response_comparison_item_resource.g.dart';

/// OrderResponseComparisonItemResource
///
/// Properties:
/// * [id] 
/// * [productId] 
/// * [productName] 
/// * [requestedQuantity] 
/// * [orderUnitPrice] 
/// * [supplier] 
/// * [response] 
/// * [selection] 
@BuiltValue()
abstract class OrderResponseComparisonItemResource implements Built<OrderResponseComparisonItemResource, OrderResponseComparisonItemResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'product_id')
  String get productId;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  @BuiltValueField(wireName: r'requested_quantity')
  int get requestedQuantity;

  @BuiltValueField(wireName: r'order_unit_price')
  String get orderUnitPrice;

  @BuiltValueField(wireName: r'supplier')
  OrderResponseComparisonItemResourceSupplier get supplier;

  @BuiltValueField(wireName: r'response')
  OrderRecipientItemResponseResource? get response;

  @BuiltValueField(wireName: r'selection')
  OrderResponseComparisonSelectionResource? get selection;

  OrderResponseComparisonItemResource._();

  factory OrderResponseComparisonItemResource([void updates(OrderResponseComparisonItemResourceBuilder b)]) = _$OrderResponseComparisonItemResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderResponseComparisonItemResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderResponseComparisonItemResource> get serializer => _$OrderResponseComparisonItemResourceSerializer();
}

class _$OrderResponseComparisonItemResourceSerializer implements PrimitiveSerializer<OrderResponseComparisonItemResource> {
  @override
  final Iterable<Type> types = const [OrderResponseComparisonItemResource, _$OrderResponseComparisonItemResource];

  @override
  final String wireName = r'OrderResponseComparisonItemResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderResponseComparisonItemResource object, {
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
    yield r'requested_quantity';
    yield serializers.serialize(
      object.requestedQuantity,
      specifiedType: const FullType(int),
    );
    yield r'order_unit_price';
    yield serializers.serialize(
      object.orderUnitPrice,
      specifiedType: const FullType(String),
    );
    yield r'supplier';
    yield serializers.serialize(
      object.supplier,
      specifiedType: const FullType(OrderResponseComparisonItemResourceSupplier),
    );
    yield r'response';
    yield object.response == null ? null : serializers.serialize(
      object.response,
      specifiedType: const FullType.nullable(OrderRecipientItemResponseResource),
    );
    yield r'selection';
    yield object.selection == null ? null : serializers.serialize(
      object.selection,
      specifiedType: const FullType.nullable(OrderResponseComparisonSelectionResource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderResponseComparisonItemResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderResponseComparisonItemResourceBuilder result,
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
        case r'requested_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.requestedQuantity = valueDes;
          break;
        case r'order_unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderUnitPrice = valueDes;
          break;
        case r'supplier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OrderResponseComparisonItemResourceSupplier),
          ) as OrderResponseComparisonItemResourceSupplier;
          result.supplier.replace(valueDes);
          break;
        case r'response':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OrderRecipientItemResponseResource),
          ) as OrderRecipientItemResponseResource?;
          if (valueDes == null) continue;
          result.response.replace(valueDes);
          break;
        case r'selection':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OrderResponseComparisonSelectionResource),
          ) as OrderResponseComparisonSelectionResource?;
          if (valueDes == null) continue;
          result.selection.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderResponseComparisonItemResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderResponseComparisonItemResourceBuilder();
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

