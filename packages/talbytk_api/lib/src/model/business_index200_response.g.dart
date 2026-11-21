// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_index200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessIndex200Response extends BusinessIndex200Response {
  @override
  final BuiltList<BusinessResource> data;

  factory _$BusinessIndex200Response(
          [void Function(BusinessIndex200ResponseBuilder)? updates]) =>
      (BusinessIndex200ResponseBuilder()..update(updates))._build();

  _$BusinessIndex200Response._({required this.data}) : super._();
  @override
  BusinessIndex200Response rebuild(
          void Function(BusinessIndex200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessIndex200ResponseBuilder toBuilder() =>
      BusinessIndex200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessIndex200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'BusinessIndex200Response')
          ..add('data', data))
        .toString();
  }
}

class BusinessIndex200ResponseBuilder
    implements
        Builder<BusinessIndex200Response, BusinessIndex200ResponseBuilder> {
  _$BusinessIndex200Response? _$v;

  ListBuilder<BusinessResource>? _data;
  ListBuilder<BusinessResource> get data =>
      _$this._data ??= ListBuilder<BusinessResource>();
  set data(ListBuilder<BusinessResource>? data) => _$this._data = data;

  BusinessIndex200ResponseBuilder() {
    BusinessIndex200Response._defaults(this);
  }

  BusinessIndex200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessIndex200Response other) {
    _$v = other as _$BusinessIndex200Response;
  }

  @override
  void update(void Function(BusinessIndex200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessIndex200Response build() => _build();

  _$BusinessIndex200Response _build() {
    _$BusinessIndex200Response _$result;
    try {
      _$result = _$v ??
          _$BusinessIndex200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BusinessIndex200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
