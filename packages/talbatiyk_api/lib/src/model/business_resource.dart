//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/business_resource_membership.dart';
import 'package:talbatiyk_api/src/model/business_contact_resource.dart';
import 'package:talbatiyk_api/src/model/business_location_resource.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'business_resource.g.dart';

/// BusinessResource
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [legalName] 
/// * [description] 
/// * [status] 
/// * [capabilities] - قدرات النشاط: supplier shop
/// * [primaryLocation] - الموقع الرئيسي فقط في هذه الاستجابة. قائمة جميع الفروع سيكون لها Endpoint مستقل لاحقًا.
/// * [primaryContact] - وسيلة الاتصال الرئيسية.
/// * [membership] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class BusinessResource implements Built<BusinessResource, BusinessResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'legal_name')
  String? get legalName;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'status')
  String get status;

  /// قدرات النشاط: supplier shop
  @BuiltValueField(wireName: r'capabilities')
  BuiltList<JsonObject?>? get capabilities;

  /// الموقع الرئيسي فقط في هذه الاستجابة. قائمة جميع الفروع سيكون لها Endpoint مستقل لاحقًا.
  @BuiltValueField(wireName: r'primary_location')
  BusinessLocationResource? get primaryLocation;

  /// وسيلة الاتصال الرئيسية.
  @BuiltValueField(wireName: r'primary_contact')
  BusinessContactResource? get primaryContact;

  @BuiltValueField(wireName: r'membership')
  BusinessResourceMembership? get membership;

  @BuiltValueField(wireName: r'created_at')
  String? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  String? get updatedAt;

  BusinessResource._();

  factory BusinessResource([void updates(BusinessResourceBuilder b)]) = _$BusinessResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusinessResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusinessResource> get serializer => _$BusinessResourceSerializer();
}

class _$BusinessResourceSerializer implements PrimitiveSerializer<BusinessResource> {
  @override
  final Iterable<Type> types = const [BusinessResource, _$BusinessResource];

  @override
  final String wireName = r'BusinessResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusinessResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'legal_name';
    yield object.legalName == null ? null : serializers.serialize(
      object.legalName,
      specifiedType: const FullType.nullable(String),
    );
    yield r'description';
    yield object.description == null ? null : serializers.serialize(
      object.description,
      specifiedType: const FullType.nullable(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    if (object.capabilities != null) {
      yield r'capabilities';
      yield serializers.serialize(
        object.capabilities,
        specifiedType: const FullType(BuiltList, [FullType.nullable(JsonObject)]),
      );
    }
    yield r'primary_location';
    yield object.primaryLocation == null ? null : serializers.serialize(
      object.primaryLocation,
      specifiedType: const FullType.nullable(BusinessLocationResource),
    );
    yield r'primary_contact';
    yield object.primaryContact == null ? null : serializers.serialize(
      object.primaryContact,
      specifiedType: const FullType.nullable(BusinessContactResource),
    );
    if (object.membership != null) {
      yield r'membership';
      yield serializers.serialize(
        object.membership,
        specifiedType: const FullType(BusinessResourceMembership),
      );
    }
    yield r'created_at';
    yield object.createdAt == null ? null : serializers.serialize(
      object.createdAt,
      specifiedType: const FullType.nullable(String),
    );
    yield r'updated_at';
    yield object.updatedAt == null ? null : serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusinessResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BusinessResourceBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'legal_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.legalName = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'capabilities':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>;
          result.capabilities.replace(valueDes);
          break;
        case r'primary_location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BusinessLocationResource),
          ) as BusinessLocationResource?;
          if (valueDes == null) continue;
          result.primaryLocation.replace(valueDes);
          break;
        case r'primary_contact':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BusinessContactResource),
          ) as BusinessContactResource?;
          if (valueDes == null) continue;
          result.primaryContact.replace(valueDes);
          break;
        case r'membership':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BusinessResourceMembership),
          ) as BusinessResourceMembership;
          result.membership.replace(valueDes);
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BusinessResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusinessResourceBuilder();
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

