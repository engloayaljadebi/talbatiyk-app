// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_approval_admin_index200_response_data_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierApprovalAdminIndex200ResponseDataInner
    extends SupplierApprovalAdminIndex200ResponseDataInner {
  @override
  final String id;
  @override
  final String? businessId;
  @override
  final String status;
  @override
  final String requestedAt;
  @override
  final SupplierApprovalAdminIndex200ResponseDataInnerBusiness business;
  @override
  final SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy requestedBy;

  factory _$SupplierApprovalAdminIndex200ResponseDataInner(
          [void Function(SupplierApprovalAdminIndex200ResponseDataInnerBuilder)?
              updates]) =>
      (SupplierApprovalAdminIndex200ResponseDataInnerBuilder()..update(updates))
          ._build();

  _$SupplierApprovalAdminIndex200ResponseDataInner._(
      {required this.id,
      this.businessId,
      required this.status,
      required this.requestedAt,
      required this.business,
      required this.requestedBy})
      : super._();
  @override
  SupplierApprovalAdminIndex200ResponseDataInner rebuild(
          void Function(SupplierApprovalAdminIndex200ResponseDataInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierApprovalAdminIndex200ResponseDataInnerBuilder toBuilder() =>
      SupplierApprovalAdminIndex200ResponseDataInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierApprovalAdminIndex200ResponseDataInner &&
        id == other.id &&
        businessId == other.businessId &&
        status == other.status &&
        requestedAt == other.requestedAt &&
        business == other.business &&
        requestedBy == other.requestedBy;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, businessId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, requestedAt.hashCode);
    _$hash = $jc(_$hash, business.hashCode);
    _$hash = $jc(_$hash, requestedBy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SupplierApprovalAdminIndex200ResponseDataInner')
          ..add('id', id)
          ..add('businessId', businessId)
          ..add('status', status)
          ..add('requestedAt', requestedAt)
          ..add('business', business)
          ..add('requestedBy', requestedBy))
        .toString();
  }
}

class SupplierApprovalAdminIndex200ResponseDataInnerBuilder
    implements
        Builder<SupplierApprovalAdminIndex200ResponseDataInner,
            SupplierApprovalAdminIndex200ResponseDataInnerBuilder> {
  _$SupplierApprovalAdminIndex200ResponseDataInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _businessId;
  String? get businessId => _$this._businessId;
  set businessId(String? businessId) => _$this._businessId = businessId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _requestedAt;
  String? get requestedAt => _$this._requestedAt;
  set requestedAt(String? requestedAt) => _$this._requestedAt = requestedAt;

  SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder? _business;
  SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder get business =>
      _$this._business ??=
          SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder();
  set business(
          SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder?
              business) =>
      _$this._business = business;

  SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder?
      _requestedBy;
  SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder
      get requestedBy => _$this._requestedBy ??=
          SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder();
  set requestedBy(
          SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder?
              requestedBy) =>
      _$this._requestedBy = requestedBy;

  SupplierApprovalAdminIndex200ResponseDataInnerBuilder() {
    SupplierApprovalAdminIndex200ResponseDataInner._defaults(this);
  }

  SupplierApprovalAdminIndex200ResponseDataInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _businessId = $v.businessId;
      _status = $v.status;
      _requestedAt = $v.requestedAt;
      _business = $v.business.toBuilder();
      _requestedBy = $v.requestedBy.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierApprovalAdminIndex200ResponseDataInner other) {
    _$v = other as _$SupplierApprovalAdminIndex200ResponseDataInner;
  }

  @override
  void update(
      void Function(SupplierApprovalAdminIndex200ResponseDataInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierApprovalAdminIndex200ResponseDataInner build() => _build();

  _$SupplierApprovalAdminIndex200ResponseDataInner _build() {
    _$SupplierApprovalAdminIndex200ResponseDataInner _$result;
    try {
      _$result = _$v ??
          _$SupplierApprovalAdminIndex200ResponseDataInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'SupplierApprovalAdminIndex200ResponseDataInner', 'id'),
            businessId: businessId,
            status: BuiltValueNullFieldError.checkNotNull(status,
                r'SupplierApprovalAdminIndex200ResponseDataInner', 'status'),
            requestedAt: BuiltValueNullFieldError.checkNotNull(
                requestedAt,
                r'SupplierApprovalAdminIndex200ResponseDataInner',
                'requestedAt'),
            business: business.build(),
            requestedBy: requestedBy.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'business';
        business.build();
        _$failedField = 'requestedBy';
        requestedBy.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupplierApprovalAdminIndex200ResponseDataInner',
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
