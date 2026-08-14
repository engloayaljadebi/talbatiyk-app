//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/business_location_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'business_location_store201_response.g.dart';

/// BusinessLocationStore201Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class BusinessLocationStore201Response implements Built<BusinessLocationStore201Response, BusinessLocationStore201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BusinessLocationResource get data;

  BusinessLocationStore201Response._();

  factory BusinessLocationStore201Response([void updates(BusinessLocationStore201ResponseBuilder b)]) = _$BusinessLocationStore201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusinessLocationStore201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusinessLocationStore201Response> get serializer => _$BusinessLocationStore201ResponseSerializer();
}

class _$BusinessLocationStore201ResponseSerializer implements PrimitiveSerializer<BusinessLocationStore201Response> {
  @override
  final Iterable<Type> types = const [BusinessLocationStore201Response, _$BusinessLocationStore201Response];

  @override
  final String wireName = r'BusinessLocationStore201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusinessLocationStore201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BusinessLocationResource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusinessLocationStore201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BusinessLocationStore201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BusinessLocationResource),
          ) as BusinessLocationResource;
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
  BusinessLocationStore201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusinessLocationStore201ResponseBuilder();
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

