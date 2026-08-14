//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/user_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_me200_response.g.dart';

/// AuthMe200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class AuthMe200Response implements Built<AuthMe200Response, AuthMe200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  UserResource get data;

  AuthMe200Response._();

  factory AuthMe200Response([void updates(AuthMe200ResponseBuilder b)]) = _$AuthMe200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthMe200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthMe200Response> get serializer => _$AuthMe200ResponseSerializer();
}

class _$AuthMe200ResponseSerializer implements PrimitiveSerializer<AuthMe200Response> {
  @override
  final Iterable<Type> types = const [AuthMe200Response, _$AuthMe200Response];

  @override
  final String wireName = r'AuthMe200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthMe200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(UserResource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthMe200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthMe200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserResource),
          ) as UserResource;
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
  AuthMe200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthMe200ResponseBuilder();
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

