// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_approval_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierApprovalResource extends SupplierApprovalResource {
  @override
  final String id;
  @override
  final String status;
  @override
  final String? requestedAt;
  @override
  final String? reviewedAt;
  @override
  final String? rejectionReason;

  factory _$SupplierApprovalResource(
          [void Function(SupplierApprovalResourceBuilder)? updates]) =>
      (SupplierApprovalResourceBuilder()..update(updates))._build();

  _$SupplierApprovalResource._(
      {required this.id,
      required this.status,
      this.requestedAt,
      this.reviewedAt,
      this.rejectionReason})
      : super._();
  @override
  SupplierApprovalResource rebuild(
          void Function(SupplierApprovalResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierApprovalResourceBuilder toBuilder() =>
      SupplierApprovalResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierApprovalResource &&
        id == other.id &&
        status == other.status &&
        requestedAt == other.requestedAt &&
        reviewedAt == other.reviewedAt &&
        rejectionReason == other.rejectionReason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, requestedAt.hashCode);
    _$hash = $jc(_$hash, reviewedAt.hashCode);
    _$hash = $jc(_$hash, rejectionReason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SupplierApprovalResource')
          ..add('id', id)
          ..add('status', status)
          ..add('requestedAt', requestedAt)
          ..add('reviewedAt', reviewedAt)
          ..add('rejectionReason', rejectionReason))
        .toString();
  }
}

class SupplierApprovalResourceBuilder
    implements
        Builder<SupplierApprovalResource, SupplierApprovalResourceBuilder> {
  _$SupplierApprovalResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _requestedAt;
  String? get requestedAt => _$this._requestedAt;
  set requestedAt(String? requestedAt) => _$this._requestedAt = requestedAt;

  String? _reviewedAt;
  String? get reviewedAt => _$this._reviewedAt;
  set reviewedAt(String? reviewedAt) => _$this._reviewedAt = reviewedAt;

  String? _rejectionReason;
  String? get rejectionReason => _$this._rejectionReason;
  set rejectionReason(String? rejectionReason) =>
      _$this._rejectionReason = rejectionReason;

  SupplierApprovalResourceBuilder() {
    SupplierApprovalResource._defaults(this);
  }

  SupplierApprovalResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _requestedAt = $v.requestedAt;
      _reviewedAt = $v.reviewedAt;
      _rejectionReason = $v.rejectionReason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierApprovalResource other) {
    _$v = other as _$SupplierApprovalResource;
  }

  @override
  void update(void Function(SupplierApprovalResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierApprovalResource build() => _build();

  _$SupplierApprovalResource _build() {
    final _$result = _$v ??
        _$SupplierApprovalResource._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'SupplierApprovalResource', 'id'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'SupplierApprovalResource', 'status'),
          requestedAt: requestedAt,
          reviewedAt: reviewedAt,
          rejectionReason: rejectionReason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
