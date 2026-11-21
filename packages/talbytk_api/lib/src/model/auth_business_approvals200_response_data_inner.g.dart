// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_business_approvals200_response_data_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthBusinessApprovals200ResponseDataInner
    extends AuthBusinessApprovals200ResponseDataInner {
  @override
  final String businessId;
  @override
  final String? shopStatus;
  @override
  final String? supplierStatus;
  @override
  final bool supplierEnabled;

  factory _$AuthBusinessApprovals200ResponseDataInner(
          [void Function(AuthBusinessApprovals200ResponseDataInnerBuilder)?
              updates]) =>
      (AuthBusinessApprovals200ResponseDataInnerBuilder()..update(updates))
          ._build();

  _$AuthBusinessApprovals200ResponseDataInner._(
      {required this.businessId,
      this.shopStatus,
      this.supplierStatus,
      required this.supplierEnabled})
      : super._();
  @override
  AuthBusinessApprovals200ResponseDataInner rebuild(
          void Function(AuthBusinessApprovals200ResponseDataInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthBusinessApprovals200ResponseDataInnerBuilder toBuilder() =>
      AuthBusinessApprovals200ResponseDataInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthBusinessApprovals200ResponseDataInner &&
        businessId == other.businessId &&
        shopStatus == other.shopStatus &&
        supplierStatus == other.supplierStatus &&
        supplierEnabled == other.supplierEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, businessId.hashCode);
    _$hash = $jc(_$hash, shopStatus.hashCode);
    _$hash = $jc(_$hash, supplierStatus.hashCode);
    _$hash = $jc(_$hash, supplierEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AuthBusinessApprovals200ResponseDataInner')
          ..add('businessId', businessId)
          ..add('shopStatus', shopStatus)
          ..add('supplierStatus', supplierStatus)
          ..add('supplierEnabled', supplierEnabled))
        .toString();
  }
}

class AuthBusinessApprovals200ResponseDataInnerBuilder
    implements
        Builder<AuthBusinessApprovals200ResponseDataInner,
            AuthBusinessApprovals200ResponseDataInnerBuilder> {
  _$AuthBusinessApprovals200ResponseDataInner? _$v;

  String? _businessId;
  String? get businessId => _$this._businessId;
  set businessId(String? businessId) => _$this._businessId = businessId;

  String? _shopStatus;
  String? get shopStatus => _$this._shopStatus;
  set shopStatus(String? shopStatus) => _$this._shopStatus = shopStatus;

  String? _supplierStatus;
  String? get supplierStatus => _$this._supplierStatus;
  set supplierStatus(String? supplierStatus) =>
      _$this._supplierStatus = supplierStatus;

  bool? _supplierEnabled;
  bool? get supplierEnabled => _$this._supplierEnabled;
  set supplierEnabled(bool? supplierEnabled) =>
      _$this._supplierEnabled = supplierEnabled;

  AuthBusinessApprovals200ResponseDataInnerBuilder() {
    AuthBusinessApprovals200ResponseDataInner._defaults(this);
  }

  AuthBusinessApprovals200ResponseDataInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _businessId = $v.businessId;
      _shopStatus = $v.shopStatus;
      _supplierStatus = $v.supplierStatus;
      _supplierEnabled = $v.supplierEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthBusinessApprovals200ResponseDataInner other) {
    _$v = other as _$AuthBusinessApprovals200ResponseDataInner;
  }

  @override
  void update(
      void Function(AuthBusinessApprovals200ResponseDataInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthBusinessApprovals200ResponseDataInner build() => _build();

  _$AuthBusinessApprovals200ResponseDataInner _build() {
    final _$result = _$v ??
        _$AuthBusinessApprovals200ResponseDataInner._(
          businessId: BuiltValueNullFieldError.checkNotNull(businessId,
              r'AuthBusinessApprovals200ResponseDataInner', 'businessId'),
          shopStatus: shopStatus,
          supplierStatus: supplierStatus,
          supplierEnabled: BuiltValueNullFieldError.checkNotNull(
              supplierEnabled,
              r'AuthBusinessApprovals200ResponseDataInner',
              'supplierEnabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
