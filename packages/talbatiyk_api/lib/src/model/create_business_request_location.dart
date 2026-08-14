//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_business_request_location.g.dart';

/// ---------------------------------------------------------------- الموقع الرئيسي ----------------------------------------------------------------
///
/// Properties:
/// * [name] 
/// * [type] 
/// * [timezone] - Laravel يتحقق أن القيمة اسم Timezone صالح. مثال: Asia/Aden
/// * [countryCode] - ISO 3166-1 alpha-2 اليمن: YE
/// * [administrativeArea] 
/// * [locality] 
/// * [district] 
/// * [streetAddress] 
/// * [addressNotes] 
/// * [latitude] - إذا تم إرسال أحد الإحداثيين يجب إرسال الآخر أيضًا. PostgreSQL لديه كذلك CHECK constraints، لكننا نرفض الخطأ مبكرًا من طبقة API.
/// * [longitude] 
@BuiltValue()
abstract class CreateBusinessRequestLocation implements Built<CreateBusinessRequestLocation, CreateBusinessRequestLocationBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'type')
  CreateBusinessRequestLocationTypeEnum get type;
  // enum typeEnum {  branch,  office,  warehouse,  store,  };

  /// Laravel يتحقق أن القيمة اسم Timezone صالح. مثال: Asia/Aden
  @BuiltValueField(wireName: r'timezone')
  String get timezone;

  /// ISO 3166-1 alpha-2 اليمن: YE
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

  @BuiltValueField(wireName: r'address_notes')
  String? get addressNotes;

  /// إذا تم إرسال أحد الإحداثيين يجب إرسال الآخر أيضًا. PostgreSQL لديه كذلك CHECK constraints، لكننا نرفض الخطأ مبكرًا من طبقة API.
  @BuiltValueField(wireName: r'latitude')
  num? get latitude;

  @BuiltValueField(wireName: r'longitude')
  num? get longitude;

  CreateBusinessRequestLocation._();

  factory CreateBusinessRequestLocation([void updates(CreateBusinessRequestLocationBuilder b)]) = _$CreateBusinessRequestLocation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateBusinessRequestLocationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateBusinessRequestLocation> get serializer => _$CreateBusinessRequestLocationSerializer();
}

class _$CreateBusinessRequestLocationSerializer implements PrimitiveSerializer<CreateBusinessRequestLocation> {
  @override
  final Iterable<Type> types = const [CreateBusinessRequestLocation, _$CreateBusinessRequestLocation];

  @override
  final String wireName = r'CreateBusinessRequestLocation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateBusinessRequestLocation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(CreateBusinessRequestLocationTypeEnum),
    );
    yield r'timezone';
    yield serializers.serialize(
      object.timezone,
      specifiedType: const FullType(String),
    );
    yield r'country_code';
    yield serializers.serialize(
      object.countryCode,
      specifiedType: const FullType(String),
    );
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
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateBusinessRequestLocation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateBusinessRequestLocationBuilder result,
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
            specifiedType: const FullType(CreateBusinessRequestLocationTypeEnum),
          ) as CreateBusinessRequestLocationTypeEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateBusinessRequestLocation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateBusinessRequestLocationBuilder();
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

class CreateBusinessRequestLocationTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'branch')
  static const CreateBusinessRequestLocationTypeEnum branch = _$createBusinessRequestLocationTypeEnum_branch;
  @BuiltValueEnumConst(wireName: r'office')
  static const CreateBusinessRequestLocationTypeEnum office = _$createBusinessRequestLocationTypeEnum_office;
  @BuiltValueEnumConst(wireName: r'warehouse')
  static const CreateBusinessRequestLocationTypeEnum warehouse = _$createBusinessRequestLocationTypeEnum_warehouse;
  @BuiltValueEnumConst(wireName: r'store')
  static const CreateBusinessRequestLocationTypeEnum store = _$createBusinessRequestLocationTypeEnum_store;

  static Serializer<CreateBusinessRequestLocationTypeEnum> get serializer => _$createBusinessRequestLocationTypeEnumSerializer;

  const CreateBusinessRequestLocationTypeEnum._(String name): super(name);

  static BuiltSet<CreateBusinessRequestLocationTypeEnum> get values => _$createBusinessRequestLocationTypeEnumValues;
  static CreateBusinessRequestLocationTypeEnum valueOf(String name) => _$createBusinessRequestLocationTypeEnumValueOf(name);
}

