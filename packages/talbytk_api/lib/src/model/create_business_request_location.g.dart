// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_business_request_location.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateBusinessRequestLocationTypeEnum
    _$createBusinessRequestLocationTypeEnum_branch =
    const CreateBusinessRequestLocationTypeEnum._('branch');
const CreateBusinessRequestLocationTypeEnum
    _$createBusinessRequestLocationTypeEnum_office =
    const CreateBusinessRequestLocationTypeEnum._('office');
const CreateBusinessRequestLocationTypeEnum
    _$createBusinessRequestLocationTypeEnum_warehouse =
    const CreateBusinessRequestLocationTypeEnum._('warehouse');
const CreateBusinessRequestLocationTypeEnum
    _$createBusinessRequestLocationTypeEnum_store =
    const CreateBusinessRequestLocationTypeEnum._('store');

CreateBusinessRequestLocationTypeEnum
    _$createBusinessRequestLocationTypeEnumValueOf(String name) {
  switch (name) {
    case 'branch':
      return _$createBusinessRequestLocationTypeEnum_branch;
    case 'office':
      return _$createBusinessRequestLocationTypeEnum_office;
    case 'warehouse':
      return _$createBusinessRequestLocationTypeEnum_warehouse;
    case 'store':
      return _$createBusinessRequestLocationTypeEnum_store;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateBusinessRequestLocationTypeEnum>
    _$createBusinessRequestLocationTypeEnumValues = BuiltSet<
        CreateBusinessRequestLocationTypeEnum>(const <CreateBusinessRequestLocationTypeEnum>[
  _$createBusinessRequestLocationTypeEnum_branch,
  _$createBusinessRequestLocationTypeEnum_office,
  _$createBusinessRequestLocationTypeEnum_warehouse,
  _$createBusinessRequestLocationTypeEnum_store,
]);

Serializer<CreateBusinessRequestLocationTypeEnum>
    _$createBusinessRequestLocationTypeEnumSerializer =
    _$CreateBusinessRequestLocationTypeEnumSerializer();

class _$CreateBusinessRequestLocationTypeEnumSerializer
    implements PrimitiveSerializer<CreateBusinessRequestLocationTypeEnum> {
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
  final Iterable<Type> types = const <Type>[
    CreateBusinessRequestLocationTypeEnum
  ];
  @override
  final String wireName = 'CreateBusinessRequestLocationTypeEnum';

  @override
  Object serialize(
          Serializers serializers, CreateBusinessRequestLocationTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateBusinessRequestLocationTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateBusinessRequestLocationTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateBusinessRequestLocation extends CreateBusinessRequestLocation {
  @override
  final String name;
  @override
  final CreateBusinessRequestLocationTypeEnum type;
  @override
  final String timezone;
  @override
  final String countryCode;
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

  factory _$CreateBusinessRequestLocation(
          [void Function(CreateBusinessRequestLocationBuilder)? updates]) =>
      (CreateBusinessRequestLocationBuilder()..update(updates))._build();

  _$CreateBusinessRequestLocation._(
      {required this.name,
      required this.type,
      required this.timezone,
      required this.countryCode,
      this.administrativeArea,
      this.locality,
      this.district,
      this.streetAddress,
      this.addressNotes,
      this.latitude,
      this.longitude})
      : super._();
  @override
  CreateBusinessRequestLocation rebuild(
          void Function(CreateBusinessRequestLocationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateBusinessRequestLocationBuilder toBuilder() =>
      CreateBusinessRequestLocationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateBusinessRequestLocation &&
        name == other.name &&
        type == other.type &&
        timezone == other.timezone &&
        countryCode == other.countryCode &&
        administrativeArea == other.administrativeArea &&
        locality == other.locality &&
        district == other.district &&
        streetAddress == other.streetAddress &&
        addressNotes == other.addressNotes &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, countryCode.hashCode);
    _$hash = $jc(_$hash, administrativeArea.hashCode);
    _$hash = $jc(_$hash, locality.hashCode);
    _$hash = $jc(_$hash, district.hashCode);
    _$hash = $jc(_$hash, streetAddress.hashCode);
    _$hash = $jc(_$hash, addressNotes.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateBusinessRequestLocation')
          ..add('name', name)
          ..add('type', type)
          ..add('timezone', timezone)
          ..add('countryCode', countryCode)
          ..add('administrativeArea', administrativeArea)
          ..add('locality', locality)
          ..add('district', district)
          ..add('streetAddress', streetAddress)
          ..add('addressNotes', addressNotes)
          ..add('latitude', latitude)
          ..add('longitude', longitude))
        .toString();
  }
}

class CreateBusinessRequestLocationBuilder
    implements
        Builder<CreateBusinessRequestLocation,
            CreateBusinessRequestLocationBuilder> {
  _$CreateBusinessRequestLocation? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CreateBusinessRequestLocationTypeEnum? _type;
  CreateBusinessRequestLocationTypeEnum? get type => _$this._type;
  set type(CreateBusinessRequestLocationTypeEnum? type) => _$this._type = type;

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

  CreateBusinessRequestLocationBuilder() {
    CreateBusinessRequestLocation._defaults(this);
  }

  CreateBusinessRequestLocationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _type = $v.type;
      _timezone = $v.timezone;
      _countryCode = $v.countryCode;
      _administrativeArea = $v.administrativeArea;
      _locality = $v.locality;
      _district = $v.district;
      _streetAddress = $v.streetAddress;
      _addressNotes = $v.addressNotes;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateBusinessRequestLocation other) {
    _$v = other as _$CreateBusinessRequestLocation;
  }

  @override
  void update(void Function(CreateBusinessRequestLocationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateBusinessRequestLocation build() => _build();

  _$CreateBusinessRequestLocation _build() {
    final _$result = _$v ??
        _$CreateBusinessRequestLocation._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CreateBusinessRequestLocation', 'name'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'CreateBusinessRequestLocation', 'type'),
          timezone: BuiltValueNullFieldError.checkNotNull(
              timezone, r'CreateBusinessRequestLocation', 'timezone'),
          countryCode: BuiltValueNullFieldError.checkNotNull(
              countryCode, r'CreateBusinessRequestLocation', 'countryCode'),
          administrativeArea: administrativeArea,
          locality: locality,
          district: district,
          streetAddress: streetAddress,
          addressNotes: addressNotes,
          latitude: latitude,
          longitude: longitude,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
