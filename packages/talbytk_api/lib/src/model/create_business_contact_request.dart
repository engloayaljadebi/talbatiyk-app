//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_business_contact_request.g.dart';

/// CreateBusinessContactRequest
///
/// Properties:
/// * [type] 
/// * [value] 
/// * [label] 
@BuiltValue()
abstract class CreateBusinessContactRequest implements Built<CreateBusinessContactRequest, CreateBusinessContactRequestBuilder> {
  @BuiltValueField(wireName: r'type')
  CreateBusinessContactRequestTypeEnum get type;
  // enum typeEnum {  phone,  whatsapp,  email,  website,  };

  @BuiltValueField(wireName: r'value')
  String get value;

  @BuiltValueField(wireName: r'label')
  String? get label;

  CreateBusinessContactRequest._();

  factory CreateBusinessContactRequest([void updates(CreateBusinessContactRequestBuilder b)]) = _$CreateBusinessContactRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateBusinessContactRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateBusinessContactRequest> get serializer => _$CreateBusinessContactRequestSerializer();
}

class _$CreateBusinessContactRequestSerializer implements PrimitiveSerializer<CreateBusinessContactRequest> {
  @override
  final Iterable<Type> types = const [CreateBusinessContactRequest, _$CreateBusinessContactRequest];

  @override
  final String wireName = r'CreateBusinessContactRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateBusinessContactRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(CreateBusinessContactRequestTypeEnum),
    );
    yield r'value';
    yield serializers.serialize(
      object.value,
      specifiedType: const FullType(String),
    );
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateBusinessContactRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateBusinessContactRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateBusinessContactRequestTypeEnum),
          ) as CreateBusinessContactRequestTypeEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateBusinessContactRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateBusinessContactRequestBuilder();
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

class CreateBusinessContactRequestTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'phone')
  static const CreateBusinessContactRequestTypeEnum phone = _$createBusinessContactRequestTypeEnum_phone;
  @BuiltValueEnumConst(wireName: r'whatsapp')
  static const CreateBusinessContactRequestTypeEnum whatsapp = _$createBusinessContactRequestTypeEnum_whatsapp;
  @BuiltValueEnumConst(wireName: r'email')
  static const CreateBusinessContactRequestTypeEnum email = _$createBusinessContactRequestTypeEnum_email;
  @BuiltValueEnumConst(wireName: r'website')
  static const CreateBusinessContactRequestTypeEnum website = _$createBusinessContactRequestTypeEnum_website;

  static Serializer<CreateBusinessContactRequestTypeEnum> get serializer => _$createBusinessContactRequestTypeEnumSerializer;

  const CreateBusinessContactRequestTypeEnum._(String name): super(name);

  static BuiltSet<CreateBusinessContactRequestTypeEnum> get values => _$createBusinessContactRequestTypeEnumValues;
  static CreateBusinessContactRequestTypeEnum valueOf(String name) => _$createBusinessContactRequestTypeEnumValueOf(name);
}

