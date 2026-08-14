//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_business_request_contact.g.dart';

/// ---------------------------------------------------------------- وسيلة الاتصال الرئيسية للنشاط ---------------------------------------------------------------- هذه الوسيلة ستكون مرتبطة بـ business_id، وليست مرتبطة بالفرع الرئيسي.
///
/// Properties:
/// * [type] 
/// * [value] 
/// * [label] 
@BuiltValue()
abstract class CreateBusinessRequestContact implements Built<CreateBusinessRequestContact, CreateBusinessRequestContactBuilder> {
  @BuiltValueField(wireName: r'type')
  CreateBusinessRequestContactTypeEnum get type;
  // enum typeEnum {  phone,  whatsapp,  email,  website,  };

  @BuiltValueField(wireName: r'value')
  String get value;

  @BuiltValueField(wireName: r'label')
  String? get label;

  CreateBusinessRequestContact._();

  factory CreateBusinessRequestContact([void updates(CreateBusinessRequestContactBuilder b)]) = _$CreateBusinessRequestContact;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateBusinessRequestContactBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateBusinessRequestContact> get serializer => _$CreateBusinessRequestContactSerializer();
}

class _$CreateBusinessRequestContactSerializer implements PrimitiveSerializer<CreateBusinessRequestContact> {
  @override
  final Iterable<Type> types = const [CreateBusinessRequestContact, _$CreateBusinessRequestContact];

  @override
  final String wireName = r'CreateBusinessRequestContact';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateBusinessRequestContact object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(CreateBusinessRequestContactTypeEnum),
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
    CreateBusinessRequestContact object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateBusinessRequestContactBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateBusinessRequestContactTypeEnum),
          ) as CreateBusinessRequestContactTypeEnum;
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
  CreateBusinessRequestContact deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateBusinessRequestContactBuilder();
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

class CreateBusinessRequestContactTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'phone')
  static const CreateBusinessRequestContactTypeEnum phone = _$createBusinessRequestContactTypeEnum_phone;
  @BuiltValueEnumConst(wireName: r'whatsapp')
  static const CreateBusinessRequestContactTypeEnum whatsapp = _$createBusinessRequestContactTypeEnum_whatsapp;
  @BuiltValueEnumConst(wireName: r'email')
  static const CreateBusinessRequestContactTypeEnum email = _$createBusinessRequestContactTypeEnum_email;
  @BuiltValueEnumConst(wireName: r'website')
  static const CreateBusinessRequestContactTypeEnum website = _$createBusinessRequestContactTypeEnum_website;

  static Serializer<CreateBusinessRequestContactTypeEnum> get serializer => _$createBusinessRequestContactTypeEnumSerializer;

  const CreateBusinessRequestContactTypeEnum._(String name): super(name);

  static BuiltSet<CreateBusinessRequestContactTypeEnum> get values => _$createBusinessRequestContactTypeEnumValues;
  static CreateBusinessRequestContactTypeEnum valueOf(String name) => _$createBusinessRequestContactTypeEnumValueOf(name);
}

