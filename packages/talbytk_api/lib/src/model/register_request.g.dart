// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RegisterRequestContactTypeEnum _$registerRequestContactTypeEnum_phone =
    const RegisterRequestContactTypeEnum._('phone');
const RegisterRequestContactTypeEnum _$registerRequestContactTypeEnum_email =
    const RegisterRequestContactTypeEnum._('email');

RegisterRequestContactTypeEnum _$registerRequestContactTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'phone':
      return _$registerRequestContactTypeEnum_phone;
    case 'email':
      return _$registerRequestContactTypeEnum_email;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RegisterRequestContactTypeEnum>
    _$registerRequestContactTypeEnumValues = BuiltSet<
        RegisterRequestContactTypeEnum>(const <RegisterRequestContactTypeEnum>[
  _$registerRequestContactTypeEnum_phone,
  _$registerRequestContactTypeEnum_email,
]);

const RegisterRequestAccountTypeEnum _$registerRequestAccountTypeEnum_shop =
    const RegisterRequestAccountTypeEnum._('shop');
const RegisterRequestAccountTypeEnum _$registerRequestAccountTypeEnum_supplier =
    const RegisterRequestAccountTypeEnum._('supplier');

RegisterRequestAccountTypeEnum _$registerRequestAccountTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'shop':
      return _$registerRequestAccountTypeEnum_shop;
    case 'supplier':
      return _$registerRequestAccountTypeEnum_supplier;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RegisterRequestAccountTypeEnum>
    _$registerRequestAccountTypeEnumValues = BuiltSet<
        RegisterRequestAccountTypeEnum>(const <RegisterRequestAccountTypeEnum>[
  _$registerRequestAccountTypeEnum_shop,
  _$registerRequestAccountTypeEnum_supplier,
]);

const RegisterRequestLocationTypeEnum _$registerRequestLocationTypeEnum_branch =
    const RegisterRequestLocationTypeEnum._('branch');
const RegisterRequestLocationTypeEnum _$registerRequestLocationTypeEnum_office =
    const RegisterRequestLocationTypeEnum._('office');
const RegisterRequestLocationTypeEnum
    _$registerRequestLocationTypeEnum_warehouse =
    const RegisterRequestLocationTypeEnum._('warehouse');
const RegisterRequestLocationTypeEnum _$registerRequestLocationTypeEnum_store =
    const RegisterRequestLocationTypeEnum._('store');

RegisterRequestLocationTypeEnum _$registerRequestLocationTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'branch':
      return _$registerRequestLocationTypeEnum_branch;
    case 'office':
      return _$registerRequestLocationTypeEnum_office;
    case 'warehouse':
      return _$registerRequestLocationTypeEnum_warehouse;
    case 'store':
      return _$registerRequestLocationTypeEnum_store;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RegisterRequestLocationTypeEnum>
    _$registerRequestLocationTypeEnumValues = BuiltSet<
        RegisterRequestLocationTypeEnum>(const <RegisterRequestLocationTypeEnum>[
  _$registerRequestLocationTypeEnum_branch,
  _$registerRequestLocationTypeEnum_office,
  _$registerRequestLocationTypeEnum_warehouse,
  _$registerRequestLocationTypeEnum_store,
]);

const RegisterRequestBusinessContactTypeEnum
    _$registerRequestBusinessContactTypeEnum_phone =
    const RegisterRequestBusinessContactTypeEnum._('phone');
const RegisterRequestBusinessContactTypeEnum
    _$registerRequestBusinessContactTypeEnum_whatsapp =
    const RegisterRequestBusinessContactTypeEnum._('whatsapp');
const RegisterRequestBusinessContactTypeEnum
    _$registerRequestBusinessContactTypeEnum_email =
    const RegisterRequestBusinessContactTypeEnum._('email');
const RegisterRequestBusinessContactTypeEnum
    _$registerRequestBusinessContactTypeEnum_website =
    const RegisterRequestBusinessContactTypeEnum._('website');

RegisterRequestBusinessContactTypeEnum
    _$registerRequestBusinessContactTypeEnumValueOf(String name) {
  switch (name) {
    case 'phone':
      return _$registerRequestBusinessContactTypeEnum_phone;
    case 'whatsapp':
      return _$registerRequestBusinessContactTypeEnum_whatsapp;
    case 'email':
      return _$registerRequestBusinessContactTypeEnum_email;
    case 'website':
      return _$registerRequestBusinessContactTypeEnum_website;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RegisterRequestBusinessContactTypeEnum>
    _$registerRequestBusinessContactTypeEnumValues = BuiltSet<
        RegisterRequestBusinessContactTypeEnum>(const <RegisterRequestBusinessContactTypeEnum>[
  _$registerRequestBusinessContactTypeEnum_phone,
  _$registerRequestBusinessContactTypeEnum_whatsapp,
  _$registerRequestBusinessContactTypeEnum_email,
  _$registerRequestBusinessContactTypeEnum_website,
]);

Serializer<RegisterRequestContactTypeEnum>
    _$registerRequestContactTypeEnumSerializer =
    _$RegisterRequestContactTypeEnumSerializer();
Serializer<RegisterRequestAccountTypeEnum>
    _$registerRequestAccountTypeEnumSerializer =
    _$RegisterRequestAccountTypeEnumSerializer();
Serializer<RegisterRequestLocationTypeEnum>
    _$registerRequestLocationTypeEnumSerializer =
    _$RegisterRequestLocationTypeEnumSerializer();
Serializer<RegisterRequestBusinessContactTypeEnum>
    _$registerRequestBusinessContactTypeEnumSerializer =
    _$RegisterRequestBusinessContactTypeEnumSerializer();

class _$RegisterRequestContactTypeEnumSerializer
    implements PrimitiveSerializer<RegisterRequestContactTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'phone': 'phone',
    'email': 'email',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'phone': 'phone',
    'email': 'email',
  };

  @override
  final Iterable<Type> types = const <Type>[RegisterRequestContactTypeEnum];
  @override
  final String wireName = 'RegisterRequestContactTypeEnum';

  @override
  Object serialize(
          Serializers serializers, RegisterRequestContactTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RegisterRequestContactTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RegisterRequestContactTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RegisterRequestAccountTypeEnumSerializer
    implements PrimitiveSerializer<RegisterRequestAccountTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'shop': 'shop',
    'supplier': 'supplier',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'shop': 'shop',
    'supplier': 'supplier',
  };

  @override
  final Iterable<Type> types = const <Type>[RegisterRequestAccountTypeEnum];
  @override
  final String wireName = 'RegisterRequestAccountTypeEnum';

  @override
  Object serialize(
          Serializers serializers, RegisterRequestAccountTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RegisterRequestAccountTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RegisterRequestAccountTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RegisterRequestLocationTypeEnumSerializer
    implements PrimitiveSerializer<RegisterRequestLocationTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'branch': 'branch',
    'office': 'office',
    'warehouse': 'warehouse',
    'store': 'store',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'branch': 'branch',
    'office': 'office',
    'warehouse': 'warehouse',
    'store': 'store',
  };

  @override
  final Iterable<Type> types = const <Type>[RegisterRequestLocationTypeEnum];
  @override
  final String wireName = 'RegisterRequestLocationTypeEnum';

  @override
  Object serialize(
          Serializers serializers, RegisterRequestLocationTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RegisterRequestLocationTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RegisterRequestLocationTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RegisterRequestBusinessContactTypeEnumSerializer
    implements PrimitiveSerializer<RegisterRequestBusinessContactTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'phone': 'phone',
    'whatsapp': 'whatsapp',
    'email': 'email',
    'website': 'website',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'phone': 'phone',
    'whatsapp': 'whatsapp',
    'email': 'email',
    'website': 'website',
  };

  @override
  final Iterable<Type> types = const <Type>[
    RegisterRequestBusinessContactTypeEnum
  ];
  @override
  final String wireName = 'RegisterRequestBusinessContactTypeEnum';

  @override
  Object serialize(Serializers serializers,
          RegisterRequestBusinessContactTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RegisterRequestBusinessContactTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RegisterRequestBusinessContactTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RegisterRequest extends RegisterRequest {
  @override
  final String username;
  @override
  final String displayName;
  @override
  final String password;
  @override
  final RegisterRequestContactTypeEnum contactType;
  @override
  final RegisterRequestContactValue contactValue;
  @override
  final RegisterRequestAccountTypeEnum accountType;
  @override
  final String? nationalityCountryCode;
  @override
  final Date? birthDate;
  @override
  final String? name;
  @override
  final String? legalName;
  @override
  final String? description;
  @override
  final String? categoryId;
  @override
  final String? locationName;
  @override
  final RegisterRequestLocationTypeEnum? locationType;
  @override
  final String? timezone;
  @override
  final String? countryCode;
  @override
  final String? administrativeArea;
  @override
  final String? locality;
  @override
  final String? district;
  @override
  final String? streetAddress;
  @override
  final String? addressNotes;
  @override
  final num? latitude;
  @override
  final num? longitude;
  @override
  final RegisterRequestBusinessContactTypeEnum? businessContactType;
  @override
  final String? businessContactValue;
  @override
  final String? businessContactLabel;
  @override
  final String deviceName;
  @override
  final String passwordConfirmation;

  factory _$RegisterRequest([void Function(RegisterRequestBuilder)? updates]) =>
      (RegisterRequestBuilder()..update(updates))._build();

  _$RegisterRequest._(
      {required this.username,
      required this.displayName,
      required this.password,
      required this.contactType,
      required this.contactValue,
      required this.accountType,
      this.nationalityCountryCode,
      this.birthDate,
      this.name,
      this.legalName,
      this.description,
      this.categoryId,
      this.locationName,
      this.locationType,
      this.timezone,
      this.countryCode,
      this.administrativeArea,
      this.locality,
      this.district,
      this.streetAddress,
      this.addressNotes,
      this.latitude,
      this.longitude,
      this.businessContactType,
      this.businessContactValue,
      this.businessContactLabel,
      required this.deviceName,
      required this.passwordConfirmation})
      : super._();
  @override
  RegisterRequest rebuild(void Function(RegisterRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterRequestBuilder toBuilder() => RegisterRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterRequest &&
        username == other.username &&
        displayName == other.displayName &&
        password == other.password &&
        contactType == other.contactType &&
        contactValue == other.contactValue &&
        accountType == other.accountType &&
        nationalityCountryCode == other.nationalityCountryCode &&
        birthDate == other.birthDate &&
        name == other.name &&
        legalName == other.legalName &&
        description == other.description &&
        categoryId == other.categoryId &&
        locationName == other.locationName &&
        locationType == other.locationType &&
        timezone == other.timezone &&
        countryCode == other.countryCode &&
        administrativeArea == other.administrativeArea &&
        locality == other.locality &&
        district == other.district &&
        streetAddress == other.streetAddress &&
        addressNotes == other.addressNotes &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        businessContactType == other.businessContactType &&
        businessContactValue == other.businessContactValue &&
        businessContactLabel == other.businessContactLabel &&
        deviceName == other.deviceName &&
        passwordConfirmation == other.passwordConfirmation;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, contactType.hashCode);
    _$hash = $jc(_$hash, contactValue.hashCode);
    _$hash = $jc(_$hash, accountType.hashCode);
    _$hash = $jc(_$hash, nationalityCountryCode.hashCode);
    _$hash = $jc(_$hash, birthDate.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, legalName.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, categoryId.hashCode);
    _$hash = $jc(_$hash, locationName.hashCode);
    _$hash = $jc(_$hash, locationType.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, countryCode.hashCode);
    _$hash = $jc(_$hash, administrativeArea.hashCode);
    _$hash = $jc(_$hash, locality.hashCode);
    _$hash = $jc(_$hash, district.hashCode);
    _$hash = $jc(_$hash, streetAddress.hashCode);
    _$hash = $jc(_$hash, addressNotes.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, businessContactType.hashCode);
    _$hash = $jc(_$hash, businessContactValue.hashCode);
    _$hash = $jc(_$hash, businessContactLabel.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jc(_$hash, passwordConfirmation.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegisterRequest')
          ..add('username', username)
          ..add('displayName', displayName)
          ..add('password', password)
          ..add('contactType', contactType)
          ..add('contactValue', contactValue)
          ..add('accountType', accountType)
          ..add('nationalityCountryCode', nationalityCountryCode)
          ..add('birthDate', birthDate)
          ..add('name', name)
          ..add('legalName', legalName)
          ..add('description', description)
          ..add('categoryId', categoryId)
          ..add('locationName', locationName)
          ..add('locationType', locationType)
          ..add('timezone', timezone)
          ..add('countryCode', countryCode)
          ..add('administrativeArea', administrativeArea)
          ..add('locality', locality)
          ..add('district', district)
          ..add('streetAddress', streetAddress)
          ..add('addressNotes', addressNotes)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('businessContactType', businessContactType)
          ..add('businessContactValue', businessContactValue)
          ..add('businessContactLabel', businessContactLabel)
          ..add('deviceName', deviceName)
          ..add('passwordConfirmation', passwordConfirmation))
        .toString();
  }
}

class RegisterRequestBuilder
    implements Builder<RegisterRequest, RegisterRequestBuilder> {
  _$RegisterRequest? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  RegisterRequestContactTypeEnum? _contactType;
  RegisterRequestContactTypeEnum? get contactType => _$this._contactType;
  set contactType(RegisterRequestContactTypeEnum? contactType) =>
      _$this._contactType = contactType;

  RegisterRequestContactValueBuilder? _contactValue;
  RegisterRequestContactValueBuilder get contactValue =>
      _$this._contactValue ??= RegisterRequestContactValueBuilder();
  set contactValue(RegisterRequestContactValueBuilder? contactValue) =>
      _$this._contactValue = contactValue;

  RegisterRequestAccountTypeEnum? _accountType;
  RegisterRequestAccountTypeEnum? get accountType => _$this._accountType;
  set accountType(RegisterRequestAccountTypeEnum? accountType) =>
      _$this._accountType = accountType;

  String? _nationalityCountryCode;
  String? get nationalityCountryCode => _$this._nationalityCountryCode;
  set nationalityCountryCode(String? nationalityCountryCode) =>
      _$this._nationalityCountryCode = nationalityCountryCode;

  Date? _birthDate;
  Date? get birthDate => _$this._birthDate;
  set birthDate(Date? birthDate) => _$this._birthDate = birthDate;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _legalName;
  String? get legalName => _$this._legalName;
  set legalName(String? legalName) => _$this._legalName = legalName;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _categoryId;
  String? get categoryId => _$this._categoryId;
  set categoryId(String? categoryId) => _$this._categoryId = categoryId;

  String? _locationName;
  String? get locationName => _$this._locationName;
  set locationName(String? locationName) => _$this._locationName = locationName;

  RegisterRequestLocationTypeEnum? _locationType;
  RegisterRequestLocationTypeEnum? get locationType => _$this._locationType;
  set locationType(RegisterRequestLocationTypeEnum? locationType) =>
      _$this._locationType = locationType;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  String? _countryCode;
  String? get countryCode => _$this._countryCode;
  set countryCode(String? countryCode) => _$this._countryCode = countryCode;

  String? _administrativeArea;
  String? get administrativeArea => _$this._administrativeArea;
  set administrativeArea(String? administrativeArea) =>
      _$this._administrativeArea = administrativeArea;

  String? _locality;
  String? get locality => _$this._locality;
  set locality(String? locality) => _$this._locality = locality;

  String? _district;
  String? get district => _$this._district;
  set district(String? district) => _$this._district = district;

  String? _streetAddress;
  String? get streetAddress => _$this._streetAddress;
  set streetAddress(String? streetAddress) =>
      _$this._streetAddress = streetAddress;

  String? _addressNotes;
  String? get addressNotes => _$this._addressNotes;
  set addressNotes(String? addressNotes) => _$this._addressNotes = addressNotes;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  RegisterRequestBusinessContactTypeEnum? _businessContactType;
  RegisterRequestBusinessContactTypeEnum? get businessContactType =>
      _$this._businessContactType;
  set businessContactType(
          RegisterRequestBusinessContactTypeEnum? businessContactType) =>
      _$this._businessContactType = businessContactType;

  String? _businessContactValue;
  String? get businessContactValue => _$this._businessContactValue;
  set businessContactValue(String? businessContactValue) =>
      _$this._businessContactValue = businessContactValue;

  String? _businessContactLabel;
  String? get businessContactLabel => _$this._businessContactLabel;
  set businessContactLabel(String? businessContactLabel) =>
      _$this._businessContactLabel = businessContactLabel;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  String? _passwordConfirmation;
  String? get passwordConfirmation => _$this._passwordConfirmation;
  set passwordConfirmation(String? passwordConfirmation) =>
      _$this._passwordConfirmation = passwordConfirmation;

  RegisterRequestBuilder() {
    RegisterRequest._defaults(this);
  }

  RegisterRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _displayName = $v.displayName;
      _password = $v.password;
      _contactType = $v.contactType;
      _contactValue = $v.contactValue.toBuilder();
      _accountType = $v.accountType;
      _nationalityCountryCode = $v.nationalityCountryCode;
      _birthDate = $v.birthDate;
      _name = $v.name;
      _legalName = $v.legalName;
      _description = $v.description;
      _categoryId = $v.categoryId;
      _locationName = $v.locationName;
      _locationType = $v.locationType;
      _timezone = $v.timezone;
      _countryCode = $v.countryCode;
      _administrativeArea = $v.administrativeArea;
      _locality = $v.locality;
      _district = $v.district;
      _streetAddress = $v.streetAddress;
      _addressNotes = $v.addressNotes;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _businessContactType = $v.businessContactType;
      _businessContactValue = $v.businessContactValue;
      _businessContactLabel = $v.businessContactLabel;
      _deviceName = $v.deviceName;
      _passwordConfirmation = $v.passwordConfirmation;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterRequest other) {
    _$v = other as _$RegisterRequest;
  }

  @override
  void update(void Function(RegisterRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterRequest build() => _build();

  _$RegisterRequest _build() {
    _$RegisterRequest _$result;
    try {
      _$result = _$v ??
          _$RegisterRequest._(
            username: BuiltValueNullFieldError.checkNotNull(
                username, r'RegisterRequest', 'username'),
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName, r'RegisterRequest', 'displayName'),
            password: BuiltValueNullFieldError.checkNotNull(
                password, r'RegisterRequest', 'password'),
            contactType: BuiltValueNullFieldError.checkNotNull(
                contactType, r'RegisterRequest', 'contactType'),
            contactValue: contactValue.build(),
            accountType: BuiltValueNullFieldError.checkNotNull(
                accountType, r'RegisterRequest', 'accountType'),
            nationalityCountryCode: nationalityCountryCode,
            birthDate: birthDate,
            name: name,
            legalName: legalName,
            description: description,
            categoryId: categoryId,
            locationName: locationName,
            locationType: locationType,
            timezone: timezone,
            countryCode: countryCode,
            administrativeArea: administrativeArea,
            locality: locality,
            district: district,
            streetAddress: streetAddress,
            addressNotes: addressNotes,
            latitude: latitude,
            longitude: longitude,
            businessContactType: businessContactType,
            businessContactValue: businessContactValue,
            businessContactLabel: businessContactLabel,
            deviceName: BuiltValueNullFieldError.checkNotNull(
                deviceName, r'RegisterRequest', 'deviceName'),
            passwordConfirmation: BuiltValueNullFieldError.checkNotNull(
                passwordConfirmation,
                r'RegisterRequest',
                'passwordConfirmation'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'contactValue';
        contactValue.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RegisterRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
