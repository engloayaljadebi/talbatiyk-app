//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/order_recipient_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_order_index200_response.g.dart';

/// SupplierOrderIndex200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class SupplierOrderIndex200Response implements Built<SupplierOrderIndex200Response, SupplierOrderIndex200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OrderRecipientResource> get data;

  SupplierOrderIndex200Response._();

  factory SupplierOrderIndex200Response([void updates(SupplierOrderIndex200ResponseBuilder b)]) = _$SupplierOrderIndex200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierOrderIndex200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierOrderIndex200Response> get serializer => _$SupplierOrderIndex200ResponseSerializer();
}

class _$SupplierOrderIndex200ResponseSerializer implements PrimitiveSerializer<SupplierOrderIndex200Response> {
  @override
  final Iterable<Type> types = const [SupplierOrderIndex200Response, _$SupplierOrderIndex200Response];

  @override
  final String wireName = r'SupplierOrderIndex200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierOrderIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OrderRecipientResource)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierOrderIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierOrderIndex200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OrderRecipientResource)]),
          ) as BuiltList<OrderRecipientResource>;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierOrderIndex200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierOrderIndex200ResponseBuilder();
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

