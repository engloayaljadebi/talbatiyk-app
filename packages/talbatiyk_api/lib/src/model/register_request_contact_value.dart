//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'register_request_contact_value.g.dart';

/// RegisterRequestContactValue
@BuiltValue()
abstract class RegisterRequestContactValue implements Built<RegisterRequestContactValue, RegisterRequestContactValueBuilder> {
  /// Any Of [String]
  AnyOf get anyOf;

  RegisterRequestContactValue._();

  factory RegisterRequestContactValue([void updates(RegisterRequestContactValueBuilder b)]) = _$RegisterRequestContactValue;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterRequestContactValueBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterRequestContactValue> get serializer => _$RegisterRequestContactValueSerializer();
}

class _$RegisterRequestContactValueSerializer implements PrimitiveSerializer<RegisterRequestContactValue> {
  @override
  final Iterable<Type> types = const [RegisterRequestContactValue, _$RegisterRequestContactValue];

  @override
  final String wireName = r'RegisterRequestContactValue';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterRequestContactValue object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    RegisterRequestContactValue object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  RegisterRequestContactValue deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterRequestContactValueBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(String), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

