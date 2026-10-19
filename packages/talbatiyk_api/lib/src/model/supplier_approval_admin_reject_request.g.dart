// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_approval_admin_reject_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierApprovalAdminRejectRequest
    extends SupplierApprovalAdminRejectRequest {
  @override
  final String reviewNote;

  factory _$SupplierApprovalAdminRejectRequest(
          [void Function(SupplierApprovalAdminRejectRequestBuilder)?
              updates]) =>
      (SupplierApprovalAdminRejectRequestBuilder()..update(updates))._build();

  _$SupplierApprovalAdminRejectRequest._({required this.reviewNote})
      : super._();
  @override
  SupplierApprovalAdminRejectRequest rebuild(
          void Function(SupplierApprovalAdminRejectRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierApprovalAdminRejectRequestBuilder toBuilder() =>
      SupplierApprovalAdminRejectRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierApprovalAdminRejectRequest &&
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
    return (newBuiltValueToStringHelper(r'SupplierApprovalAdminRejectRequest')
          ..add('reviewNote', reviewNote))
        .toString();
  }
}

class SupplierApprovalAdminRejectRequestBuilder
    implements
        Builder<SupplierApprovalAdminRejectRequest,
            SupplierApprovalAdminRejectRequestBuilder> {
  _$SupplierApprovalAdminRejectRequest? _$v;

  String? _reviewNote;
  String? get reviewNote => _$this._reviewNote;
  set reviewNote(String? reviewNote) => _$this._reviewNote = reviewNote;

  SupplierApprovalAdminRejectRequestBuilder() {
    SupplierApprovalAdminRejectRequest._defaults(this);
  }

  SupplierApprovalAdminRejectRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reviewNote = $v.reviewNote;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierApprovalAdminRejectRequest other) {
    _$v = other as _$SupplierApprovalAdminRejectRequest;
  }

  @override
  void update(
      void Function(SupplierApprovalAdminRejectRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierApprovalAdminRejectRequest build() => _build();

  _$SupplierApprovalAdminRejectRequest _build() {
    final _$result = _$v ??
        _$SupplierApprovalAdminRejectRequest._(
          reviewNote: BuiltValueNullFieldError.checkNotNull(
              reviewNote, r'SupplierApprovalAdminRejectRequest', 'reviewNote'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
