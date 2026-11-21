// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_approval_admin_approve200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierApprovalAdminApprove200Response
    extends SupplierApprovalAdminApprove200Response {
  @override
  final SupplierApprovalAdminApprove200ResponseData data;

  factory _$SupplierApprovalAdminApprove200Response(
          [void Function(SupplierApprovalAdminApprove200ResponseBuilder)?
              updates]) =>
      (SupplierApprovalAdminApprove200ResponseBuilder()..update(updates))
          ._build();

  _$SupplierApprovalAdminApprove200Response._({required this.data}) : super._();
  @override
  SupplierApprovalAdminApprove200Response rebuild(
          void Function(SupplierApprovalAdminApprove200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierApprovalAdminApprove200ResponseBuilder toBuilder() =>
      SupplierApprovalAdminApprove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierApprovalAdminApprove200Response &&
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
            r'SupplierApprovalAdminApprove200Response')
          ..add('data', data))
        .toString();
  }
}

class SupplierApprovalAdminApprove200ResponseBuilder
    implements
        Builder<SupplierApprovalAdminApprove200Response,
            SupplierApprovalAdminApprove200ResponseBuilder> {
  _$SupplierApprovalAdminApprove200Response? _$v;

  SupplierApprovalAdminApprove200ResponseDataBuilder? _data;
  SupplierApprovalAdminApprove200ResponseDataBuilder get data =>
      _$this._data ??= SupplierApprovalAdminApprove200ResponseDataBuilder();
  set data(SupplierApprovalAdminApprove200ResponseDataBuilder? data) =>
      _$this._data = data;

  SupplierApprovalAdminApprove200ResponseBuilder() {
    SupplierApprovalAdminApprove200Response._defaults(this);
  }

  SupplierApprovalAdminApprove200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierApprovalAdminApprove200Response other) {
    _$v = other as _$SupplierApprovalAdminApprove200Response;
  }

  @override
  void update(
      void Function(SupplierApprovalAdminApprove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierApprovalAdminApprove200Response build() => _build();

  _$SupplierApprovalAdminApprove200Response _build() {
    _$SupplierApprovalAdminApprove200Response _$result;
    try {
      _$result = _$v ??
          _$SupplierApprovalAdminApprove200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupplierApprovalAdminApprove200Response',
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
