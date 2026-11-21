// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_approval_admin_index200_response_data_inner_business.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierApprovalAdminIndex200ResponseDataInnerBusiness
    extends SupplierApprovalAdminIndex200ResponseDataInnerBusiness {
  @override
  final String id;
  @override
  final String name;
  @override
  final String status;

  factory _$SupplierApprovalAdminIndex200ResponseDataInnerBusiness(
          [void Function(
                  SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder)?
              updates]) =>
      (SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder()
            ..update(updates))
          ._build();

  _$SupplierApprovalAdminIndex200ResponseDataInnerBusiness._(
      {required this.id, required this.name, required this.status})
      : super._();
  @override
  SupplierApprovalAdminIndex200ResponseDataInnerBusiness rebuild(
          void Function(
                  SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder toBuilder() =>
      SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierApprovalAdminIndex200ResponseDataInnerBusiness &&
        id == other.id &&
        name == other.name &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SupplierApprovalAdminIndex200ResponseDataInnerBusiness')
          ..add('id', id)
          ..add('name', name)
          ..add('status', status))
        .toString();
  }
}

class SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder
    implements
        Builder<SupplierApprovalAdminIndex200ResponseDataInnerBusiness,
            SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder> {
  _$SupplierApprovalAdminIndex200ResponseDataInnerBusiness? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder() {
    SupplierApprovalAdminIndex200ResponseDataInnerBusiness._defaults(this);
  }

  SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierApprovalAdminIndex200ResponseDataInnerBusiness other) {
    _$v = other as _$SupplierApprovalAdminIndex200ResponseDataInnerBusiness;
  }

  @override
  void update(
      void Function(
              SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierApprovalAdminIndex200ResponseDataInnerBusiness build() => _build();

  _$SupplierApprovalAdminIndex200ResponseDataInnerBusiness _build() {
    final _$result = _$v ??
        _$SupplierApprovalAdminIndex200ResponseDataInnerBusiness._(
          id: BuiltValueNullFieldError.checkNotNull(id,
              r'SupplierApprovalAdminIndex200ResponseDataInnerBusiness', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'SupplierApprovalAdminIndex200ResponseDataInnerBusiness',
              'name'),
          status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'SupplierApprovalAdminIndex200ResponseDataInnerBusiness',
              'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
