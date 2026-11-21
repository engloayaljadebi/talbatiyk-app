// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_business_location_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateBusinessLocationRequestTypeEnum
    _$createBusinessLocationRequestTypeEnum_branch =
    const CreateBusinessLocationRequestTypeEnum._('branch');
const CreateBusinessLocationRequestTypeEnum
    _$createBusinessLocationRequestTypeEnum_office =
    const CreateBusinessLocationRequestTypeEnum._('office');
const CreateBusinessLocationRequestTypeEnum
    _$createBusinessLocationRequestTypeEnum_warehouse =
    const CreateBusinessLocationRequestTypeEnum._('warehouse');
const CreateBusinessLocationRequestTypeEnum
    _$createBusinessLocationRequestTypeEnum_store =
    const CreateBusinessLocationRequestTypeEnum._('store');

CreateBusinessLocationRequestTypeEnum
    _$createBusinessLocationRequestTypeEnumValueOf(String name) {
  switch (name) {
    case 'branch':
      return _$createBusinessLocationRequestTypeEnum_branch;
    case 'office':
      return _$createBusinessLocationRequestTypeEnum_office;
    case 'warehouse':
      return _$createBusinessLocationRequestTypeEnum_warehouse;
    case 'store':
      return _$createBusinessLocationRequestTypeEnum_store;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateBusinessLocationRequestTypeEnum>
    _$createBusinessLocationRequestTypeEnumValues = BuiltSet<
        CreateBusinessLocationRequestTypeEnum>(const <CreateBusinessLocationRequestTypeEnum>[
  _$createBusinessLocationRequestTypeEnum_branch,
  _$createBusinessLocationRequestTypeEnum_office,
  _$createBusinessLocationRequestTypeEnum_warehouse,
  _$createBusinessLocationRequestTypeEnum_store,
]);

const CreateBusinessLocationRequestStatusEnum
    _$createBusinessLocationRequestStatusEnum_active =
    const CreateBusinessLocationRequestStatusEnum._('active');
const CreateBusinessLocationRequestStatusEnum
    _$createBusinessLocationRequestStatusEnum_temporarilyClosed =
    const CreateBusinessLocationRequestStatusEnum._('temporarilyClosed');
const CreateBusinessLocationRequestStatusEnum
    _$createBusinessLocationRequestStatusEnum_closed =
    const CreateBusinessLocationRequestStatusEnum._('closed');

CreateBusinessLocationRequestStatusEnum
    _$createBusinessLocationRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$createBusinessLocationRequestStatusEnum_active;
    case 'temporarilyClosed':
      return _$createBusinessLocationRequestStatusEnum_temporarilyClosed;
    case 'closed':
      return _$createBusinessLocationRequestStatusEnum_closed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateBusinessLocationRequestStatusEnum>
    _$createBusinessLocationRequestStatusEnumValues = BuiltSet<
        CreateBusinessLocationRequestStatusEnum>(const <CreateBusinessLocationRequestStatusEnum>[
  _$createBusinessLocationRequestStatusEnum_active,
  _$createBusinessLocationRequestStatusEnum_temporarilyClosed,
  _$createBusinessLocationRequestStatusEnum_closed,
]);

Serializer<CreateBusinessLocationRequestTypeEnum>
    _$createBusinessLocationRequestTypeEnumSerializer =
    _$CreateBusinessLocationRequestTypeEnumSerializer();
Serializer<CreateBusinessLocationRequestStatusEnum>
    _$createBusinessLocationRequestStatusEnumSerializer =
    _$CreateBusinessLocationRequestStatusEnumSerializer();

class _$CreateBusinessLocationRequestTypeEnumSerializer
    implements PrimitiveSerializer<CreateBusinessLocationRequestTypeEnum> {
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
    CreateBusinessLocationRequestTypeEnum
  ];
  @override
  final String wireName = 'CreateBusinessLocationRequestTypeEnum';

  @override
  Object serialize(
          Serializers serializers, CreateBusinessLocationRequestTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateBusinessLocationRequestTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateBusinessLocationRequestTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateBusinessLocationRequestStatusEnumSerializer
    implements PrimitiveSerializer<CreateBusinessLocationRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'temporarilyClosed': 'temporarily_closed',
    'closed': 'closed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'temporarily_closed': 'temporarilyClosed',
    'closed': 'closed',
  };

  @override
  final Iterable<Type> types = const <Type>[
    CreateBusinessLocationRequestStatusEnum
  ];
  @override
  final String wireName = 'CreateBusinessLocationRequestStatusEnum';

  @override
  Object serialize(Serializers serializers,
          CreateBusinessLocationRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateBusinessLocationRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateBusinessLocationRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateBusinessLocationRequest extends CreateBusinessLocationRequest {
  @override
  final String name;
  @override
  final CreateBusinessLocationRequestTypeEnum type;
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
  @override
  final CreateBusinessLocationRequestStatusEnum? status;

  factory _$CreateBusinessLocationRequest(
          [void Function(CreateBusinessLocationRequestBuilder)? updates]) =>
      (CreateBusinessLocationRequestBuilder()..update(updates))._build();

  _$CreateBusinessLocationRequest._(
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
      this.longitude,
      this.status})
      : super._();
  @override
  CreateBusinessLocationRequest rebuild(
          void Function(CreateBusinessLocationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateBusinessLocationRequestBuilder toBuilder() =>
      CreateBusinessLocationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateBusinessLocationRequest &&
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
        longitude == other.longitude &&
        status == other.status;
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
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateBusinessLocationRequest')
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
          ..add('longitude', longitude)
          ..add('status', status))
        .toString();
  }
}

class CreateBusinessLocationRequestBuilder
    implements
        Builder<CreateBusinessLocationRequest,
            CreateBusinessLocationRequestBuilder> {
  _$CreateBusinessLocationRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CreateBusinessLocationRequestTypeEnum? _type;
  CreateBusinessLocationRequestTypeEnum? get type => _$this._type;
  set type(CreateBusinessLocationRequestTypeEnum? type) => _$this._type = type;

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

  CreateBusinessLocationRequestStatusEnum? _status;
  CreateBusinessLocationRequestStatusEnum? get status => _$this._status;
  set status(CreateBusinessLocationRequestStatusEnum? status) =>
      _$this._status = status;

  CreateBusinessLocationRequestBuilder() {
    CreateBusinessLocationRequest._defaults(this);
  }

  CreateBusinessLocationRequestBuilder get _$this {
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
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateBusinessLocationRequest other) {
    _$v = other as _$CreateBusinessLocationRequest;
  }

  @override
  void update(void Function(CreateBusinessLocationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateBusinessLocationRequest build() => _build();

  _$CreateBusinessLocationRequest _build() {
    final _$result = _$v ??
        _$CreateBusinessLocationRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CreateBusinessLocationRequest', 'name'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'CreateBusinessLocationRequest', 'type'),
          timezone: BuiltValueNullFieldError.checkNotNull(
              timezone, r'CreateBusinessLocationRequest', 'timezone'),
          countryCode: BuiltValueNullFieldError.checkNotNull(
              countryCode, r'CreateBusinessLocationRequest', 'countryCode'),
          administrativeArea: administrativeArea,
          locality: locality,
          district: district,
          streetAddress: streetAddress,
          addressNotes: addressNotes,
          latitude: latitude,
          longitude: longitude,
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
