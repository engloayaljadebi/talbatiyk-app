// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_approval_admin_approve200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierApprovalAdminApprove200ResponseData
    extends SupplierApprovalAdminApprove200ResponseData {
  @override
  final String id;
  @override
  final String? businessId;
  @override
  final String status;
  @override
  final String? reviewedByUserId;
  @override
  final String? reviewedAt;
  @override
  final String? reviewNote;

  factory _$SupplierApprovalAdminApprove200ResponseData(
          [void Function(SupplierApprovalAdminApprove200ResponseDataBuilder)?
              updates]) =>
      (SupplierApprovalAdminApprove200ResponseDataBuilder()..update(updates))
          ._build();

  _$SupplierApprovalAdminApprove200ResponseData._(
      {required this.id,
      this.businessId,
      required this.status,
      this.reviewedByUserId,
      this.reviewedAt,
      this.reviewNote})
      : super._();
  @override
  SupplierApprovalAdminApprove200ResponseData rebuild(
          void Function(SupplierApprovalAdminApprove200ResponseDataBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierApprovalAdminApprove200ResponseDataBuilder toBuilder() =>
      SupplierApprovalAdminApprove200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierApprovalAdminApprove200ResponseData &&
        id == other.id &&
        businessId == other.businessId &&
        status == other.status &&
        reviewedByUserId == other.reviewedByUserId &&
        reviewedAt == other.reviewedAt &&
        reviewNote == other.reviewNote;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, businessId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, reviewedByUserId.hashCode);
    _$hash = $jc(_$hash, reviewedAt.hashCode);
    _$hash = $jc(_$hash, reviewNote.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SupplierApprovalAdminApprove200ResponseData')
          ..add('id', id)
          ..add('businessId', businessId)
          ..add('status', status)
          ..add('reviewedByUserId', reviewedByUserId)
          ..add('reviewedAt', reviewedAt)
          ..add('reviewNote', reviewNote))
        .toString();
  }
}

class SupplierApprovalAdminApprove200ResponseDataBuilder
    implements
        Builder<SupplierApprovalAdminApprove200ResponseData,
            SupplierApprovalAdminApprove200ResponseDataBuilder> {
  _$SupplierApprovalAdminApprove200ResponseData? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _businessId;
  String? get businessId => _$this._businessId;
  set businessId(String? businessId) => _$this._businessId = businessId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _reviewedByUserId;
  String? get reviewedByUserId => _$this._reviewedByUserId;
  set reviewedByUserId(String? reviewedByUserId) =>
      _$this._reviewedByUserId = reviewedByUserId;

  String? _reviewedAt;
  String? get reviewedAt => _$this._reviewedAt;
  set reviewedAt(String? reviewedAt) => _$this._reviewedAt = reviewedAt;

  String? _reviewNote;
  String? get reviewNote => _$this._reviewNote;
  set reviewNote(String? reviewNote) => _$this._reviewNote = reviewNote;

  SupplierApprovalAdminApprove200ResponseDataBuilder() {
    SupplierApprovalAdminApprove200ResponseData._defaults(this);
  }

  SupplierApprovalAdminApprove200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _businessId = $v.businessId;
      _status = $v.status;
      _reviewedByUserId = $v.reviewedByUserId;
      _reviewedAt = $v.reviewedAt;
      _reviewNote = $v.reviewNote;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierApprovalAdminApprove200ResponseData other) {
    _$v = other as _$SupplierApprovalAdminApprove200ResponseData;
  }

  @override
  void update(
      void Function(SupplierApprovalAdminApprove200ResponseDataBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierApprovalAdminApprove200ResponseData build() => _build();

  _$SupplierApprovalAdminApprove200ResponseData _build() {
    final _$result = _$v ??
        _$SupplierApprovalAdminApprove200ResponseData._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'SupplierApprovalAdminApprove200ResponseData', 'id'),
          businessId: businessId,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'SupplierApprovalAdminApprove200ResponseData', 'status'),
          reviewedByUserId: reviewedByUserId,
          reviewedAt: reviewedAt,
          reviewNote: reviewNote,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
