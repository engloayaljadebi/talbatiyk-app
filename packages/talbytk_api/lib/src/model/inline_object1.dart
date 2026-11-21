//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'inline_object1.g.dart';

/// InlineObject1
///
/// Properties:
/// * [message] - Error overview.
@BuiltValue()
abstract class InlineObject1 implements Built<InlineObject1, InlineObject1Builder> {
  /// Error overview.
  @BuiltValueField(wireName: r'message')
  String get message;

  InlineObject1._();

  factory InlineObject1([void updates(InlineObject1Builder b)]) = _$InlineObject1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InlineObject1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InlineObject1> get serializer => _$InlineObject1Serializer();
}

class _$InlineObject1Serializer implements PrimitiveSerializer<InlineObject1> {
  @override
  final Iterable<Type> types = const [InlineObject1, _$InlineObject1];

  @override
  final String wireName = r'InlineObject1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InlineObject1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InlineObject1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InlineObject1Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InlineObject1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InlineObject1Builder();
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

