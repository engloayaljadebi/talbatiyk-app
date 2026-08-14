// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_store201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessStore201Response extends BusinessStore201Response {
  @override
  final BusinessResource data;

  factory _$BusinessStore201Response(
          [void Function(BusinessStore201ResponseBuilder)? updates]) =>
      (BusinessStore201ResponseBuilder()..update(updates))._build();

  _$BusinessStore201Response._({required this.data}) : super._();
  @override
  BusinessStore201Response rebuild(
          void Function(BusinessStore201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessStore201ResponseBuilder toBuilder() =>
      BusinessStore201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessStore201Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'BusinessStore201Response')
          ..add('data', data))
        .toString();
  }
}

class BusinessStore201ResponseBuilder
    implements
        Builder<BusinessStore201Response, BusinessStore201ResponseBuilder> {
  _$BusinessStore201Response? _$v;

  BusinessResourceBuilder? _data;
  BusinessResourceBuilder get data =>
      _$this._data ??= BusinessResourceBuilder();
  set data(BusinessResourceBuilder? data) => _$this._data = data;

  BusinessStore201ResponseBuilder() {
    BusinessStore201Response._defaults(this);
  }

  BusinessStore201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessStore201Response other) {
    _$v = other as _$BusinessStore201Response;
  }

  @override
  void update(void Function(BusinessStore201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessStore201Response build() => _build();

  _$BusinessStore201Response _build() {
    _$BusinessStore201Response _$result;
    try {
      _$result = _$v ??
          _$BusinessStore201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BusinessStore201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
