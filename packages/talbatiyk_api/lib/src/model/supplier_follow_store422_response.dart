//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/supplier_follow_store422_response_errors.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_follow_store422_response.g.dart';

/// SupplierFollowStore422Response
///
/// Properties:
/// * [message] 
/// * [errors] 
@BuiltValue()
abstract class SupplierFollowStore422Response implements Built<SupplierFollowStore422Response, SupplierFollowStore422ResponseBuilder> {
  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'errors')
  SupplierFollowStore422ResponseErrors get errors;

  SupplierFollowStore422Response._();

  factory SupplierFollowStore422Response([void updates(SupplierFollowStore422ResponseBuilder b)]) = _$SupplierFollowStore422Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierFollowStore422ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierFollowStore422Response> get serializer => _$SupplierFollowStore422ResponseSerializer();
}

class _$SupplierFollowStore422ResponseSerializer implements PrimitiveSerializer<SupplierFollowStore422Response> {
  @override
  final Iterable<Type> types = const [SupplierFollowStore422Response, _$SupplierFollowStore422Response];

  @override
  final String wireName = r'SupplierFollowStore422Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierFollowStore422Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'errors';
    yield serializers.serialize(
      object.errors,
      specifiedType: const FullType(SupplierFollowStore422ResponseErrors),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierFollowStore422Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierFollowStore422ResponseBuilder result,
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
        case r'errors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SupplierFollowStore422ResponseErrors),
          ) as SupplierFollowStore422ResponseErrors;
          result.errors.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierFollowStore422Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierFollowStore422ResponseBuilder();
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

