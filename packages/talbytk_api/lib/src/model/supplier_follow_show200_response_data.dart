//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_follow_show200_response_data.g.dart';

/// SupplierFollowShow200ResponseData
///
/// Properties:
/// * [businessId] 
/// * [isFollowing] 
@BuiltValue()
abstract class SupplierFollowShow200ResponseData implements Built<SupplierFollowShow200ResponseData, SupplierFollowShow200ResponseDataBuilder> {
  @BuiltValueField(wireName: r'business_id')
  String get businessId;

  @BuiltValueField(wireName: r'is_following')
  bool get isFollowing;

  SupplierFollowShow200ResponseData._();

  factory SupplierFollowShow200ResponseData([void updates(SupplierFollowShow200ResponseDataBuilder b)]) = _$SupplierFollowShow200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierFollowShow200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierFollowShow200ResponseData> get serializer => _$SupplierFollowShow200ResponseDataSerializer();
}

class _$SupplierFollowShow200ResponseDataSerializer implements PrimitiveSerializer<SupplierFollowShow200ResponseData> {
  @override
  final Iterable<Type> types = const [SupplierFollowShow200ResponseData, _$SupplierFollowShow200ResponseData];

  @override
  final String wireName = r'SupplierFollowShow200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierFollowShow200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'business_id';
    yield serializers.serialize(
      object.businessId,
      specifiedType: const FullType(String),
    );
    yield r'is_following';
    yield serializers.serialize(
      object.isFollowing,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierFollowShow200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierFollowShow200ResponseDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'business_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.businessId = valueDes;
          break;
        case r'is_following':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isFollowing = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierFollowShow200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierFollowShow200ResponseDataBuilder();
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

