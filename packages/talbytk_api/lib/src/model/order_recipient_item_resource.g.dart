// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_recipient_item_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderRecipientItemResource extends OrderRecipientItemResource {
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
  final int requestedQuantity;
  @override
  final String? unit;
  @override
  final String? note;
  @override
  final int? selectedQuantity;
  @override
  final String? imageUrl;

  factory _$OrderRecipientItemResource(
          [void Function(OrderRecipientItemResourceBuilder)? updates]) =>
      (OrderRecipientItemResourceBuilder()..update(updates))._build();

  _$OrderRecipientItemResource._(
      {required this.id,
      required this.itemType,
      this.productId,
      required this.productName,
      required this.unitPrice,
      required this.requestedQuantity,
      this.unit,
      this.note,
      this.selectedQuantity,
      this.imageUrl})
      : super._();
  @override
  OrderRecipientItemResource rebuild(
          void Function(OrderRecipientItemResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderRecipientItemResourceBuilder toBuilder() =>
      OrderRecipientItemResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderRecipientItemResource &&
        id == other.id &&
        itemType == other.itemType &&
        productId == other.productId &&
        productName == other.productName &&
        unitPrice == other.unitPrice &&
        requestedQuantity == other.requestedQuantity &&
        unit == other.unit &&
        note == other.note &&
        selectedQuantity == other.selectedQuantity &&
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
    _$hash = $jc(_$hash, requestedQuantity.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, selectedQuantity.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderRecipientItemResource')
          ..add('id', id)
          ..add('itemType', itemType)
          ..add('productId', productId)
          ..add('productName', productName)
          ..add('unitPrice', unitPrice)
          ..add('requestedQuantity', requestedQuantity)
          ..add('unit', unit)
          ..add('note', note)
          ..add('selectedQuantity', selectedQuantity)
          ..add('imageUrl', imageUrl))
        .toString();
  }
}

class OrderRecipientItemResourceBuilder
    implements
        Builder<OrderRecipientItemResource, OrderRecipientItemResourceBuilder> {
  _$OrderRecipientItemResource? _$v;

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

  int? _requestedQuantity;
  int? get requestedQuantity => _$this._requestedQuantity;
  set requestedQuantity(int? requestedQuantity) =>
      _$this._requestedQuantity = requestedQuantity;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  int? _selectedQuantity;
  int? get selectedQuantity => _$this._selectedQuantity;
  set selectedQuantity(int? selectedQuantity) =>
      _$this._selectedQuantity = selectedQuantity;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  OrderRecipientItemResourceBuilder() {
    OrderRecipientItemResource._defaults(this);
  }

  OrderRecipientItemResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _itemType = $v.itemType;
      _productId = $v.productId;
      _productName = $v.productName;
      _unitPrice = $v.unitPrice;
      _requestedQuantity = $v.requestedQuantity;
      _unit = $v.unit;
      _note = $v.note;
      _selectedQuantity = $v.selectedQuantity;
      _imageUrl = $v.imageUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderRecipientItemResource other) {
    _$v = other as _$OrderRecipientItemResource;
  }

  @override
  void update(void Function(OrderRecipientItemResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderRecipientItemResource build() => _build();

  _$OrderRecipientItemResource _build() {
    final _$result = _$v ??
        _$OrderRecipientItemResource._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OrderRecipientItemResource', 'id'),
          itemType: BuiltValueNullFieldError.checkNotNull(
              itemType, r'OrderRecipientItemResource', 'itemType'),
          productId: productId,
          productName: BuiltValueNullFieldError.checkNotNull(
              productName, r'OrderRecipientItemResource', 'productName'),
          unitPrice: BuiltValueNullFieldError.checkNotNull(
              unitPrice, r'OrderRecipientItemResource', 'unitPrice'),
          requestedQuantity: BuiltValueNullFieldError.checkNotNull(
              requestedQuantity,
              r'OrderRecipientItemResource',
              'requestedQuantity'),
          unit: unit,
          note: note,
          selectedQuantity: selectedQuantity,
          imageUrl: imageUrl,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
