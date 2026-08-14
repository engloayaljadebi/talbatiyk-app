//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/user_resource_contacts_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_resource.g.dart';

/// UserResource
///
/// Properties:
/// * [id] 
/// * [username] 
/// * [displayName] 
/// * [status] 
/// * [lastLoginAt] 
/// * [contacts] 
@BuiltValue()
abstract class UserResource implements Built<UserResource, UserResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'display_name')
  String get displayName;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'last_login_at')
  String? get lastLoginAt;

  @BuiltValueField(wireName: r'contacts')
  BuiltList<UserResourceContactsInner>? get contacts;

  UserResource._();

  factory UserResource([void updates(UserResourceBuilder b)]) = _$UserResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserResource> get serializer => _$UserResourceSerializer();
}

class _$UserResourceSerializer implements PrimitiveSerializer<UserResource> {
  @override
  final Iterable<Type> types = const [UserResource, _$UserResource];

  @override
  final String wireName = r'UserResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
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
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'last_login_at';
    yield object.lastLoginAt == null ? null : serializers.serialize(
      object.lastLoginAt,
      specifiedType: const FullType.nullable(String),
    );
    if (object.contacts != null) {
      yield r'contacts';
      yield serializers.serialize(
        object.contacts,
        specifiedType: const FullType(BuiltList, [FullType(UserResourceContactsInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserResourceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'last_login_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastLoginAt = valueDes;
          break;
        case r'contacts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(UserResourceContactsInner)]),
          ) as BuiltList<UserResourceContactsInner>;
          result.contacts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserResourceBuilder();
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

