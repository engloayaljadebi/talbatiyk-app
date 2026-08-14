//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'business_location_resource_coordinates.g.dart';

/// نضع الإحداثيات في كائن مستقل، وهذا يسهل لاحقًا ربطها بالخريطة في Flutter.
///
/// Properties:
/// * [latitude] 
/// * [longitude] 
@BuiltValue()
abstract class BusinessLocationResourceCoordinates implements Built<BusinessLocationResourceCoordinates, BusinessLocationResourceCoordinatesBuilder> {
  @BuiltValueField(wireName: r'latitude')
  num? get latitude;

  @BuiltValueField(wireName: r'longitude')
  num? get longitude;

  BusinessLocationResourceCoordinates._();

  factory BusinessLocationResourceCoordinates([void updates(BusinessLocationResourceCoordinatesBuilder b)]) = _$BusinessLocationResourceCoordinates;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusinessLocationResourceCoordinatesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusinessLocationResourceCoordinates> get serializer => _$BusinessLocationResourceCoordinatesSerializer();
}

class _$BusinessLocationResourceCoordinatesSerializer implements PrimitiveSerializer<BusinessLocationResourceCoordinates> {
  @override
  final Iterable<Type> types = const [BusinessLocationResourceCoordinates, _$BusinessLocationResourceCoordinates];

  @override
  final String wireName = r'BusinessLocationResourceCoordinates';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusinessLocationResourceCoordinates object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'latitude';
    yield object.latitude == null ? null : serializers.serialize(
      object.latitude,
      specifiedType: const FullType.nullable(num),
    );
    yield r'longitude';
    yield object.longitude == null ? null : serializers.serialize(
      object.longitude,
      specifiedType: const FullType.nullable(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusinessLocationResourceCoordinates object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BusinessLocationResourceCoordinatesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.longitude = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BusinessLocationResourceCoordinates deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusinessLocationResourceCoordinatesBuilder();
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

