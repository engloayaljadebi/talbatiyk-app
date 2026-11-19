// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderItemResource extends OrderItemResource {
  @override
  final String id;
  @override
  final String itemType;
  @override
  final String? productId;
  @override
  final String productName;
  @override
  final String unitPrice;
  @override
  final int quantity;
  @override
  final String? unit;
  @override
  final String? note;
  @override
  final String? supplierId;
  @override
  final String? supplierName;
  @override
  final String? imageUrl;

  factory _$OrderItemResource(
          [void Function(OrderItemResourceBuilder)? updates]) =>
      (OrderItemResourceBuilder()..update(updates))._build();

  _$OrderItemResource._(
      {required this.id,
      required this.itemType,
      this.productId,
      required this.productName,
      required this.unitPrice,
      required this.quantity,
      this.unit,
      this.note,
      this.supplierId,
      this.supplierName,
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
        itemType == other.itemType &&
        productId == other.productId &&
        productName == other.productName &&
        unitPrice == other.unitPrice &&
        quantity == other.quantity &&
        unit == other.unit &&
        note == other.note &&
        supplierId == other.supplierId &&
        supplierName == other.supplierName &&
        imageUrl == other.imageUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, itemType.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, productName.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
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
          ..add('itemType', itemType)
          ..add('productId', productId)
          ..add('productName', productName)
          ..add('unitPrice', unitPrice)
          ..add('quantity', quantity)
          ..add('unit', unit)
          ..add('note', note)
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

  String? _itemType;
  String? get itemType => _$this._itemType;
  set itemType(String? itemType) => _$this._itemType = itemType;

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

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

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
      _itemType = $v.itemType;
      _productId = $v.productId;
      _productName = $v.productName;
      _unitPrice = $v.unitPrice;
      _quantity = $v.quantity;
      _unit = $v.unit;
      _note = $v.note;
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
          itemType: BuiltValueNullFieldError.checkNotNull(
              itemType, r'OrderItemResource', 'itemType'),
          productId: productId,
          productName: BuiltValueNullFieldError.checkNotNull(
              productName, r'OrderItemResource', 'productName'),
          unitPrice: BuiltValueNullFieldError.checkNotNull(
              unitPrice, r'OrderItemResource', 'unitPrice'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'OrderItemResource', 'quantity'),
          unit: unit,
          note: note,
          supplierId: supplierId,
          supplierName: supplierName,
          imageUrl: imageUrl,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
