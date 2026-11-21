// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_location_resource_address.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessLocationResourceAddress
    extends BusinessLocationResourceAddress {
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
  final String? notes;

  factory _$BusinessLocationResourceAddress(
          [void Function(BusinessLocationResourceAddressBuilder)? updates]) =>
      (BusinessLocationResourceAddressBuilder()..update(updates))._build();

  _$BusinessLocationResourceAddress._(
      {required this.countryCode,
      this.administrativeArea,
      this.locality,
      this.district,
      this.streetAddress,
      this.notes})
      : super._();
  @override
  BusinessLocationResourceAddress rebuild(
          void Function(BusinessLocationResourceAddressBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessLocationResourceAddressBuilder toBuilder() =>
      BusinessLocationResourceAddressBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessLocationResourceAddress &&
        countryCode == other.countryCode &&
        administrativeArea == other.administrativeArea &&
        locality == other.locality &&
        district == other.district &&
        streetAddress == other.streetAddress &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, countryCode.hashCode);
    _$hash = $jc(_$hash, administrativeArea.hashCode);
    _$hash = $jc(_$hash, locality.hashCode);
    _$hash = $jc(_$hash, district.hashCode);
    _$hash = $jc(_$hash, streetAddress.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BusinessLocationResourceAddress')
          ..add('countryCode', countryCode)
          ..add('administrativeArea', administrativeArea)
          ..add('locality', locality)
          ..add('district', district)
          ..add('streetAddress', streetAddress)
          ..add('notes', notes))
        .toString();
  }
}

class BusinessLocationResourceAddressBuilder
    implements
        Builder<BusinessLocationResourceAddress,
            BusinessLocationResourceAddressBuilder> {
  _$BusinessLocationResourceAddress? _$v;

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

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  BusinessLocationResourceAddressBuilder() {
    BusinessLocationResourceAddress._defaults(this);
  }

  BusinessLocationResourceAddressBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _countryCode = $v.countryCode;
      _administrativeArea = $v.administrativeArea;
      _locality = $v.locality;
      _district = $v.district;
      _streetAddress = $v.streetAddress;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessLocationResourceAddress other) {
    _$v = other as _$BusinessLocationResourceAddress;
  }

  @override
  void update(void Function(BusinessLocationResourceAddressBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessLocationResourceAddress build() => _build();

  _$BusinessLocationResourceAddress _build() {
    final _$result = _$v ??
        _$BusinessLocationResourceAddress._(
          countryCode: BuiltValueNullFieldError.checkNotNull(
              countryCode, r'BusinessLocationResourceAddress', 'countryCode'),
          administrativeArea: administrativeArea,
          locality: locality,
          district: district,
          streetAddress: streetAddress,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
