// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_location_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessLocationResource extends BusinessLocationResource {
  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final String timezone;
  @override
  final BusinessLocationResourceAddress address;
  @override
  final BusinessLocationResourceCoordinates coordinates;
  @override
  final bool isPrimary;
  @override
  final String status;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  factory _$BusinessLocationResource(
          [void Function(BusinessLocationResourceBuilder)? updates]) =>
      (BusinessLocationResourceBuilder()..update(updates))._build();

  _$BusinessLocationResource._(
      {required this.id,
      required this.name,
      required this.type,
      required this.timezone,
      required this.address,
      required this.coordinates,
      required this.isPrimary,
      required this.status,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  BusinessLocationResource rebuild(
          void Function(BusinessLocationResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessLocationResourceBuilder toBuilder() =>
      BusinessLocationResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessLocationResource &&
        id == other.id &&
        name == other.name &&
        type == other.type &&
        timezone == other.timezone &&
        address == other.address &&
        coordinates == other.coordinates &&
        isPrimary == other.isPrimary &&
        status == other.status &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, coordinates.hashCode);
    _$hash = $jc(_$hash, isPrimary.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BusinessLocationResource')
          ..add('id', id)
          ..add('name', name)
          ..add('type', type)
          ..add('timezone', timezone)
          ..add('address', address)
          ..add('coordinates', coordinates)
          ..add('isPrimary', isPrimary)
          ..add('status', status)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class BusinessLocationResourceBuilder
    implements
        Builder<BusinessLocationResource, BusinessLocationResourceBuilder> {
  _$BusinessLocationResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  BusinessLocationResourceAddressBuilder? _address;
  BusinessLocationResourceAddressBuilder get address =>
      _$this._address ??= BusinessLocationResourceAddressBuilder();
  set address(BusinessLocationResourceAddressBuilder? address) =>
      _$this._address = address;

  BusinessLocationResourceCoordinatesBuilder? _coordinates;
  BusinessLocationResourceCoordinatesBuilder get coordinates =>
      _$this._coordinates ??= BusinessLocationResourceCoordinatesBuilder();
  set coordinates(BusinessLocationResourceCoordinatesBuilder? coordinates) =>
      _$this._coordinates = coordinates;

  bool? _isPrimary;
  bool? get isPrimary => _$this._isPrimary;
  set isPrimary(bool? isPrimary) => _$this._isPrimary = isPrimary;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  String? _updatedAt;
  String? get updatedAt => _$this._updatedAt;
  set updatedAt(String? updatedAt) => _$this._updatedAt = updatedAt;

  BusinessLocationResourceBuilder() {
    BusinessLocationResource._defaults(this);
  }

  BusinessLocationResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _type = $v.type;
      _timezone = $v.timezone;
      _address = $v.address.toBuilder();
      _coordinates = $v.coordinates.toBuilder();
      _isPrimary = $v.isPrimary;
      _status = $v.status;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessLocationResource other) {
    _$v = other as _$BusinessLocationResource;
  }

  @override
  void update(void Function(BusinessLocationResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessLocationResource build() => _build();

  _$BusinessLocationResource _build() {
    _$BusinessLocationResource _$result;
    try {
      _$result = _$v ??
          _$BusinessLocationResource._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'BusinessLocationResource', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'BusinessLocationResource', 'name'),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'BusinessLocationResource', 'type'),
            timezone: BuiltValueNullFieldError.checkNotNull(
                timezone, r'BusinessLocationResource', 'timezone'),
            address: address.build(),
            coordinates: coordinates.build(),
            isPrimary: BuiltValueNullFieldError.checkNotNull(
                isPrimary, r'BusinessLocationResource', 'isPrimary'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'BusinessLocationResource', 'status'),
            createdAt: createdAt,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'address';
        address.build();
        _$failedField = 'coordinates';
        coordinates.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BusinessLocationResource', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
