//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_business_request.g.dart';

/// UpdateBusinessRequest
///
/// Properties:
/// * [name] - ---------------------------------------------------------------- البيانات الأساسية المسموح بتعديلها ----------------------------------------------------------------
/// * [legalName] 
/// * [description] 
@BuiltValue()
abstract class UpdateBusinessRequest implements Built<UpdateBusinessRequest, UpdateBusinessRequestBuilder> {
  /// ---------------------------------------------------------------- البيانات الأساسية المسموح بتعديلها ----------------------------------------------------------------
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'legal_name')
  String? get legalName;

  @BuiltValueField(wireName: r'description')
  String? get description;

  UpdateBusinessRequest._();

  factory UpdateBusinessRequest([void updates(UpdateBusinessRequestBuilder b)]) = _$UpdateBusinessRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateBusinessRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateBusinessRequest> get serializer => _$UpdateBusinessRequestSerializer();
}

class _$UpdateBusinessRequestSerializer implements PrimitiveSerializer<UpdateBusinessRequest> {
  @override
  final Iterable<Type> types = const [UpdateBusinessRequest, _$UpdateBusinessRequest];

  @override
  final String wireName = r'UpdateBusinessRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateBusinessRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
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
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateBusinessRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateBusinessRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateBusinessRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateBusinessRequestBuilder();
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

