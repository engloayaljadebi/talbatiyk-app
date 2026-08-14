//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/create_business_request_contact.dart';
import 'package:talbatiyk_api/src/model/create_business_request_location.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_business_request.g.dart';

/// CreateBusinessRequest
///
/// Properties:
/// * [name] - ---------------------------------------------------------------- بيانات النشاط الأساسية ----------------------------------------------------------------
/// * [legalName] 
/// * [description] 
/// * [capabilities] - ---------------------------------------------------------------- قدرات النشاط ---------------------------------------------------------------- مثال:  capabilities: - supplier - shop  لا نقبل قدرة متوقفة retired_at.
/// * [location] 
/// * [contact] 
@BuiltValue()
abstract class CreateBusinessRequest implements Built<CreateBusinessRequest, CreateBusinessRequestBuilder> {
  /// ---------------------------------------------------------------- بيانات النشاط الأساسية ----------------------------------------------------------------
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'legal_name')
  String? get legalName;

  @BuiltValueField(wireName: r'description')
  String? get description;

  /// ---------------------------------------------------------------- قدرات النشاط ---------------------------------------------------------------- مثال:  capabilities: - supplier - shop  لا نقبل قدرة متوقفة retired_at.
  @BuiltValueField(wireName: r'capabilities')
  BuiltList<String> get capabilities;

  @BuiltValueField(wireName: r'location')
  CreateBusinessRequestLocation get location;

  @BuiltValueField(wireName: r'contact')
  CreateBusinessRequestContact get contact;

  CreateBusinessRequest._();

  factory CreateBusinessRequest([void updates(CreateBusinessRequestBuilder b)]) = _$CreateBusinessRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateBusinessRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateBusinessRequest> get serializer => _$CreateBusinessRequestSerializer();
}

class _$CreateBusinessRequestSerializer implements PrimitiveSerializer<CreateBusinessRequest> {
  @override
  final Iterable<Type> types = const [CreateBusinessRequest, _$CreateBusinessRequest];

  @override
  final String wireName = r'CreateBusinessRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateBusinessRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.legalName != null) {
      yield r'legal_name';
      yield serializers.serialize(
        object.legalName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'capabilities';
    yield serializers.serialize(
      object.capabilities,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(CreateBusinessRequestLocation),
    );
    yield r'contact';
    yield serializers.serialize(
      object.contact,
      specifiedType: const FullType(CreateBusinessRequestContact),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateBusinessRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateBusinessRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'capabilities':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.capabilities.replace(valueDes);
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateBusinessRequestLocation),
          ) as CreateBusinessRequestLocation;
          result.location.replace(valueDes);
          break;
        case r'contact':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateBusinessRequestContact),
          ) as CreateBusinessRequestContact;
          result.contact.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateBusinessRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateBusinessRequestBuilder();
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

