//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/business_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'business_index200_response.g.dart';

/// BusinessIndex200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class BusinessIndex200Response implements Built<BusinessIndex200Response, BusinessIndex200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<BusinessResource> get data;

  BusinessIndex200Response._();

  factory BusinessIndex200Response([void updates(BusinessIndex200ResponseBuilder b)]) = _$BusinessIndex200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusinessIndex200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusinessIndex200Response> get serializer => _$BusinessIndex200ResponseSerializer();
}

class _$BusinessIndex200ResponseSerializer implements PrimitiveSerializer<BusinessIndex200Response> {
  @override
  final Iterable<Type> types = const [BusinessIndex200Response, _$BusinessIndex200Response];

  @override
  final String wireName = r'BusinessIndex200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusinessIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(BusinessResource)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusinessIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BusinessIndex200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BusinessResource)]),
          ) as BuiltList<BusinessResource>;
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
  BusinessIndex200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusinessIndex200ResponseBuilder();
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

