// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_approval_admin_index200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierApprovalAdminIndex200Response
    extends SupplierApprovalAdminIndex200Response {
  @override
  final BuiltList<SupplierApprovalAdminIndex200ResponseDataInner> data;
  @override
  final SupplierApprovalAdminIndex200ResponseMeta meta;

  factory _$SupplierApprovalAdminIndex200Response(
          [void Function(SupplierApprovalAdminIndex200ResponseBuilder)?
              updates]) =>
      (SupplierApprovalAdminIndex200ResponseBuilder()..update(updates))
          ._build();

  _$SupplierApprovalAdminIndex200Response._(
      {required this.data, required this.meta})
      : super._();
  @override
  SupplierApprovalAdminIndex200Response rebuild(
          void Function(SupplierApprovalAdminIndex200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierApprovalAdminIndex200ResponseBuilder toBuilder() =>
      SupplierApprovalAdminIndex200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierApprovalAdminIndex200Response &&
        data == other.data &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SupplierApprovalAdminIndex200Response')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class SupplierApprovalAdminIndex200ResponseBuilder
    implements
        Builder<SupplierApprovalAdminIndex200Response,
            SupplierApprovalAdminIndex200ResponseBuilder> {
  _$SupplierApprovalAdminIndex200Response? _$v;

  ListBuilder<SupplierApprovalAdminIndex200ResponseDataInner>? _data;
  ListBuilder<SupplierApprovalAdminIndex200ResponseDataInner> get data =>
      _$this._data ??=
          ListBuilder<SupplierApprovalAdminIndex200ResponseDataInner>();
  set data(ListBuilder<SupplierApprovalAdminIndex200ResponseDataInner>? data) =>
      _$this._data = data;

  SupplierApprovalAdminIndex200ResponseMetaBuilder? _meta;
  SupplierApprovalAdminIndex200ResponseMetaBuilder get meta =>
      _$this._meta ??= SupplierApprovalAdminIndex200ResponseMetaBuilder();
  set meta(SupplierApprovalAdminIndex200ResponseMetaBuilder? meta) =>
      _$this._meta = meta;

  SupplierApprovalAdminIndex200ResponseBuilder() {
    SupplierApprovalAdminIndex200Response._defaults(this);
  }

  SupplierApprovalAdminIndex200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierApprovalAdminIndex200Response other) {
    _$v = other as _$SupplierApprovalAdminIndex200Response;
  }

  @override
  void update(
      void Function(SupplierApprovalAdminIndex200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierApprovalAdminIndex200Response build() => _build();

  _$SupplierApprovalAdminIndex200Response _build() {
    _$SupplierApprovalAdminIndex200Response _$result;
    try {
      _$result = _$v ??
          _$SupplierApprovalAdminIndex200Response._(
            data: data.build(),
            meta: meta.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupplierApprovalAdminIndex200Response',
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
