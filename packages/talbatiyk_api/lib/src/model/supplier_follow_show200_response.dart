//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/supplier_follow_show200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_follow_show200_response.g.dart';

/// SupplierFollowShow200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class SupplierFollowShow200Response implements Built<SupplierFollowShow200Response, SupplierFollowShow200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  SupplierFollowShow200ResponseData get data;

  SupplierFollowShow200Response._();

  factory SupplierFollowShow200Response([void updates(SupplierFollowShow200ResponseBuilder b)]) = _$SupplierFollowShow200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierFollowShow200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierFollowShow200Response> get serializer => _$SupplierFollowShow200ResponseSerializer();
}

class _$SupplierFollowShow200ResponseSerializer implements PrimitiveSerializer<SupplierFollowShow200Response> {
  @override
  final Iterable<Type> types = const [SupplierFollowShow200Response, _$SupplierFollowShow200Response];

  @override
  final String wireName = r'SupplierFollowShow200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierFollowShow200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(SupplierFollowShow200ResponseData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierFollowShow200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierFollowShow200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SupplierFollowShow200ResponseData),
          ) as SupplierFollowShow200ResponseData;
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
  SupplierFollowShow200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierFollowShow200ResponseBuilder();
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

