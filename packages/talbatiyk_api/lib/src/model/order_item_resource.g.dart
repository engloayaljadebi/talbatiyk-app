// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderItemResource extends OrderItemResource {
  @override
  final String id;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final String unitPrice;
  @override
  final int quantity;
  @override
  final String supplierId;
  @override
  final String supplierName;
  @override
  final String? imageUrl;

  factory _$OrderItemResource(
          [void Function(OrderItemResourceBuilder)? updates]) =>
      (OrderItemResourceBuilder()..update(updates))._build();

  _$OrderItemResource._(
      {required this.id,
      required this.productId,
      required this.productName,
      required this.unitPrice,
      required this.quantity,
      required this.supplierId,
      required this.supplierName,
      this.imageUrl})
      : super._();
  @override
  OrderItemResource rebuild(void Function(OrderItemResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderItemResourceBuilder toBuilder() =>
      OrderItemResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderItemResource &&
        id == other.id &&
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
    _$hash = $jc(_$hash, id.hashCode);
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
    return (newBuiltValueToStringHelper(r'OrderItemResource')
          ..add('id', id)
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

class OrderItemResourceBuilder
    implements Builder<OrderItemResource, OrderItemResourceBuilder> {
  _$OrderItemResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  String? _productName;
  String? get productName => _$this._productName;
  set productName(String? productName) => _$this._productName = productName;

  String? _unitPrice;
  String? get unitPrice => _$this._unitPrice;
  set unitPrice(String? unitPrice) => _$this._unitPrice = unitPrice;

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

  OrderItemResourceBuilder() {
    OrderItemResource._defaults(this);
  }

  OrderItemResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
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
  void replace(OrderItemResource other) {
    _$v = other as _$OrderItemResource;
  }

  @override
  void update(void Function(OrderItemResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderItemResource build() => _build();

  _$OrderItemResource _build() {
    final _$result = _$v ??
        _$OrderItemResource._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OrderItemResource', 'id'),
          productId: BuiltValueNullFieldError.checkNotNull(
              productId, r'OrderItemResource', 'productId'),
          productName: BuiltValueNullFieldError.checkNotNull(
              productName, r'OrderItemResource', 'productName'),
          unitPrice: BuiltValueNullFieldError.checkNotNull(
              unitPrice, r'OrderItemResource', 'unitPrice'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'OrderItemResource', 'quantity'),
          supplierId: BuiltValueNullFieldError.checkNotNull(
              supplierId, r'OrderItemResource', 'supplierId'),
          supplierName: BuiltValueNullFieldError.checkNotNull(
              supplierName, r'OrderItemResource', 'supplierName'),
          imageUrl: imageUrl,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
