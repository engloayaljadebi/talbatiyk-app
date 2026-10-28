//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/auth_registration_categories200_response_data_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_registration_categories200_response.g.dart';

/// AuthRegistrationCategories200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class AuthRegistrationCategories200Response implements Built<AuthRegistrationCategories200Response, AuthRegistrationCategories200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<AuthRegistrationCategories200ResponseDataInner> get data;

  AuthRegistrationCategories200Response._();

  factory AuthRegistrationCategories200Response([void updates(AuthRegistrationCategories200ResponseBuilder b)]) = _$AuthRegistrationCategories200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRegistrationCategories200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRegistrationCategories200Response> get serializer => _$AuthRegistrationCategories200ResponseSerializer();
}

class _$AuthRegistrationCategories200ResponseSerializer implements PrimitiveSerializer<AuthRegistrationCategories200Response> {
  @override
  final Iterable<Type> types = const [AuthRegistrationCategories200Response, _$AuthRegistrationCategories200Response];

  @override
  final String wireName = r'AuthRegistrationCategories200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRegistrationCategories200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(AuthRegistrationCategories200ResponseDataInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthRegistrationCategories200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthRegistrationCategories200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AuthRegistrationCategories200ResponseDataInner)]),
          ) as BuiltList<AuthRegistrationCategories200ResponseDataInner>;
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
  AuthRegistrationCategories200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRegistrationCategories200ResponseBuilder();
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

