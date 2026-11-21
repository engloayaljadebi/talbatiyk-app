//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_login403_response.g.dart';

/// AuthLogin403Response
///
/// Properties:
/// * [message] 
@BuiltValue()
abstract class AuthLogin403Response implements Built<AuthLogin403Response, AuthLogin403ResponseBuilder> {
  @BuiltValueField(wireName: r'message')
  String get message;

  AuthLogin403Response._();

  factory AuthLogin403Response([void updates(AuthLogin403ResponseBuilder b)]) = _$AuthLogin403Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthLogin403ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthLogin403Response> get serializer => _$AuthLogin403ResponseSerializer();
}

class _$AuthLogin403ResponseSerializer implements PrimitiveSerializer<AuthLogin403Response> {
  @override
  final Iterable<Type> types = const [AuthLogin403Response, _$AuthLogin403Response];

  @override
  final String wireName = r'AuthLogin403Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthLogin403Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthLogin403Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthLogin403ResponseBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthLogin403Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthLogin403ResponseBuilder();
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

