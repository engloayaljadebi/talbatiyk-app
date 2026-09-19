// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_request_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateOrderRequestItemsInner extends CreateOrderRequestItemsInner {
  @override
  final String productId;
  @override
  final int quantity;
  @override
  final num expectedUnitPrice;
  @override
  final String expectedSupplierId;

  factory _$CreateOrderRequestItemsInner(
          [void Function(CreateOrderRequestItemsInnerBuilder)? updates]) =>
      (CreateOrderRequestItemsInnerBuilder()..update(updates))._build();

  _$CreateOrderRequestItemsInner._(
      {required this.productId,
      required this.quantity,
      required this.expectedUnitPrice,
      required this.expectedSupplierId})
      : super._();
  @override
  CreateOrderRequestItemsInner rebuild(
          void Function(CreateOrderRequestItemsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateOrderRequestItemsInnerBuilder toBuilder() =>
      CreateOrderRequestItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateOrderRequestItemsInner &&
        productId == other.productId &&
        quantity == other.quantity &&
        expectedUnitPrice == other.expectedUnitPrice &&
        expectedSupplierId == other.expectedSupplierId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, expectedUnitPrice.hashCode);
    _$hash = $jc(_$hash, expectedSupplierId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateOrderRequestItemsInner')
          ..add('productId', productId)
          ..add('quantity', quantity)
          ..add('expectedUnitPrice', expectedUnitPrice)
          ..add('expectedSupplierId', expectedSupplierId))
        .toString();
  }
}

class CreateOrderRequestItemsInnerBuilder
    implements
        Builder<CreateOrderRequestItemsInner,
            CreateOrderRequestItemsInnerBuilder> {
  _$CreateOrderRequestItemsInner? _$v;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  num? _expectedUnitPrice;
  num? get expectedUnitPrice => _$this._expectedUnitPrice;
  set expectedUnitPrice(num? expectedUnitPrice) =>
      _$this._expectedUnitPrice = expectedUnitPrice;

  String? _expectedSupplierId;
  String? get expectedSupplierId => _$this._expectedSupplierId;
  set expectedSupplierId(String? expectedSupplierId) =>
      _$this._expectedSupplierId = expectedSupplierId;

  CreateOrderRequestItemsInnerBuilder() {
    CreateOrderRequestItemsInner._defaults(this);
  }

  CreateOrderRequestItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _quantity = $v.quantity;
      _expectedUnitPrice = $v.expectedUnitPrice;
      _expectedSupplierId = $v.expectedSupplierId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateOrderRequestItemsInner other) {
    _$v = other as _$CreateOrderRequestItemsInner;
  }

  @override
  void update(void Function(CreateOrderRequestItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateOrderRequestItemsInner build() => _build();

  _$CreateOrderRequestItemsInner _build() {
    final _$result = _$v ??
        _$CreateOrderRequestItemsInner._(
          productId: BuiltValueNullFieldError.checkNotNull(
              productId, r'CreateOrderRequestItemsInner', 'productId'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'CreateOrderRequestItemsInner', 'quantity'),
          expectedUnitPrice: BuiltValueNullFieldError.checkNotNull(
              expectedUnitPrice,
              r'CreateOrderRequestItemsInner',
              'expectedUnitPrice'),
          expectedSupplierId: BuiltValueNullFieldError.checkNotNull(
              expectedSupplierId,
              r'CreateOrderRequestItemsInner',
              'expectedSupplierId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
