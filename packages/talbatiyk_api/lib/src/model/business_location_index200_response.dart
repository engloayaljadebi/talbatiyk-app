//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/business_location_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'business_location_index200_response.g.dart';

/// BusinessLocationIndex200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class BusinessLocationIndex200Response implements Built<BusinessLocationIndex200Response, BusinessLocationIndex200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<BusinessLocationResource> get data;

  BusinessLocationIndex200Response._();

  factory BusinessLocationIndex200Response([void updates(BusinessLocationIndex200ResponseBuilder b)]) = _$BusinessLocationIndex200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusinessLocationIndex200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusinessLocationIndex200Response> get serializer => _$BusinessLocationIndex200ResponseSerializer();
}

class _$BusinessLocationIndex200ResponseSerializer implements PrimitiveSerializer<BusinessLocationIndex200Response> {
  @override
  final Iterable<Type> types = const [BusinessLocationIndex200Response, _$BusinessLocationIndex200Response];

  @override
  final String wireName = r'BusinessLocationIndex200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusinessLocationIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(BusinessLocationResource)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusinessLocationIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BusinessLocationIndex200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BusinessLocationResource)]),
          ) as BuiltList<BusinessLocationResource>;
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
  BusinessLocationIndex200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusinessLocationIndex200ResponseBuilder();
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

