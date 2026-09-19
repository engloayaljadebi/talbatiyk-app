// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_follow_show200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierFollowShow200Response extends SupplierFollowShow200Response {
  @override
  final SupplierFollowShow200ResponseData data;

  factory _$SupplierFollowShow200Response(
          [void Function(SupplierFollowShow200ResponseBuilder)? updates]) =>
      (SupplierFollowShow200ResponseBuilder()..update(updates))._build();

  _$SupplierFollowShow200Response._({required this.data}) : super._();
  @override
  SupplierFollowShow200Response rebuild(
          void Function(SupplierFollowShow200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierFollowShow200ResponseBuilder toBuilder() =>
      SupplierFollowShow200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierFollowShow200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'SupplierFollowShow200Response')
          ..add('data', data))
        .toString();
  }
}

class SupplierFollowShow200ResponseBuilder
    implements
        Builder<SupplierFollowShow200Response,
            SupplierFollowShow200ResponseBuilder> {
  _$SupplierFollowShow200Response? _$v;

  SupplierFollowShow200ResponseDataBuilder? _data;
  SupplierFollowShow200ResponseDataBuilder get data =>
      _$this._data ??= SupplierFollowShow200ResponseDataBuilder();
  set data(SupplierFollowShow200ResponseDataBuilder? data) =>
      _$this._data = data;

  SupplierFollowShow200ResponseBuilder() {
    SupplierFollowShow200Response._defaults(this);
  }

  SupplierFollowShow200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierFollowShow200Response other) {
    _$v = other as _$SupplierFollowShow200Response;
  }

  @override
  void update(void Function(SupplierFollowShow200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierFollowShow200Response build() => _build();

  _$SupplierFollowShow200Response _build() {
    _$SupplierFollowShow200Response _$result;
    try {
      _$result = _$v ??
          _$SupplierFollowShow200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupplierFollowShow200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
