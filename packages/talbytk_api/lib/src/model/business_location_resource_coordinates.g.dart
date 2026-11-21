// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_location_resource_coordinates.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessLocationResourceCoordinates
    extends BusinessLocationResourceCoordinates {
  @override
  final num? latitude;
  @override
  final num? longitude;

  factory _$BusinessLocationResourceCoordinates(
          [void Function(BusinessLocationResourceCoordinatesBuilder)?
              updates]) =>
      (BusinessLocationResourceCoordinatesBuilder()..update(updates))._build();

  _$BusinessLocationResourceCoordinates._({this.latitude, this.longitude})
      : super._();
  @override
  BusinessLocationResourceCoordinates rebuild(
          void Function(BusinessLocationResourceCoordinatesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessLocationResourceCoordinatesBuilder toBuilder() =>
      BusinessLocationResourceCoordinatesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessLocationResourceCoordinates &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BusinessLocationResourceCoordinates')
          ..add('latitude', latitude)
          ..add('longitude', longitude))
        .toString();
  }
}

class BusinessLocationResourceCoordinatesBuilder
    implements
        Builder<BusinessLocationResourceCoordinates,
            BusinessLocationResourceCoordinatesBuilder> {
  _$BusinessLocationResourceCoordinates? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  BusinessLocationResourceCoordinatesBuilder() {
    BusinessLocationResourceCoordinates._defaults(this);
  }

  BusinessLocationResourceCoordinatesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessLocationResourceCoordinates other) {
    _$v = other as _$BusinessLocationResourceCoordinates;
  }

  @override
  void update(
      void Function(BusinessLocationResourceCoordinatesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessLocationResourceCoordinates build() => _build();

  _$BusinessLocationResourceCoordinates _build() {
    final _$result = _$v ??
        _$BusinessLocationResourceCoordinates._(
          latitude: latitude,
          longitude: longitude,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
