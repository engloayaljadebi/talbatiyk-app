// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_location_index200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessLocationIndex200Response
    extends BusinessLocationIndex200Response {
  @override
  final BuiltList<BusinessLocationResource> data;

  factory _$BusinessLocationIndex200Response(
          [void Function(BusinessLocationIndex200ResponseBuilder)? updates]) =>
      (BusinessLocationIndex200ResponseBuilder()..update(updates))._build();

  _$BusinessLocationIndex200Response._({required this.data}) : super._();
  @override
  BusinessLocationIndex200Response rebuild(
          void Function(BusinessLocationIndex200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessLocationIndex200ResponseBuilder toBuilder() =>
      BusinessLocationIndex200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessLocationIndex200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'BusinessLocationIndex200Response')
          ..add('data', data))
        .toString();
  }
}

class BusinessLocationIndex200ResponseBuilder
    implements
        Builder<BusinessLocationIndex200Response,
            BusinessLocationIndex200ResponseBuilder> {
  _$BusinessLocationIndex200Response? _$v;

  ListBuilder<BusinessLocationResource>? _data;
  ListBuilder<BusinessLocationResource> get data =>
      _$this._data ??= ListBuilder<BusinessLocationResource>();
  set data(ListBuilder<BusinessLocationResource>? data) => _$this._data = data;

  BusinessLocationIndex200ResponseBuilder() {
    BusinessLocationIndex200Response._defaults(this);
  }

  BusinessLocationIndex200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessLocationIndex200Response other) {
    _$v = other as _$BusinessLocationIndex200Response;
  }

  @override
  void update(void Function(BusinessLocationIndex200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessLocationIndex200Response build() => _build();

  _$BusinessLocationIndex200Response _build() {
    _$BusinessLocationIndex200Response _$result;
    try {
      _$result = _$v ??
          _$BusinessLocationIndex200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BusinessLocationIndex200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
