//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_me403_response.g.dart';

/// AuthMe403Response
///
/// Properties:
/// * [message] 
/// * [code] 
@BuiltValue()
abstract class AuthMe403Response implements Built<AuthMe403Response, AuthMe403ResponseBuilder> {
  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'code')
  AuthMe403ResponseCodeEnum get code;
  // enum codeEnum {  ACCOUNT_INACTIVE,  };

  AuthMe403Response._();

  factory AuthMe403Response([void updates(AuthMe403ResponseBuilder b)]) = _$AuthMe403Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthMe403ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthMe403Response> get serializer => _$AuthMe403ResponseSerializer();
}

class _$AuthMe403ResponseSerializer implements PrimitiveSerializer<AuthMe403Response> {
  @override
  final Iterable<Type> types = const [AuthMe403Response, _$AuthMe403Response];

  @override
  final String wireName = r'AuthMe403Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthMe403Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(AuthMe403ResponseCodeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthMe403Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthMe403ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthMe403ResponseCodeEnum),
          ) as AuthMe403ResponseCodeEnum;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthMe403Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthMe403ResponseBuilder();
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

class AuthMe403ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ACCOUNT_INACTIVE')
  static const AuthMe403ResponseCodeEnum ACCOUNT_INACTIVE = _$authMe403ResponseCodeEnum_ACCOUNT_INACTIVE;

  static Serializer<AuthMe403ResponseCodeEnum> get serializer => _$authMe403ResponseCodeEnumSerializer;

  const AuthMe403ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthMe403ResponseCodeEnum> get values => _$authMe403ResponseCodeEnumValues;
  static AuthMe403ResponseCodeEnum valueOf(String name) => _$authMe403ResponseCodeEnumValueOf(name);
}

