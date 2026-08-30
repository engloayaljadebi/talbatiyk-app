//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/submit_supplier_order_response_request_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'submit_supplier_order_response_request.g.dart';

/// SubmitSupplierOrderResponseRequest
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class SubmitSupplierOrderResponseRequest implements Built<SubmitSupplierOrderResponseRequest, SubmitSupplierOrderResponseRequestBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<SubmitSupplierOrderResponseRequestItemsInner> get items;

  SubmitSupplierOrderResponseRequest._();

  factory SubmitSupplierOrderResponseRequest([void updates(SubmitSupplierOrderResponseRequestBuilder b)]) = _$SubmitSupplierOrderResponseRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubmitSupplierOrderResponseRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubmitSupplierOrderResponseRequest> get serializer => _$SubmitSupplierOrderResponseRequestSerializer();
}

class _$SubmitSupplierOrderResponseRequestSerializer implements PrimitiveSerializer<SubmitSupplierOrderResponseRequest> {
  @override
  final Iterable<Type> types = const [SubmitSupplierOrderResponseRequest, _$SubmitSupplierOrderResponseRequest];

  @override
  final String wireName = r'SubmitSupplierOrderResponseRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubmitSupplierOrderResponseRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(SubmitSupplierOrderResponseRequestItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SubmitSupplierOrderResponseRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubmitSupplierOrderResponseRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SubmitSupplierOrderResponseRequestItemsInner)]),
          ) as BuiltList<SubmitSupplierOrderResponseRequestItemsInner>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SubmitSupplierOrderResponseRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubmitSupplierOrderResponseRequestBuilder();
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

