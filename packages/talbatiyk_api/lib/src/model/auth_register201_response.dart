//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/auth_register201_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_register201_response.g.dart';

/// AuthRegister201Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class AuthRegister201Response implements Built<AuthRegister201Response, AuthRegister201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AuthRegister201ResponseData get data;

  AuthRegister201Response._();

  factory AuthRegister201Response([void updates(AuthRegister201ResponseBuilder b)]) = _$AuthRegister201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRegister201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRegister201Response> get serializer => _$AuthRegister201ResponseSerializer();
}

class _$AuthRegister201ResponseSerializer implements PrimitiveSerializer<AuthRegister201Response> {
  @override
  final Iterable<Type> types = const [AuthRegister201Response, _$AuthRegister201Response];

  @override
  final String wireName = r'AuthRegister201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRegister201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AuthRegister201ResponseData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthRegister201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthRegister201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthRegister201ResponseData),
          ) as AuthRegister201ResponseData;
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
  AuthRegister201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRegister201ResponseBuilder();
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

