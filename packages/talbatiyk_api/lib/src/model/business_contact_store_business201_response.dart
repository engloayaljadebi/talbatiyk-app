//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/business_contact_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'business_contact_store_business201_response.g.dart';

/// BusinessContactStoreBusiness201Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class BusinessContactStoreBusiness201Response implements Built<BusinessContactStoreBusiness201Response, BusinessContactStoreBusiness201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BusinessContactResource get data;

  BusinessContactStoreBusiness201Response._();

  factory BusinessContactStoreBusiness201Response([void updates(BusinessContactStoreBusiness201ResponseBuilder b)]) = _$BusinessContactStoreBusiness201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusinessContactStoreBusiness201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusinessContactStoreBusiness201Response> get serializer => _$BusinessContactStoreBusiness201ResponseSerializer();
}

class _$BusinessContactStoreBusiness201ResponseSerializer implements PrimitiveSerializer<BusinessContactStoreBusiness201Response> {
  @override
  final Iterable<Type> types = const [BusinessContactStoreBusiness201Response, _$BusinessContactStoreBusiness201Response];

  @override
  final String wireName = r'BusinessContactStoreBusiness201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusinessContactStoreBusiness201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BusinessContactResource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusinessContactStoreBusiness201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BusinessContactStoreBusiness201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BusinessContactResource),
          ) as BusinessContactResource;
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
  BusinessContactStoreBusiness201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusinessContactStoreBusiness201ResponseBuilder();
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

