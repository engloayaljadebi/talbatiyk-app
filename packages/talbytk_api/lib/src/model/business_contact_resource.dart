//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'business_contact_resource.g.dart';

/// BusinessContactResource
///
/// Properties:
/// * [id] 
/// * [type] 
/// * [value] 
/// * [label] 
/// * [isPrimary] 
/// * [isVerified] - لا نرسل verified_at فقط كقيمة منطقية، بل نرسل الحالة والتاريخ للاستفادة منهما مستقبلًا.
/// * [verifiedAt] 
@BuiltValue()
abstract class BusinessContactResource implements Built<BusinessContactResource, BusinessContactResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'type')
  String get type;

  @BuiltValueField(wireName: r'value')
  String get value;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'is_primary')
  bool get isPrimary;

  /// لا نرسل verified_at فقط كقيمة منطقية، بل نرسل الحالة والتاريخ للاستفادة منهما مستقبلًا.
  @BuiltValueField(wireName: r'is_verified')
  bool get isVerified;

  @BuiltValueField(wireName: r'verified_at')
  String? get verifiedAt;

  BusinessContactResource._();

  factory BusinessContactResource([void updates(BusinessContactResourceBuilder b)]) = _$BusinessContactResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusinessContactResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusinessContactResource> get serializer => _$BusinessContactResourceSerializer();
}

class _$BusinessContactResourceSerializer implements PrimitiveSerializer<BusinessContactResource> {
  @override
  final Iterable<Type> types = const [BusinessContactResource, _$BusinessContactResource];

  @override
  final String wireName = r'BusinessContactResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusinessContactResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(String),
    );
    yield r'value';
    yield serializers.serialize(
      object.value,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield object.label == null ? null : serializers.serialize(
      object.label,
      specifiedType: const FullType.nullable(String),
    );
    yield r'is_primary';
    yield serializers.serialize(
      object.isPrimary,
      specifiedType: const FullType(bool),
    );
    yield r'is_verified';
    yield serializers.serialize(
      object.isVerified,
      specifiedType: const FullType(bool),
    );
    yield r'verified_at';
    yield object.verifiedAt == null ? null : serializers.serialize(
      object.verifiedAt,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusinessContactResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BusinessContactResourceBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.value = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'is_primary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isPrimary = valueDes;
          break;
        case r'is_verified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isVerified = valueDes;
          break;
        case r'verified_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.verifiedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BusinessContactResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusinessContactResourceBuilder();
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

