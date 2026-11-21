// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_location_store201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessLocationStore201Response
    extends BusinessLocationStore201Response {
  @override
  final BusinessLocationResource data;

  factory _$BusinessLocationStore201Response(
          [void Function(BusinessLocationStore201ResponseBuilder)? updates]) =>
      (BusinessLocationStore201ResponseBuilder()..update(updates))._build();

  _$BusinessLocationStore201Response._({required this.data}) : super._();
  @override
  BusinessLocationStore201Response rebuild(
          void Function(BusinessLocationStore201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessLocationStore201ResponseBuilder toBuilder() =>
      BusinessLocationStore201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessLocationStore201Response && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BusinessLocationStore201Response')
          ..add('data', data))
        .toString();
  }
}

class BusinessLocationStore201ResponseBuilder
    implements
        Builder<BusinessLocationStore201Response,
            BusinessLocationStore201ResponseBuilder> {
  _$BusinessLocationStore201Response? _$v;

  BusinessLocationResourceBuilder? _data;
  BusinessLocationResourceBuilder get data =>
      _$this._data ??= BusinessLocationResourceBuilder();
  set data(BusinessLocationResourceBuilder? data) => _$this._data = data;

  BusinessLocationStore201ResponseBuilder() {
    BusinessLocationStore201Response._defaults(this);
  }

  BusinessLocationStore201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessLocationStore201Response other) {
    _$v = other as _$BusinessLocationStore201Response;
  }

  @override
  void update(void Function(BusinessLocationStore201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessLocationStore201Response build() => _build();

  _$BusinessLocationStore201Response _build() {
    _$BusinessLocationStore201Response _$result;
    try {
      _$result = _$v ??
          _$BusinessLocationStore201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BusinessLocationStore201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
