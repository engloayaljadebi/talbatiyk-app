//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/date.dart';
import 'package:talbatiyk_api/src/model/register_request_contact_value.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register_request.g.dart';

/// RegisterRequest
///
/// Properties:
/// * [username] 
/// * [displayName] 
/// * [password] 
/// * [contactType] 
/// * [contactValue] 
/// * [accountType] 
/// * [nationalityCountryCode] 
/// * [birthDate] 
/// * [name] 
/// * [legalName] 
/// * [description] 
/// * [categoryId] 
/// * [locationName] 
/// * [locationType] 
/// * [timezone] 
/// * [countryCode] 
/// * [administrativeArea] 
/// * [locality] 
/// * [district] 
/// * [streetAddress] 
/// * [addressNotes] 
/// * [latitude] 
/// * [longitude] 
/// * [businessContactType] 
/// * [businessContactValue] 
/// * [businessContactLabel] 
/// * [deviceName] 
/// * [passwordConfirmation] 
@BuiltValue()
abstract class RegisterRequest implements Built<RegisterRequest, RegisterRequestBuilder> {
  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'display_name')
  String get displayName;

  @BuiltValueField(wireName: r'password')
  String get password;

  @BuiltValueField(wireName: r'contact_type')
  RegisterRequestContactTypeEnum get contactType;
  // enum contactTypeEnum {  phone,  email,  };

  @BuiltValueField(wireName: r'contact_value')
  RegisterRequestContactValue get contactValue;

  @BuiltValueField(wireName: r'account_type')
  RegisterRequestAccountTypeEnum get accountType;
  // enum accountTypeEnum {  shop,  supplier,  };

  @BuiltValueField(wireName: r'nationality_country_code')
  String? get nationalityCountryCode;

  @BuiltValueField(wireName: r'birth_date')
  Date? get birthDate;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'legal_name')
  String? get legalName;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'category_id')
  String? get categoryId;

  @BuiltValueField(wireName: r'location_name')
  String? get locationName;

  @BuiltValueField(wireName: r'location_type')
  RegisterRequestLocationTypeEnum? get locationType;
  // enum locationTypeEnum {  branch,  office,  warehouse,  store,  ,  };

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

  @BuiltValueField(wireName: r'business_contact_type')
  RegisterRequestBusinessContactTypeEnum? get businessContactType;
  // enum businessContactTypeEnum {  phone,  whatsapp,  email,  website,  ,  };

  @BuiltValueField(wireName: r'business_contact_value')
  String? get businessContactValue;

  @BuiltValueField(wireName: r'business_contact_label')
  String? get businessContactLabel;

  @BuiltValueField(wireName: r'device_name')
  String get deviceName;

  @BuiltValueField(wireName: r'password_confirmation')
  String get passwordConfirmation;

  RegisterRequest._();

  factory RegisterRequest([void updates(RegisterRequestBuilder b)]) = _$RegisterRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterRequest> get serializer => _$RegisterRequestSerializer();
}

class _$RegisterRequestSerializer implements PrimitiveSerializer<RegisterRequest> {
  @override
  final Iterable<Type> types = const [RegisterRequest, _$RegisterRequest];

  @override
  final String wireName = r'RegisterRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'display_name';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
    yield r'contact_type';
    yield serializers.serialize(
      object.contactType,
      specifiedType: const FullType(RegisterRequestContactTypeEnum),
    );
    yield r'contact_value';
    yield serializers.serialize(
      object.contactValue,
      specifiedType: const FullType(RegisterRequestContactValue),
    );
    yield r'account_type';
    yield serializers.serialize(
      object.accountType,
      specifiedType: const FullType(RegisterRequestAccountTypeEnum),
    );
    if (object.nationalityCountryCode != null) {
      yield r'nationality_country_code';
      yield serializers.serialize(
        object.nationalityCountryCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.birthDate != null) {
      yield r'birth_date';
      yield serializers.serialize(
        object.birthDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.legalName != null) {
      yield r'legal_name';
      yield serializers.serialize(
        object.legalName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.categoryId != null) {
      yield r'category_id';
      yield serializers.serialize(
        object.categoryId,
        specifiedType: const FullType(String),
      );
    }
    if (object.locationName != null) {
      yield r'location_name';
      yield serializers.serialize(
        object.locationName,
        specifiedType: const FullType(String),
      );
    }
    if (object.locationType != null) {
      yield r'location_type';
      yield serializers.serialize(
        object.locationType,
        specifiedType: const FullType.nullable(RegisterRequestLocationTypeEnum),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.countryCode != null) {
      yield r'country_code';
      yield serializers.serialize(
        object.countryCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.administrativeArea != null) {
      yield r'administrative_area';
      yield serializers.serialize(
        object.administrativeArea,
        specifiedType: const FullType(String),
      );
    }
    if (object.locality != null) {
      yield r'locality';
      yield serializers.serialize(
        object.locality,
        specifiedType: const FullType(String),
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
    if (object.businessContactType != null) {
      yield r'business_contact_type';
      yield serializers.serialize(
        object.businessContactType,
        specifiedType: const FullType.nullable(RegisterRequestBusinessContactTypeEnum),
      );
    }
    if (object.businessContactValue != null) {
      yield r'business_contact_value';
      yield serializers.serialize(
        object.businessContactValue,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.businessContactLabel != null) {
      yield r'business_contact_label';
      yield serializers.serialize(
        object.businessContactLabel,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'device_name';
    yield serializers.serialize(
      object.deviceName,
      specifiedType: const FullType(String),
    );
    yield r'password_confirmation';
    yield serializers.serialize(
      object.passwordConfirmation,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RegisterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RegisterRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        case r'contact_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RegisterRequestContactTypeEnum),
          ) as RegisterRequestContactTypeEnum;
          result.contactType = valueDes;
          break;
        case r'contact_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RegisterRequestContactValue),
          ) as RegisterRequestContactValue;
          result.contactValue.replace(valueDes);
          break;
        case r'account_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RegisterRequestAccountTypeEnum),
          ) as RegisterRequestAccountTypeEnum;
          result.accountType = valueDes;
          break;
        case r'nationality_country_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nationalityCountryCode = valueDes;
          break;
        case r'birth_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.birthDate = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'legal_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.legalName = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'category_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.categoryId = valueDes;
          break;
        case r'location_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.locationName = valueDes;
          break;
        case r'location_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RegisterRequestLocationTypeEnum),
          ) as RegisterRequestLocationTypeEnum?;
          if (valueDes == null) continue;
          result.locationType = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.timezone = valueDes;
          break;
        case r'country_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.countryCode = valueDes;
          break;
        case r'administrative_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.administrativeArea = valueDes;
          break;
        case r'locality':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
        case r'business_contact_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RegisterRequestBusinessContactTypeEnum),
          ) as RegisterRequestBusinessContactTypeEnum?;
          if (valueDes == null) continue;
          result.businessContactType = valueDes;
          break;
        case r'business_contact_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.businessContactValue = valueDes;
          break;
        case r'business_contact_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.businessContactLabel = valueDes;
          break;
        case r'device_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceName = valueDes;
          break;
        case r'password_confirmation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.passwordConfirmation = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RegisterRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterRequestBuilder();
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

class RegisterRequestContactTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'phone')
  static const RegisterRequestContactTypeEnum phone = _$registerRequestContactTypeEnum_phone;
  @BuiltValueEnumConst(wireName: r'email')
  static const RegisterRequestContactTypeEnum email = _$registerRequestContactTypeEnum_email;

  static Serializer<RegisterRequestContactTypeEnum> get serializer => _$registerRequestContactTypeEnumSerializer;

  const RegisterRequestContactTypeEnum._(String name): super(name);

  static BuiltSet<RegisterRequestContactTypeEnum> get values => _$registerRequestContactTypeEnumValues;
  static RegisterRequestContactTypeEnum valueOf(String name) => _$registerRequestContactTypeEnumValueOf(name);
}

class RegisterRequestAccountTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'shop')
  static const RegisterRequestAccountTypeEnum shop = _$registerRequestAccountTypeEnum_shop;
  @BuiltValueEnumConst(wireName: r'supplier')
  static const RegisterRequestAccountTypeEnum supplier = _$registerRequestAccountTypeEnum_supplier;

  static Serializer<RegisterRequestAccountTypeEnum> get serializer => _$registerRequestAccountTypeEnumSerializer;

  const RegisterRequestAccountTypeEnum._(String name): super(name);

  static BuiltSet<RegisterRequestAccountTypeEnum> get values => _$registerRequestAccountTypeEnumValues;
  static RegisterRequestAccountTypeEnum valueOf(String name) => _$registerRequestAccountTypeEnumValueOf(name);
}

class RegisterRequestLocationTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'branch')
  static const RegisterRequestLocationTypeEnum branch = _$registerRequestLocationTypeEnum_branch;
  @BuiltValueEnumConst(wireName: r'office')
  static const RegisterRequestLocationTypeEnum office = _$registerRequestLocationTypeEnum_office;
  @BuiltValueEnumConst(wireName: r'warehouse')
  static const RegisterRequestLocationTypeEnum warehouse = _$registerRequestLocationTypeEnum_warehouse;
  @BuiltValueEnumConst(wireName: r'store')
  static const RegisterRequestLocationTypeEnum store = _$registerRequestLocationTypeEnum_store;

  static Serializer<RegisterRequestLocationTypeEnum> get serializer => _$registerRequestLocationTypeEnumSerializer;

  const RegisterRequestLocationTypeEnum._(String name): super(name);

  static BuiltSet<RegisterRequestLocationTypeEnum> get values => _$registerRequestLocationTypeEnumValues;
  static RegisterRequestLocationTypeEnum valueOf(String name) => _$registerRequestLocationTypeEnumValueOf(name);
}

class RegisterRequestBusinessContactTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'phone')
  static const RegisterRequestBusinessContactTypeEnum phone = _$registerRequestBusinessContactTypeEnum_phone;
  @BuiltValueEnumConst(wireName: r'whatsapp')
  static const RegisterRequestBusinessContactTypeEnum whatsapp = _$registerRequestBusinessContactTypeEnum_whatsapp;
  @BuiltValueEnumConst(wireName: r'email')
  static const RegisterRequestBusinessContactTypeEnum email = _$registerRequestBusinessContactTypeEnum_email;
  @BuiltValueEnumConst(wireName: r'website')
  static const RegisterRequestBusinessContactTypeEnum website = _$registerRequestBusinessContactTypeEnum_website;

  static Serializer<RegisterRequestBusinessContactTypeEnum> get serializer => _$registerRequestBusinessContactTypeEnumSerializer;

  const RegisterRequestBusinessContactTypeEnum._(String name): super(name);

  static BuiltSet<RegisterRequestBusinessContactTypeEnum> get values => _$registerRequestBusinessContactTypeEnumValues;
  static RegisterRequestBusinessContactTypeEnum valueOf(String name) => _$registerRequestBusinessContactTypeEnumValueOf(name);
}

