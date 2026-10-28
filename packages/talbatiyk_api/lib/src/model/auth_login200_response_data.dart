//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/user_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_login200_response_data.g.dart';

/// AuthLogin200ResponseData
///
/// Properties:
/// * [user] 
/// * [accessToken] 
/// * [tokenType] 
@BuiltValue()
abstract class AuthLogin200ResponseData implements Built<AuthLogin200ResponseData, AuthLogin200ResponseDataBuilder> {
  @BuiltValueField(wireName: r'user')
  UserResource get user;

  @BuiltValueField(wireName: r'access_token')
  String get accessToken;

  @BuiltValueField(wireName: r'token_type')
  AuthLogin200ResponseDataTokenTypeEnum get tokenType;
  // enum tokenTypeEnum {  Bearer,  };

  AuthLogin200ResponseData._();

  factory AuthLogin200ResponseData([void updates(AuthLogin200ResponseDataBuilder b)]) = _$AuthLogin200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthLogin200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthLogin200ResponseData> get serializer => _$AuthLogin200ResponseDataSerializer();
}

class _$AuthLogin200ResponseDataSerializer implements PrimitiveSerializer<AuthLogin200ResponseData> {
  @override
  final Iterable<Type> types = const [AuthLogin200ResponseData, _$AuthLogin200ResponseData];

  @override
  final String wireName = r'AuthLogin200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthLogin200ResponseData object, {
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
      specifiedType: const FullType(AuthLogin200ResponseDataTokenTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthLogin200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthLogin200ResponseDataBuilder result,
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
            specifiedType: const FullType(AuthLogin200ResponseDataTokenTypeEnum),
          ) as AuthLogin200ResponseDataTokenTypeEnum;
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
  AuthLogin200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthLogin200ResponseDataBuilder();
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

class AuthLogin200ResponseDataTokenTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'Bearer')
  static const AuthLogin200ResponseDataTokenTypeEnum bearer = _$authLogin200ResponseDataTokenTypeEnum_bearer;

  static Serializer<AuthLogin200ResponseDataTokenTypeEnum> get serializer => _$authLogin200ResponseDataTokenTypeEnumSerializer;

  const AuthLogin200ResponseDataTokenTypeEnum._(String name): super(name);

  static BuiltSet<AuthLogin200ResponseDataTokenTypeEnum> get values => _$authLogin200ResponseDataTokenTypeEnumValues;
  static AuthLogin200ResponseDataTokenTypeEnum valueOf(String name) => _$authLogin200ResponseDataTokenTypeEnumValueOf(name);
}

