//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'business_resource_membership.g.dart';

/// عضوية المستخدم الذي أنشأ النشاط. لا نعيد بيانات المستخدم مرة أخرى لأنها موجودة أصلًا في Auth /me.
///
/// Properties:
/// * [id] 
/// * [status] 
/// * [roles] 
/// * [joinedAt] 
@BuiltValue()
abstract class BusinessResourceMembership implements Built<BusinessResourceMembership, BusinessResourceMembershipBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'roles')
  BuiltList<JsonObject?> get roles;

  @BuiltValueField(wireName: r'joined_at')
  String? get joinedAt;

  BusinessResourceMembership._();

  factory BusinessResourceMembership([void updates(BusinessResourceMembershipBuilder b)]) = _$BusinessResourceMembership;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusinessResourceMembershipBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusinessResourceMembership> get serializer => _$BusinessResourceMembershipSerializer();
}

class _$BusinessResourceMembershipSerializer implements PrimitiveSerializer<BusinessResourceMembership> {
  @override
  final Iterable<Type> types = const [BusinessResourceMembership, _$BusinessResourceMembership];

  @override
  final String wireName = r'BusinessResourceMembership';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusinessResourceMembership object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'roles';
    yield serializers.serialize(
      object.roles,
      specifiedType: const FullType(BuiltList, [FullType.nullable(JsonObject)]),
    );
    yield r'joined_at';
    yield object.joinedAt == null ? null : serializers.serialize(
      object.joinedAt,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusinessResourceMembership object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BusinessResourceMembershipBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'roles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>;
          result.roles.replace(valueDes);
          break;
        case r'joined_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.joinedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BusinessResourceMembership deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusinessResourceMembershipBuilder();
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

