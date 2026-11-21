//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_follow_store422_response_errors.g.dart';

/// SupplierFollowStore422ResponseErrors
///
/// Properties:
/// * [businessId] 
@BuiltValue()
abstract class SupplierFollowStore422ResponseErrors implements Built<SupplierFollowStore422ResponseErrors, SupplierFollowStore422ResponseErrorsBuilder> {
  @BuiltValueField(wireName: r'business_id')
  BuiltList<String> get businessId;

  SupplierFollowStore422ResponseErrors._();

  factory SupplierFollowStore422ResponseErrors([void updates(SupplierFollowStore422ResponseErrorsBuilder b)]) = _$SupplierFollowStore422ResponseErrors;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierFollowStore422ResponseErrorsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierFollowStore422ResponseErrors> get serializer => _$SupplierFollowStore422ResponseErrorsSerializer();
}

class _$SupplierFollowStore422ResponseErrorsSerializer implements PrimitiveSerializer<SupplierFollowStore422ResponseErrors> {
  @override
  final Iterable<Type> types = const [SupplierFollowStore422ResponseErrors, _$SupplierFollowStore422ResponseErrors];

  @override
  final String wireName = r'SupplierFollowStore422ResponseErrors';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierFollowStore422ResponseErrors object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'business_id';
    yield serializers.serialize(
      object.businessId,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierFollowStore422ResponseErrors object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierFollowStore422ResponseErrorsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'business_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.businessId.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierFollowStore422ResponseErrors deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierFollowStore422ResponseErrorsBuilder();
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

