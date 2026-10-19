// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_approval_admin_index200_response_data_inner_requested_by.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy
    extends SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy {
  @override
  final String id;
  @override
  final String displayName;

  factory _$SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy(
          [void Function(
                  SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder)?
              updates]) =>
      (SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder()
            ..update(updates))
          ._build();

  _$SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy._(
      {required this.id, required this.displayName})
      : super._();
  @override
  SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy rebuild(
          void Function(
                  SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder
      toBuilder() =>
          SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy &&
        id == other.id &&
        displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy')
          ..add('id', id)
          ..add('displayName', displayName))
        .toString();
  }
}

class SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder
    implements
        Builder<SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy,
            SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder> {
  _$SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder() {
    SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy._defaults(this);
  }

  SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy other) {
    _$v = other as _$SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy;
  }

  @override
  void update(
      void Function(
              SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy build() => _build();

  _$SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy _build() {
    final _$result = _$v ??
        _$SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy._(
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy',
              'id'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName,
              r'SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy',
              'displayName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
