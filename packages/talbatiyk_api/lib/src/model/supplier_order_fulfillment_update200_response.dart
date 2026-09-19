//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/order_recipient_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_order_fulfillment_update200_response.g.dart';

/// SupplierOrderFulfillmentUpdate200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class SupplierOrderFulfillmentUpdate200Response implements Built<SupplierOrderFulfillmentUpdate200Response, SupplierOrderFulfillmentUpdate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OrderRecipientResource get data;

  SupplierOrderFulfillmentUpdate200Response._();

  factory SupplierOrderFulfillmentUpdate200Response([void updates(SupplierOrderFulfillmentUpdate200ResponseBuilder b)]) = _$SupplierOrderFulfillmentUpdate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierOrderFulfillmentUpdate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierOrderFulfillmentUpdate200Response> get serializer => _$SupplierOrderFulfillmentUpdate200ResponseSerializer();
}

class _$SupplierOrderFulfillmentUpdate200ResponseSerializer implements PrimitiveSerializer<SupplierOrderFulfillmentUpdate200Response> {
  @override
  final Iterable<Type> types = const [SupplierOrderFulfillmentUpdate200Response, _$SupplierOrderFulfillmentUpdate200Response];

  @override
  final String wireName = r'SupplierOrderFulfillmentUpdate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierOrderFulfillmentUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OrderRecipientResource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierOrderFulfillmentUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierOrderFulfillmentUpdate200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OrderRecipientResource),
          ) as OrderRecipientResource;
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
  SupplierOrderFulfillmentUpdate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierOrderFulfillmentUpdate200ResponseBuilder();
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

