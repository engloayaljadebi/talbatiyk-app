// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_approval_admin_index200_response_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierApprovalAdminIndex200ResponseMeta
    extends SupplierApprovalAdminIndex200ResponseMeta {
  @override
  final int currentPage;
  @override
  final int lastPage;
  @override
  final int perPage;
  @override
  final int total;

  factory _$SupplierApprovalAdminIndex200ResponseMeta(
          [void Function(SupplierApprovalAdminIndex200ResponseMetaBuilder)?
              updates]) =>
      (SupplierApprovalAdminIndex200ResponseMetaBuilder()..update(updates))
          ._build();

  _$SupplierApprovalAdminIndex200ResponseMeta._(
      {required this.currentPage,
      required this.lastPage,
      required this.perPage,
      required this.total})
      : super._();
  @override
  SupplierApprovalAdminIndex200ResponseMeta rebuild(
          void Function(SupplierApprovalAdminIndex200ResponseMetaBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierApprovalAdminIndex200ResponseMetaBuilder toBuilder() =>
      SupplierApprovalAdminIndex200ResponseMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierApprovalAdminIndex200ResponseMeta &&
        currentPage == other.currentPage &&
        lastPage == other.lastPage &&
        perPage == other.perPage &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currentPage.hashCode);
    _$hash = $jc(_$hash, lastPage.hashCode);
    _$hash = $jc(_$hash, perPage.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SupplierApprovalAdminIndex200ResponseMeta')
          ..add('currentPage', currentPage)
          ..add('lastPage', lastPage)
          ..add('perPage', perPage)
          ..add('total', total))
        .toString();
  }
}

class SupplierApprovalAdminIndex200ResponseMetaBuilder
    implements
        Builder<SupplierApprovalAdminIndex200ResponseMeta,
            SupplierApprovalAdminIndex200ResponseMetaBuilder> {
  _$SupplierApprovalAdminIndex200ResponseMeta? _$v;

  int? _currentPage;
  int? get currentPage => _$this._currentPage;
  set currentPage(int? currentPage) => _$this._currentPage = currentPage;

  int? _lastPage;
  int? get lastPage => _$this._lastPage;
  set lastPage(int? lastPage) => _$this._lastPage = lastPage;

  int? _perPage;
  int? get perPage => _$this._perPage;
  set perPage(int? perPage) => _$this._perPage = perPage;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  SupplierApprovalAdminIndex200ResponseMetaBuilder() {
    SupplierApprovalAdminIndex200ResponseMeta._defaults(this);
  }

  SupplierApprovalAdminIndex200ResponseMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _currentPage = $v.currentPage;
      _lastPage = $v.lastPage;
      _perPage = $v.perPage;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierApprovalAdminIndex200ResponseMeta other) {
    _$v = other as _$SupplierApprovalAdminIndex200ResponseMeta;
  }

  @override
  void update(
      void Function(SupplierApprovalAdminIndex200ResponseMetaBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierApprovalAdminIndex200ResponseMeta build() => _build();

  _$SupplierApprovalAdminIndex200ResponseMeta _build() {
    final _$result = _$v ??
        _$SupplierApprovalAdminIndex200ResponseMeta._(
          currentPage: BuiltValueNullFieldError.checkNotNull(currentPage,
              r'SupplierApprovalAdminIndex200ResponseMeta', 'currentPage'),
          lastPage: BuiltValueNullFieldError.checkNotNull(lastPage,
              r'SupplierApprovalAdminIndex200ResponseMeta', 'lastPage'),
          perPage: BuiltValueNullFieldError.checkNotNull(
              perPage, r'SupplierApprovalAdminIndex200ResponseMeta', 'perPage'),
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'SupplierApprovalAdminIndex200ResponseMeta', 'total'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
