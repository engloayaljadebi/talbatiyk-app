// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_contact_store_business201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessContactStoreBusiness201Response
    extends BusinessContactStoreBusiness201Response {
  @override
  final BusinessContactResource data;

  factory _$BusinessContactStoreBusiness201Response(
          [void Function(BusinessContactStoreBusiness201ResponseBuilder)?
              updates]) =>
      (BusinessContactStoreBusiness201ResponseBuilder()..update(updates))
          ._build();

  _$BusinessContactStoreBusiness201Response._({required this.data}) : super._();
  @override
  BusinessContactStoreBusiness201Response rebuild(
          void Function(BusinessContactStoreBusiness201ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessContactStoreBusiness201ResponseBuilder toBuilder() =>
      BusinessContactStoreBusiness201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessContactStoreBusiness201Response &&
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
            r'BusinessContactStoreBusiness201Response')
          ..add('data', data))
        .toString();
  }
}

class BusinessContactStoreBusiness201ResponseBuilder
    implements
        Builder<BusinessContactStoreBusiness201Response,
            BusinessContactStoreBusiness201ResponseBuilder> {
  _$BusinessContactStoreBusiness201Response? _$v;

  BusinessContactResourceBuilder? _data;
  BusinessContactResourceBuilder get data =>
      _$this._data ??= BusinessContactResourceBuilder();
  set data(BusinessContactResourceBuilder? data) => _$this._data = data;

  BusinessContactStoreBusiness201ResponseBuilder() {
    BusinessContactStoreBusiness201Response._defaults(this);
  }

  BusinessContactStoreBusiness201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessContactStoreBusiness201Response other) {
    _$v = other as _$BusinessContactStoreBusiness201Response;
  }

  @override
  void update(
      void Function(BusinessContactStoreBusiness201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessContactStoreBusiness201Response build() => _build();

  _$BusinessContactStoreBusiness201Response _build() {
    _$BusinessContactStoreBusiness201Response _$result;
    try {
      _$result = _$v ??
          _$BusinessContactStoreBusiness201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BusinessContactStoreBusiness201Response',
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
