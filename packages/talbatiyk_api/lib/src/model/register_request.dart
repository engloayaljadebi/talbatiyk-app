//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/register_request_contact_value.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register_request.g.dart';

/// RegisterRequest
///
/// Properties:
/// * [username] 
/// * [displayName] 
/// * [password] 
/// * [contactType] 
/// * [contactValue] 
/// * [deviceName] 
/// * [passwordConfirmation] 
@BuiltValue()
abstract class RegisterRequest implements Built<RegisterRequest, RegisterRequestBuilder> {
  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'display_name')
  String get displayName;

  @BuiltValueField(wireName: r'password')
  String get password;

  @BuiltValueField(wireName: r'contact_type')
  RegisterRequestContactTypeEnum get contactType;
  // enum contactTypeEnum {  phone,  email,  };

  @BuiltValueField(wireName: r'contact_value')
  RegisterRequestContactValue get contactValue;

  @BuiltValueField(wireName: r'device_name')
  String get deviceName;

  @BuiltValueField(wireName: r'password_confirmation')
  String get passwordConfirmation;

  RegisterRequest._();

  factory RegisterRequest([void updates(RegisterRequestBuilder b)]) = _$RegisterRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterRequest> get serializer => _$RegisterRequestSerializer();
}

class _$RegisterRequestSerializer implements PrimitiveSerializer<RegisterRequest> {
  @override
  final Iterable<Type> types = const [RegisterRequest, _$RegisterRequest];

  @override
  final String wireName = r'RegisterRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'display_name';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
    yield r'contact_type';
    yield serializers.serialize(
      object.contactType,
      specifiedType: const FullType(RegisterRequestContactTypeEnum),
    );
    yield r'contact_value';
    yield serializers.serialize(
      object.contactValue,
      specifiedType: const FullType(RegisterRequestContactValue),
    );
    yield r'device_name';
    yield serializers.serialize(
      object.deviceName,
      specifiedType: const FullType(String),
    );
    yield r'password_confirmation';
    yield serializers.serialize(
      object.passwordConfirmation,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RegisterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RegisterRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        case r'contact_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RegisterRequestContactTypeEnum),
          ) as RegisterRequestContactTypeEnum;
          result.contactType = valueDes;
          break;
        case r'contact_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RegisterRequestContactValue),
          ) as RegisterRequestContactValue;
          result.contactValue.replace(valueDes);
          break;
        case r'device_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceName = valueDes;
          break;
        case r'password_confirmation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.passwordConfirmation = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RegisterRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterRequestBuilder();
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

class RegisterRequestContactTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'phone')
  static const RegisterRequestContactTypeEnum phone = _$registerRequestContactTypeEnum_phone;
  @BuiltValueEnumConst(wireName: r'email')
  static const RegisterRequestContactTypeEnum email = _$registerRequestContactTypeEnum_email;

  static Serializer<RegisterRequestContactTypeEnum> get serializer => _$registerRequestContactTypeEnumSerializer;

  const RegisterRequestContactTypeEnum._(String name): super(name);

  static BuiltSet<RegisterRequestContactTypeEnum> get values => _$registerRequestContactTypeEnumValues;
  static RegisterRequestContactTypeEnum valueOf(String name) => _$registerRequestContactTypeEnumValueOf(name);
}

