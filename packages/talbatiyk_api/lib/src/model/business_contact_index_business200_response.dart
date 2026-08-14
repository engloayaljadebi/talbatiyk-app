//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/business_contact_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'business_contact_index_business200_response.g.dart';

/// BusinessContactIndexBusiness200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class BusinessContactIndexBusiness200Response implements Built<BusinessContactIndexBusiness200Response, BusinessContactIndexBusiness200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<BusinessContactResource> get data;

  BusinessContactIndexBusiness200Response._();

  factory BusinessContactIndexBusiness200Response([void updates(BusinessContactIndexBusiness200ResponseBuilder b)]) = _$BusinessContactIndexBusiness200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusinessContactIndexBusiness200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusinessContactIndexBusiness200Response> get serializer => _$BusinessContactIndexBusiness200ResponseSerializer();
}

class _$BusinessContactIndexBusiness200ResponseSerializer implements PrimitiveSerializer<BusinessContactIndexBusiness200Response> {
  @override
  final Iterable<Type> types = const [BusinessContactIndexBusiness200Response, _$BusinessContactIndexBusiness200Response];

  @override
  final String wireName = r'BusinessContactIndexBusiness200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusinessContactIndexBusiness200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(BusinessContactResource)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusinessContactIndexBusiness200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BusinessContactIndexBusiness200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BusinessContactResource)]),
          ) as BuiltList<BusinessContactResource>;
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
  BusinessContactIndexBusiness200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusinessContactIndexBusiness200ResponseBuilder();
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

