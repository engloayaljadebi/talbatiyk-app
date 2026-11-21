//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_business_location_request.g.dart';

/// UpdateBusinessLocationRequest
///
/// Properties:
/// * [name] 
/// * [type] 
/// * [timezone] 
/// * [countryCode] 
/// * [administrativeArea] 
/// * [locality] 
/// * [district] 
/// * [streetAddress] 
/// * [addressNotes] 
/// * [latitude] 
/// * [longitude] 
/// * [status] 
@BuiltValue()
abstract class UpdateBusinessLocationRequest implements Built<UpdateBusinessLocationRequest, UpdateBusinessLocationRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'type')
  UpdateBusinessLocationRequestTypeEnum? get type;
  // enum typeEnum {  branch,  office,  warehouse,  store,  };

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'country_code')
  String? get countryCode;

  @BuiltValueField(wireName: r'administrative_area')
  String? get administrativeArea;

  @BuiltValueField(wireName: r'locality')
  String? get locality;

  @BuiltValueField(wireName: r'district')
  String? get district;

  @BuiltValueField(wireName: r'street_address')
  String? get streetAddress;

  @BuiltValueField(wireName: r'address_notes')
  String? get addressNotes;

  @BuiltValueField(wireName: r'latitude')
  num? get latitude;

  @BuiltValueField(wireName: r'longitude')
  num? get longitude;

  @BuiltValueField(wireName: r'status')
  UpdateBusinessLocationRequestStatusEnum? get status;
  // enum statusEnum {  active,  temporarily_closed,  closed,  };

  UpdateBusinessLocationRequest._();

  factory UpdateBusinessLocationRequest([void updates(UpdateBusinessLocationRequestBuilder b)]) = _$UpdateBusinessLocationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateBusinessLocationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateBusinessLocationRequest> get serializer => _$UpdateBusinessLocationRequestSerializer();
}

class _$UpdateBusinessLocationRequestSerializer implements PrimitiveSerializer<UpdateBusinessLocationRequest> {
  @override
  final Iterable<Type> types = const [UpdateBusinessLocationRequest, _$UpdateBusinessLocationRequest];

  @override
  final String wireName = r'UpdateBusinessLocationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateBusinessLocationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(UpdateBusinessLocationRequestTypeEnum),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType(String),
      );
    }
    if (object.countryCode != null) {
      yield r'country_code';
      yield serializers.serialize(
        object.countryCode,
        specifiedType: const FullType(String),
      );
    }
    if (object.administrativeArea != null) {
      yield r'administrative_area';
      yield serializers.serialize(
        object.administrativeArea,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.locality != null) {
      yield r'locality';
      yield serializers.serialize(
        object.locality,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.district != null) {
      yield r'district';
      yield serializers.serialize(
        object.district,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.streetAddress != null) {
      yield r'street_address';
      yield serializers.serialize(
        object.streetAddress,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.addressNotes != null) {
      yield r'address_notes';
      yield serializers.serialize(
        object.addressNotes,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.latitude != null) {
      yield r'latitude';
      yield serializers.serialize(
        object.latitude,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.longitude != null) {
      yield r'longitude';
      yield serializers.serialize(
        object.longitude,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(UpdateBusinessLocationRequestStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateBusinessLocationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateBusinessLocationRequestBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateBusinessLocationRequestTypeEnum),
          ) as UpdateBusinessLocationRequestTypeEnum;
          result.type = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.timezone = valueDes;
          break;
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
        case r'address_notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.addressNotes = valueDes;
          break;
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateBusinessLocationRequestStatusEnum),
          ) as UpdateBusinessLocationRequestStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateBusinessLocationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateBusinessLocationRequestBuilder();
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

class UpdateBusinessLocationRequestTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'branch')
  static const UpdateBusinessLocationRequestTypeEnum branch = _$updateBusinessLocationRequestTypeEnum_branch;
  @BuiltValueEnumConst(wireName: r'office')
  static const UpdateBusinessLocationRequestTypeEnum office = _$updateBusinessLocationRequestTypeEnum_office;
  @BuiltValueEnumConst(wireName: r'warehouse')
  static const UpdateBusinessLocationRequestTypeEnum warehouse = _$updateBusinessLocationRequestTypeEnum_warehouse;
  @BuiltValueEnumConst(wireName: r'store')
  static const UpdateBusinessLocationRequestTypeEnum store = _$updateBusinessLocationRequestTypeEnum_store;

  static Serializer<UpdateBusinessLocationRequestTypeEnum> get serializer => _$updateBusinessLocationRequestTypeEnumSerializer;

  const UpdateBusinessLocationRequestTypeEnum._(String name): super(name);

  static BuiltSet<UpdateBusinessLocationRequestTypeEnum> get values => _$updateBusinessLocationRequestTypeEnumValues;
  static UpdateBusinessLocationRequestTypeEnum valueOf(String name) => _$updateBusinessLocationRequestTypeEnumValueOf(name);
}

class UpdateBusinessLocationRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const UpdateBusinessLocationRequestStatusEnum active = _$updateBusinessLocationRequestStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'temporarily_closed')
  static const UpdateBusinessLocationRequestStatusEnum temporarilyClosed = _$updateBusinessLocationRequestStatusEnum_temporarilyClosed;
  @BuiltValueEnumConst(wireName: r'closed')
  static const UpdateBusinessLocationRequestStatusEnum closed = _$updateBusinessLocationRequestStatusEnum_closed;

  static Serializer<UpdateBusinessLocationRequestStatusEnum> get serializer => _$updateBusinessLocationRequestStatusEnumSerializer;

  const UpdateBusinessLocationRequestStatusEnum._(String name): super(name);

  static BuiltSet<UpdateBusinessLocationRequestStatusEnum> get values => _$updateBusinessLocationRequestStatusEnumValues;
  static UpdateBusinessLocationRequestStatusEnum valueOf(String name) => _$updateBusinessLocationRequestStatusEnumValueOf(name);
}

