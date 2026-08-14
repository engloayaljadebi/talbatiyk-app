//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/business_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'business_store201_response.g.dart';

/// BusinessStore201Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class BusinessStore201Response implements Built<BusinessStore201Response, BusinessStore201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BusinessResource get data;

  BusinessStore201Response._();

  factory BusinessStore201Response([void updates(BusinessStore201ResponseBuilder b)]) = _$BusinessStore201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusinessStore201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusinessStore201Response> get serializer => _$BusinessStore201ResponseSerializer();
}

class _$BusinessStore201ResponseSerializer implements PrimitiveSerializer<BusinessStore201Response> {
  @override
  final Iterable<Type> types = const [BusinessStore201Response, _$BusinessStore201Response];

  @override
  final String wireName = r'BusinessStore201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusinessStore201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BusinessResource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusinessStore201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BusinessStore201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BusinessResource),
          ) as BusinessResource;
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
  BusinessStore201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusinessStore201ResponseBuilder();
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

