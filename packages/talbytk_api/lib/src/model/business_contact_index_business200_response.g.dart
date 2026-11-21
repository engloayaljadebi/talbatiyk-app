// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_contact_index_business200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessContactIndexBusiness200Response
    extends BusinessContactIndexBusiness200Response {
  @override
  final BuiltList<BusinessContactResource> data;

  factory _$BusinessContactIndexBusiness200Response(
          [void Function(BusinessContactIndexBusiness200ResponseBuilder)?
              updates]) =>
      (BusinessContactIndexBusiness200ResponseBuilder()..update(updates))
          ._build();

  _$BusinessContactIndexBusiness200Response._({required this.data}) : super._();
  @override
  BusinessContactIndexBusiness200Response rebuild(
          void Function(BusinessContactIndexBusiness200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessContactIndexBusiness200ResponseBuilder toBuilder() =>
      BusinessContactIndexBusiness200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessContactIndexBusiness200Response &&
        data == other.data;
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
    return (newBuiltValueToStringHelper(
            r'BusinessContactIndexBusiness200Response')
          ..add('data', data))
        .toString();
  }
}

class BusinessContactIndexBusiness200ResponseBuilder
    implements
        Builder<BusinessContactIndexBusiness200Response,
            BusinessContactIndexBusiness200ResponseBuilder> {
  _$BusinessContactIndexBusiness200Response? _$v;

  ListBuilder<BusinessContactResource>? _data;
  ListBuilder<BusinessContactResource> get data =>
      _$this._data ??= ListBuilder<BusinessContactResource>();
  set data(ListBuilder<BusinessContactResource>? data) => _$this._data = data;

  BusinessContactIndexBusiness200ResponseBuilder() {
    BusinessContactIndexBusiness200Response._defaults(this);
  }

  BusinessContactIndexBusiness200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessContactIndexBusiness200Response other) {
    _$v = other as _$BusinessContactIndexBusiness200Response;
  }

  @override
  void update(
      void Function(BusinessContactIndexBusiness200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessContactIndexBusiness200Response build() => _build();

  _$BusinessContactIndexBusiness200Response _build() {
    _$BusinessContactIndexBusiness200Response _$result;
    try {
      _$result = _$v ??
          _$BusinessContactIndexBusiness200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BusinessContactIndexBusiness200Response',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
