//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/order_recipient_response_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_order_response_store201_response.g.dart';

/// SupplierOrderResponseStore201Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class SupplierOrderResponseStore201Response implements Built<SupplierOrderResponseStore201Response, SupplierOrderResponseStore201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OrderRecipientResponseResource get data;

  SupplierOrderResponseStore201Response._();

  factory SupplierOrderResponseStore201Response([void updates(SupplierOrderResponseStore201ResponseBuilder b)]) = _$SupplierOrderResponseStore201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierOrderResponseStore201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierOrderResponseStore201Response> get serializer => _$SupplierOrderResponseStore201ResponseSerializer();
}

class _$SupplierOrderResponseStore201ResponseSerializer implements PrimitiveSerializer<SupplierOrderResponseStore201Response> {
  @override
  final Iterable<Type> types = const [SupplierOrderResponseStore201Response, _$SupplierOrderResponseStore201Response];

  @override
  final String wireName = r'SupplierOrderResponseStore201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierOrderResponseStore201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OrderRecipientResponseResource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierOrderResponseStore201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierOrderResponseStore201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OrderRecipientResponseResource),
          ) as OrderRecipientResponseResource;
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
  SupplierOrderResponseStore201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierOrderResponseStore201ResponseBuilder();
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

