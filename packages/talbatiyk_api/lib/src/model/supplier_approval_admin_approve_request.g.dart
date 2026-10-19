// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_approval_admin_approve_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierApprovalAdminApproveRequest
    extends SupplierApprovalAdminApproveRequest {
  @override
  final String? reviewNote;

  factory _$SupplierApprovalAdminApproveRequest(
          [void Function(SupplierApprovalAdminApproveRequestBuilder)?
              updates]) =>
      (SupplierApprovalAdminApproveRequestBuilder()..update(updates))._build();

  _$SupplierApprovalAdminApproveRequest._({this.reviewNote}) : super._();
  @override
  SupplierApprovalAdminApproveRequest rebuild(
          void Function(SupplierApprovalAdminApproveRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierApprovalAdminApproveRequestBuilder toBuilder() =>
      SupplierApprovalAdminApproveRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierApprovalAdminApproveRequest &&
        reviewNote == other.reviewNote;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reviewNote.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SupplierApprovalAdminApproveRequest')
          ..add('reviewNote', reviewNote))
        .toString();
  }
}

class SupplierApprovalAdminApproveRequestBuilder
    implements
        Builder<SupplierApprovalAdminApproveRequest,
            SupplierApprovalAdminApproveRequestBuilder> {
  _$SupplierApprovalAdminApproveRequest? _$v;

  String? _reviewNote;
  String? get reviewNote => _$this._reviewNote;
  set reviewNote(String? reviewNote) => _$this._reviewNote = reviewNote;

  SupplierApprovalAdminApproveRequestBuilder() {
    SupplierApprovalAdminApproveRequest._defaults(this);
  }

  SupplierApprovalAdminApproveRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reviewNote = $v.reviewNote;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierApprovalAdminApproveRequest other) {
    _$v = other as _$SupplierApprovalAdminApproveRequest;
  }

  @override
  void update(
      void Function(SupplierApprovalAdminApproveRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierApprovalAdminApproveRequest build() => _build();

  _$SupplierApprovalAdminApproveRequest _build() {
    final _$result = _$v ??
        _$SupplierApprovalAdminApproveRequest._(
          reviewNote: reviewNote,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
