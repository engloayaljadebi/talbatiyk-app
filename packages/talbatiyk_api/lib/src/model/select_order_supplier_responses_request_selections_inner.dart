//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'select_order_supplier_responses_request_selections_inner.g.dart';

/// SelectOrderSupplierResponsesRequestSelectionsInner
///
/// Properties:
/// * [orderRecipientItemResponseId] 
/// * [selectedQuantity] 
@BuiltValue()
abstract class SelectOrderSupplierResponsesRequestSelectionsInner implements Built<SelectOrderSupplierResponsesRequestSelectionsInner, SelectOrderSupplierResponsesRequestSelectionsInnerBuilder> {
  @BuiltValueField(wireName: r'order_recipient_item_response_id')
  String get orderRecipientItemResponseId;

  @BuiltValueField(wireName: r'selected_quantity')
  int get selectedQuantity;

  SelectOrderSupplierResponsesRequestSelectionsInner._();

  factory SelectOrderSupplierResponsesRequestSelectionsInner([void updates(SelectOrderSupplierResponsesRequestSelectionsInnerBuilder b)]) = _$SelectOrderSupplierResponsesRequestSelectionsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SelectOrderSupplierResponsesRequestSelectionsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SelectOrderSupplierResponsesRequestSelectionsInner> get serializer => _$SelectOrderSupplierResponsesRequestSelectionsInnerSerializer();
}

class _$SelectOrderSupplierResponsesRequestSelectionsInnerSerializer implements PrimitiveSerializer<SelectOrderSupplierResponsesRequestSelectionsInner> {
  @override
  final Iterable<Type> types = const [SelectOrderSupplierResponsesRequestSelectionsInner, _$SelectOrderSupplierResponsesRequestSelectionsInner];

  @override
  final String wireName = r'SelectOrderSupplierResponsesRequestSelectionsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SelectOrderSupplierResponsesRequestSelectionsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    SelectOrderSupplierResponsesRequestSelectionsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SelectOrderSupplierResponsesRequestSelectionsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  SelectOrderSupplierResponsesRequestSelectionsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SelectOrderSupplierResponsesRequestSelectionsInnerBuilder();
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

