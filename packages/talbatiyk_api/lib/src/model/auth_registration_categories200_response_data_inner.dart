//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_registration_categories200_response_data_inner.g.dart';

/// AuthRegistrationCategories200ResponseDataInner
///
/// Properties:
/// * [id] 
/// * [name] 
@BuiltValue()
abstract class AuthRegistrationCategories200ResponseDataInner implements Built<AuthRegistrationCategories200ResponseDataInner, AuthRegistrationCategories200ResponseDataInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  AuthRegistrationCategories200ResponseDataInner._();

  factory AuthRegistrationCategories200ResponseDataInner([void updates(AuthRegistrationCategories200ResponseDataInnerBuilder b)]) = _$AuthRegistrationCategories200ResponseDataInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRegistrationCategories200ResponseDataInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRegistrationCategories200ResponseDataInner> get serializer => _$AuthRegistrationCategories200ResponseDataInnerSerializer();
}

class _$AuthRegistrationCategories200ResponseDataInnerSerializer implements PrimitiveSerializer<AuthRegistrationCategories200ResponseDataInner> {
  @override
  final Iterable<Type> types = const [AuthRegistrationCategories200ResponseDataInner, _$AuthRegistrationCategories200ResponseDataInner];

  @override
  final String wireName = r'AuthRegistrationCategories200ResponseDataInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRegistrationCategories200ResponseDataInner object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthRegistrationCategories200ResponseDataInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthRegistrationCategories200ResponseDataInnerBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthRegistrationCategories200ResponseDataInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRegistrationCategories200ResponseDataInnerBuilder();
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

