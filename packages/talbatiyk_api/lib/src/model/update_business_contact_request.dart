//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_business_contact_request.g.dart';

/// UpdateBusinessContactRequest
///
/// Properties:
/// * [value] - يتم التحقق من صيغة value حسب النوع الحالي داخل BusinessContactService بعد التحقق من صلاحية المستخدم وملكية Contact.
/// * [label] 
@BuiltValue()
abstract class UpdateBusinessContactRequest implements Built<UpdateBusinessContactRequest, UpdateBusinessContactRequestBuilder> {
  /// يتم التحقق من صيغة value حسب النوع الحالي داخل BusinessContactService بعد التحقق من صلاحية المستخدم وملكية Contact.
  @BuiltValueField(wireName: r'value')
  String? get value;

  @BuiltValueField(wireName: r'label')
  String? get label;

  UpdateBusinessContactRequest._();

  factory UpdateBusinessContactRequest([void updates(UpdateBusinessContactRequestBuilder b)]) = _$UpdateBusinessContactRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateBusinessContactRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateBusinessContactRequest> get serializer => _$UpdateBusinessContactRequestSerializer();
}

class _$UpdateBusinessContactRequestSerializer implements PrimitiveSerializer<UpdateBusinessContactRequest> {
  @override
  final Iterable<Type> types = const [UpdateBusinessContactRequest, _$UpdateBusinessContactRequest];

  @override
  final String wireName = r'UpdateBusinessContactRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateBusinessContactRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.value != null) {
      yield r'value';
      yield serializers.serialize(
        object.value,
        specifiedType: const FullType(String),
      );
    }
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
    UpdateBusinessContactRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateBusinessContactRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  UpdateBusinessContactRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateBusinessContactRequestBuilder();
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

