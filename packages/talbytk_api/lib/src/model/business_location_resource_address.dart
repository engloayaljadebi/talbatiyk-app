//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'business_location_resource_address.g.dart';

/// BusinessLocationResourceAddress
///
/// Properties:
/// * [countryCode] 
/// * [administrativeArea] 
/// * [locality] 
/// * [district] 
/// * [streetAddress] 
/// * [notes] 
@BuiltValue()
abstract class BusinessLocationResourceAddress implements Built<BusinessLocationResourceAddress, BusinessLocationResourceAddressBuilder> {
  @BuiltValueField(wireName: r'country_code')
  String get countryCode;

  @BuiltValueField(wireName: r'administrative_area')
  String? get administrativeArea;

  @BuiltValueField(wireName: r'locality')
  String? get locality;

  @BuiltValueField(wireName: r'district')
  String? get district;

  @BuiltValueField(wireName: r'street_address')
  String? get streetAddress;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  BusinessLocationResourceAddress._();

  factory BusinessLocationResourceAddress([void updates(BusinessLocationResourceAddressBuilder b)]) = _$BusinessLocationResourceAddress;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusinessLocationResourceAddressBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusinessLocationResourceAddress> get serializer => _$BusinessLocationResourceAddressSerializer();
}

class _$BusinessLocationResourceAddressSerializer implements PrimitiveSerializer<BusinessLocationResourceAddress> {
  @override
  final Iterable<Type> types = const [BusinessLocationResourceAddress, _$BusinessLocationResourceAddress];

  @override
  final String wireName = r'BusinessLocationResourceAddress';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusinessLocationResourceAddress object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'country_code';
    yield serializers.serialize(
      object.countryCode,
      specifiedType: const FullType(String),
    );
    yield r'administrative_area';
    yield object.administrativeArea == null ? null : serializers.serialize(
      object.administrativeArea,
      specifiedType: const FullType.nullable(String),
    );
    yield r'locality';
    yield object.locality == null ? null : serializers.serialize(
      object.locality,
      specifiedType: const FullType.nullable(String),
    );
    yield r'district';
    yield object.district == null ? null : serializers.serialize(
      object.district,
      specifiedType: const FullType.nullable(String),
    );
    yield r'street_address';
    yield object.streetAddress == null ? null : serializers.serialize(
      object.streetAddress,
      specifiedType: const FullType.nullable(String),
    );
    yield r'notes';
    yield object.notes == null ? null : serializers.serialize(
      object.notes,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusinessLocationResourceAddress object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BusinessLocationResourceAddressBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'country_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.countryCode = valueDes;
          break;
        case r'administrative_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.administrativeArea = valueDes;
          break;
        case r'locality':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.locality = valueDes;
          break;
        case r'district':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.district = valueDes;
          break;
        case r'street_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.streetAddress = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BusinessLocationResourceAddress deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusinessLocationResourceAddressBuilder();
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

