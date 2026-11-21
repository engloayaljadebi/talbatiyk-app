//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_logout200_response.g.dart';

/// AuthLogout200Response
///
/// Properties:
/// * [message] 
@BuiltValue()
abstract class AuthLogout200Response implements Built<AuthLogout200Response, AuthLogout200ResponseBuilder> {
  @BuiltValueField(wireName: r'message')
  AuthLogout200ResponseMessageEnum get message;
  // enum messageEnum {  تم تسجيل الخروج بنجاح.,  };

  AuthLogout200Response._();

  factory AuthLogout200Response([void updates(AuthLogout200ResponseBuilder b)]) = _$AuthLogout200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthLogout200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthLogout200Response> get serializer => _$AuthLogout200ResponseSerializer();
}

class _$AuthLogout200ResponseSerializer implements PrimitiveSerializer<AuthLogout200Response> {
  @override
  final Iterable<Type> types = const [AuthLogout200Response, _$AuthLogout200Response];

  @override
  final String wireName = r'AuthLogout200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthLogout200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(AuthLogout200ResponseMessageEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthLogout200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthLogout200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthLogout200ResponseMessageEnum),
          ) as AuthLogout200ResponseMessageEnum;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthLogout200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthLogout200ResponseBuilder();
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

class AuthLogout200ResponseMessageEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'تم تسجيل الخروج بنجاح.')
  static const AuthLogout200ResponseMessageEnum period = _$authLogout200ResponseMessageEnum_period;

  static Serializer<AuthLogout200ResponseMessageEnum> get serializer => _$authLogout200ResponseMessageEnumSerializer;

  const AuthLogout200ResponseMessageEnum._(String name): super(name);

  static BuiltSet<AuthLogout200ResponseMessageEnum> get values => _$authLogout200ResponseMessageEnumValues;
  static AuthLogout200ResponseMessageEnum valueOf(String name) => _$authLogout200ResponseMessageEnumValueOf(name);
}

