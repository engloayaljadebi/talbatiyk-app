// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_request_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateOrderRequestItemsInner extends CreateOrderRequestItemsInner {
  @override
  final String productId;
  @override
  final String productName;
  @override
  final num unitPrice;
  @override
  final int quantity;
  @override
  final String supplierId;
  @override
  final String supplierName;
  @override
  final String? imageUrl;

  factory _$CreateOrderRequestItemsInner(
          [void Function(CreateOrderRequestItemsInnerBuilder)? updates]) =>
      (CreateOrderRequestItemsInnerBuilder()..update(updates))._build();

  _$CreateOrderRequestItemsInner._(
      {required this.productId,
      required this.productName,
      required this.unitPrice,
      required this.quantity,
      required this.supplierId,
      required this.supplierName,
      this.imageUrl})
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
        productName == other.productName &&
        unitPrice == other.unitPrice &&
        quantity == other.quantity &&
        supplierId == other.supplierId &&
        supplierName == other.supplierName &&
        imageUrl == other.imageUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, productName.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, supplierId.hashCode);
    _$hash = $jc(_$hash, supplierName.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateOrderRequestItemsInner')
          ..add('productId', productId)
          ..add('productName', productName)
          ..add('unitPrice', unitPrice)
          ..add('quantity', quantity)
          ..add('supplierId', supplierId)
          ..add('supplierName', supplierName)
          ..add('imageUrl', imageUrl))
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

  String? _productName;
  String? get productName => _$this._productName;
  set productName(String? productName) => _$this._productName = productName;

  num? _unitPrice;
  num? get unitPrice => _$this._unitPrice;
  set unitPrice(num? unitPrice) => _$this._unitPrice = unitPrice;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _supplierId;
  String? get supplierId => _$this._supplierId;
  set supplierId(String? supplierId) => _$this._supplierId = supplierId;

  String? _supplierName;
  String? get supplierName => _$this._supplierName;
  set supplierName(String? supplierName) => _$this._supplierName = supplierName;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  CreateOrderRequestItemsInnerBuilder() {
    CreateOrderRequestItemsInner._defaults(this);
  }

  CreateOrderRequestItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _productName = $v.productName;
      _unitPrice = $v.unitPrice;
      _quantity = $v.quantity;
      _supplierId = $v.supplierId;
      _supplierName = $v.supplierName;
      _imageUrl = $v.imageUrl;
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
          productName: BuiltValueNullFieldError.checkNotNull(
              productName, r'CreateOrderRequestItemsInner', 'productName'),
          unitPrice: BuiltValueNullFieldError.checkNotNull(
              unitPrice, r'CreateOrderRequestItemsInner', 'unitPrice'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'CreateOrderRequestItemsInner', 'quantity'),
          supplierId: BuiltValueNullFieldError.checkNotNull(
              supplierId, r'CreateOrderRequestItemsInner', 'supplierId'),
          supplierName: BuiltValueNullFieldError.checkNotNull(
              supplierName, r'CreateOrderRequestItemsInner', 'supplierName'),
          imageUrl: imageUrl,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
