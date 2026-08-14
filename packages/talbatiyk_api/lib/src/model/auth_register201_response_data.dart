//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/user_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_register201_response_data.g.dart';

/// AuthRegister201ResponseData
///
/// Properties:
/// * [user] 
/// * [accessToken] 
/// * [tokenType] 
@BuiltValue()
abstract class AuthRegister201ResponseData implements Built<AuthRegister201ResponseData, AuthRegister201ResponseDataBuilder> {
  @BuiltValueField(wireName: r'user')
  UserResource get user;

  @BuiltValueField(wireName: r'access_token')
  String get accessToken;

  @BuiltValueField(wireName: r'token_type')
  AuthRegister201ResponseDataTokenTypeEnum get tokenType;
  // enum tokenTypeEnum {  Bearer,  };

  AuthRegister201ResponseData._();

  factory AuthRegister201ResponseData([void updates(AuthRegister201ResponseDataBuilder b)]) = _$AuthRegister201ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRegister201ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRegister201ResponseData> get serializer => _$AuthRegister201ResponseDataSerializer();
}

class _$AuthRegister201ResponseDataSerializer implements PrimitiveSerializer<AuthRegister201ResponseData> {
  @override
  final Iterable<Type> types = const [AuthRegister201ResponseData, _$AuthRegister201ResponseData];

  @override
  final String wireName = r'AuthRegister201ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRegister201ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(UserResource),
    );
    yield r'access_token';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
    yield r'token_type';
    yield serializers.serialize(
      object.tokenType,
      specifiedType: const FullType(AuthRegister201ResponseDataTokenTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthRegister201ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthRegister201ResponseDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserResource),
          ) as UserResource;
          result.user.replace(valueDes);
          break;
        case r'access_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'token_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthRegister201ResponseDataTokenTypeEnum),
          ) as AuthRegister201ResponseDataTokenTypeEnum;
          result.tokenType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthRegister201ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRegister201ResponseDataBuilder();
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

class AuthRegister201ResponseDataTokenTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'Bearer')
  static const AuthRegister201ResponseDataTokenTypeEnum bearer = _$authRegister201ResponseDataTokenTypeEnum_bearer;

  static Serializer<AuthRegister201ResponseDataTokenTypeEnum> get serializer => _$authRegister201ResponseDataTokenTypeEnumSerializer;

  const AuthRegister201ResponseDataTokenTypeEnum._(String name): super(name);

  static BuiltSet<AuthRegister201ResponseDataTokenTypeEnum> get values => _$authRegister201ResponseDataTokenTypeEnumValues;
  static AuthRegister201ResponseDataTokenTypeEnum valueOf(String name) => _$authRegister201ResponseDataTokenTypeEnumValueOf(name);
}

