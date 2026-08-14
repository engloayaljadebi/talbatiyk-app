// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_business_location_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateBusinessLocationRequestTypeEnum
    _$updateBusinessLocationRequestTypeEnum_branch =
    const UpdateBusinessLocationRequestTypeEnum._('branch');
const UpdateBusinessLocationRequestTypeEnum
    _$updateBusinessLocationRequestTypeEnum_office =
    const UpdateBusinessLocationRequestTypeEnum._('office');
const UpdateBusinessLocationRequestTypeEnum
    _$updateBusinessLocationRequestTypeEnum_warehouse =
    const UpdateBusinessLocationRequestTypeEnum._('warehouse');
const UpdateBusinessLocationRequestTypeEnum
    _$updateBusinessLocationRequestTypeEnum_store =
    const UpdateBusinessLocationRequestTypeEnum._('store');

UpdateBusinessLocationRequestTypeEnum
    _$updateBusinessLocationRequestTypeEnumValueOf(String name) {
  switch (name) {
    case 'branch':
      return _$updateBusinessLocationRequestTypeEnum_branch;
    case 'office':
      return _$updateBusinessLocationRequestTypeEnum_office;
    case 'warehouse':
      return _$updateBusinessLocationRequestTypeEnum_warehouse;
    case 'store':
      return _$updateBusinessLocationRequestTypeEnum_store;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UpdateBusinessLocationRequestTypeEnum>
    _$updateBusinessLocationRequestTypeEnumValues = BuiltSet<
        UpdateBusinessLocationRequestTypeEnum>(const <UpdateBusinessLocationRequestTypeEnum>[
  _$updateBusinessLocationRequestTypeEnum_branch,
  _$updateBusinessLocationRequestTypeEnum_office,
  _$updateBusinessLocationRequestTypeEnum_warehouse,
  _$updateBusinessLocationRequestTypeEnum_store,
]);

const UpdateBusinessLocationRequestStatusEnum
    _$updateBusinessLocationRequestStatusEnum_active =
    const UpdateBusinessLocationRequestStatusEnum._('active');
const UpdateBusinessLocationRequestStatusEnum
    _$updateBusinessLocationRequestStatusEnum_temporarilyClosed =
    const UpdateBusinessLocationRequestStatusEnum._('temporarilyClosed');
const UpdateBusinessLocationRequestStatusEnum
    _$updateBusinessLocationRequestStatusEnum_closed =
    const UpdateBusinessLocationRequestStatusEnum._('closed');

UpdateBusinessLocationRequestStatusEnum
    _$updateBusinessLocationRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$updateBusinessLocationRequestStatusEnum_active;
    case 'temporarilyClosed':
      return _$updateBusinessLocationRequestStatusEnum_temporarilyClosed;
    case 'closed':
      return _$updateBusinessLocationRequestStatusEnum_closed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UpdateBusinessLocationRequestStatusEnum>
    _$updateBusinessLocationRequestStatusEnumValues = BuiltSet<
        UpdateBusinessLocationRequestStatusEnum>(const <UpdateBusinessLocationRequestStatusEnum>[
  _$updateBusinessLocationRequestStatusEnum_active,
  _$updateBusinessLocationRequestStatusEnum_temporarilyClosed,
  _$updateBusinessLocationRequestStatusEnum_closed,
]);

Serializer<UpdateBusinessLocationRequestTypeEnum>
    _$updateBusinessLocationRequestTypeEnumSerializer =
    _$UpdateBusinessLocationRequestTypeEnumSerializer();
Serializer<UpdateBusinessLocationRequestStatusEnum>
    _$updateBusinessLocationRequestStatusEnumSerializer =
    _$UpdateBusinessLocationRequestStatusEnumSerializer();

class _$UpdateBusinessLocationRequestTypeEnumSerializer
    implements PrimitiveSerializer<UpdateBusinessLocationRequestTypeEnum> {
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
    UpdateBusinessLocationRequestTypeEnum
  ];
  @override
  final String wireName = 'UpdateBusinessLocationRequestTypeEnum';

  @override
  Object serialize(
          Serializers serializers, UpdateBusinessLocationRequestTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UpdateBusinessLocationRequestTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UpdateBusinessLocationRequestTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UpdateBusinessLocationRequestStatusEnumSerializer
    implements PrimitiveSerializer<UpdateBusinessLocationRequestStatusEnum> {
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
    UpdateBusinessLocationRequestStatusEnum
  ];
  @override
  final String wireName = 'UpdateBusinessLocationRequestStatusEnum';

  @override
  Object serialize(Serializers serializers,
          UpdateBusinessLocationRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UpdateBusinessLocationRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UpdateBusinessLocationRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UpdateBusinessLocationRequest extends UpdateBusinessLocationRequest {
  @override
  final String? name;
  @override
  final UpdateBusinessLocationRequestTypeEnum? type;
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
  final UpdateBusinessLocationRequestStatusEnum? status;

  factory _$UpdateBusinessLocationRequest(
          [void Function(UpdateBusinessLocationRequestBuilder)? updates]) =>
      (UpdateBusinessLocationRequestBuilder()..update(updates))._build();

  _$UpdateBusinessLocationRequest._(
      {this.name,
      this.type,
      this.timezone,
      this.countryCode,
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
  UpdateBusinessLocationRequest rebuild(
          void Function(UpdateBusinessLocationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateBusinessLocationRequestBuilder toBuilder() =>
      UpdateBusinessLocationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateBusinessLocationRequest &&
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
    return (newBuiltValueToStringHelper(r'UpdateBusinessLocationRequest')
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

class UpdateBusinessLocationRequestBuilder
    implements
        Builder<UpdateBusinessLocationRequest,
            UpdateBusinessLocationRequestBuilder> {
  _$UpdateBusinessLocationRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  UpdateBusinessLocationRequestTypeEnum? _type;
  UpdateBusinessLocationRequestTypeEnum? get type => _$this._type;
  set type(UpdateBusinessLocationRequestTypeEnum? type) => _$this._type = type;

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

  UpdateBusinessLocationRequestStatusEnum? _status;
  UpdateBusinessLocationRequestStatusEnum? get status => _$this._status;
  set status(UpdateBusinessLocationRequestStatusEnum? status) =>
      _$this._status = status;

  UpdateBusinessLocationRequestBuilder() {
    UpdateBusinessLocationRequest._defaults(this);
  }

  UpdateBusinessLocationRequestBuilder get _$this {
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
  void replace(UpdateBusinessLocationRequest other) {
    _$v = other as _$UpdateBusinessLocationRequest;
  }

  @override
  void update(void Function(UpdateBusinessLocationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateBusinessLocationRequest build() => _build();

  _$UpdateBusinessLocationRequest _build() {
    final _$result = _$v ??
        _$UpdateBusinessLocationRequest._(
          name: name,
          type: type,
          timezone: timezone,
          countryCode: countryCode,
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
