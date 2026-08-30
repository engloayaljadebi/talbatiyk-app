// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response_comparison_item_resource_supplier.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderResponseComparisonItemResourceSupplier
    extends OrderResponseComparisonItemResourceSupplier {
  @override
  final String recipientId;
  @override
  final String supplierId;
  @override
  final String supplierName;

  factory _$OrderResponseComparisonItemResourceSupplier(
          [void Function(OrderResponseComparisonItemResourceSupplierBuilder)?
              updates]) =>
      (OrderResponseComparisonItemResourceSupplierBuilder()..update(updates))
          ._build();

  _$OrderResponseComparisonItemResourceSupplier._(
      {required this.recipientId,
      required this.supplierId,
      required this.supplierName})
      : super._();
  @override
  OrderResponseComparisonItemResourceSupplier rebuild(
          void Function(OrderResponseComparisonItemResourceSupplierBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderResponseComparisonItemResourceSupplierBuilder toBuilder() =>
      OrderResponseComparisonItemResourceSupplierBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderResponseComparisonItemResourceSupplier &&
        recipientId == other.recipientId &&
        supplierId == other.supplierId &&
        supplierName == other.supplierName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recipientId.hashCode);
    _$hash = $jc(_$hash, supplierId.hashCode);
    _$hash = $jc(_$hash, supplierName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'OrderResponseComparisonItemResourceSupplier')
          ..add('recipientId', recipientId)
          ..add('supplierId', supplierId)
          ..add('supplierName', supplierName))
        .toString();
  }
}

class OrderResponseComparisonItemResourceSupplierBuilder
    implements
        Builder<OrderResponseComparisonItemResourceSupplier,
            OrderResponseComparisonItemResourceSupplierBuilder> {
  _$OrderResponseComparisonItemResourceSupplier? _$v;

  String? _recipientId;
  String? get recipientId => _$this._recipientId;
  set recipientId(String? recipientId) => _$this._recipientId = recipientId;

  String? _supplierId;
  String? get supplierId => _$this._supplierId;
  set supplierId(String? supplierId) => _$this._supplierId = supplierId;

  String? _supplierName;
  String? get supplierName => _$this._supplierName;
  set supplierName(String? supplierName) => _$this._supplierName = supplierName;

  OrderResponseComparisonItemResourceSupplierBuilder() {
    OrderResponseComparisonItemResourceSupplier._defaults(this);
  }

  OrderResponseComparisonItemResourceSupplierBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _recipientId = $v.recipientId;
      _supplierId = $v.supplierId;
      _supplierName = $v.supplierName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderResponseComparisonItemResourceSupplier other) {
    _$v = other as _$OrderResponseComparisonItemResourceSupplier;
  }

  @override
  void update(
      void Function(OrderResponseComparisonItemResourceSupplierBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderResponseComparisonItemResourceSupplier build() => _build();

  _$OrderResponseComparisonItemResourceSupplier _build() {
    final _$result = _$v ??
        _$OrderResponseComparisonItemResourceSupplier._(
          recipientId: BuiltValueNullFieldError.checkNotNull(recipientId,
              r'OrderResponseComparisonItemResourceSupplier', 'recipientId'),
          supplierId: BuiltValueNullFieldError.checkNotNull(supplierId,
              r'OrderResponseComparisonItemResourceSupplier', 'supplierId'),
          supplierName: BuiltValueNullFieldError.checkNotNull(supplierName,
              r'OrderResponseComparisonItemResourceSupplier', 'supplierName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
