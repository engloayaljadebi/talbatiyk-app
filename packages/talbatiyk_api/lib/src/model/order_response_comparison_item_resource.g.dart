// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response_comparison_item_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderResponseComparisonItemResource
    extends OrderResponseComparisonItemResource {
  @override
  final String id;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final int requestedQuantity;
  @override
  final String orderUnitPrice;
  @override
  final OrderResponseComparisonItemResourceSupplier supplier;
  @override
  final OrderRecipientItemResponseResource? response;
  @override
  final OrderResponseComparisonSelectionResource? selection;

  factory _$OrderResponseComparisonItemResource(
          [void Function(OrderResponseComparisonItemResourceBuilder)?
              updates]) =>
      (OrderResponseComparisonItemResourceBuilder()..update(updates))._build();

  _$OrderResponseComparisonItemResource._(
      {required this.id,
      required this.productId,
      required this.productName,
      required this.requestedQuantity,
      required this.orderUnitPrice,
      required this.supplier,
      this.response,
      this.selection})
      : super._();
  @override
  OrderResponseComparisonItemResource rebuild(
          void Function(OrderResponseComparisonItemResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderResponseComparisonItemResourceBuilder toBuilder() =>
      OrderResponseComparisonItemResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderResponseComparisonItemResource &&
        id == other.id &&
        productId == other.productId &&
        productName == other.productName &&
        requestedQuantity == other.requestedQuantity &&
        orderUnitPrice == other.orderUnitPrice &&
        supplier == other.supplier &&
        response == other.response &&
        selection == other.selection;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, productName.hashCode);
    _$hash = $jc(_$hash, requestedQuantity.hashCode);
    _$hash = $jc(_$hash, orderUnitPrice.hashCode);
    _$hash = $jc(_$hash, supplier.hashCode);
    _$hash = $jc(_$hash, response.hashCode);
    _$hash = $jc(_$hash, selection.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderResponseComparisonItemResource')
          ..add('id', id)
          ..add('productId', productId)
          ..add('productName', productName)
          ..add('requestedQuantity', requestedQuantity)
          ..add('orderUnitPrice', orderUnitPrice)
          ..add('supplier', supplier)
          ..add('response', response)
          ..add('selection', selection))
        .toString();
  }
}

class OrderResponseComparisonItemResourceBuilder
    implements
        Builder<OrderResponseComparisonItemResource,
            OrderResponseComparisonItemResourceBuilder> {
  _$OrderResponseComparisonItemResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  String? _productName;
  String? get productName => _$this._productName;
  set productName(String? productName) => _$this._productName = productName;

  int? _requestedQuantity;
  int? get requestedQuantity => _$this._requestedQuantity;
  set requestedQuantity(int? requestedQuantity) =>
      _$this._requestedQuantity = requestedQuantity;

  String? _orderUnitPrice;
  String? get orderUnitPrice => _$this._orderUnitPrice;
  set orderUnitPrice(String? orderUnitPrice) =>
      _$this._orderUnitPrice = orderUnitPrice;

  OrderResponseComparisonItemResourceSupplierBuilder? _supplier;
  OrderResponseComparisonItemResourceSupplierBuilder get supplier =>
      _$this._supplier ??= OrderResponseComparisonItemResourceSupplierBuilder();
  set supplier(OrderResponseComparisonItemResourceSupplierBuilder? supplier) =>
      _$this._supplier = supplier;

  OrderRecipientItemResponseResourceBuilder? _response;
  OrderRecipientItemResponseResourceBuilder get response =>
      _$this._response ??= OrderRecipientItemResponseResourceBuilder();
  set response(OrderRecipientItemResponseResourceBuilder? response) =>
      _$this._response = response;

  OrderResponseComparisonSelectionResourceBuilder? _selection;
  OrderResponseComparisonSelectionResourceBuilder get selection =>
      _$this._selection ??= OrderResponseComparisonSelectionResourceBuilder();
  set selection(OrderResponseComparisonSelectionResourceBuilder? selection) =>
      _$this._selection = selection;

  OrderResponseComparisonItemResourceBuilder() {
    OrderResponseComparisonItemResource._defaults(this);
  }

  OrderResponseComparisonItemResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _productId = $v.productId;
      _productName = $v.productName;
      _requestedQuantity = $v.requestedQuantity;
      _orderUnitPrice = $v.orderUnitPrice;
      _supplier = $v.supplier.toBuilder();
      _response = $v.response?.toBuilder();
      _selection = $v.selection?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderResponseComparisonItemResource other) {
    _$v = other as _$OrderResponseComparisonItemResource;
  }

  @override
  void update(
      void Function(OrderResponseComparisonItemResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderResponseComparisonItemResource build() => _build();

  _$OrderResponseComparisonItemResource _build() {
    _$OrderResponseComparisonItemResource _$result;
    try {
      _$result = _$v ??
          _$OrderResponseComparisonItemResource._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OrderResponseComparisonItemResource', 'id'),
            productId: BuiltValueNullFieldError.checkNotNull(
                productId, r'OrderResponseComparisonItemResource', 'productId'),
            productName: BuiltValueNullFieldError.checkNotNull(productName,
                r'OrderResponseComparisonItemResource', 'productName'),
            requestedQuantity: BuiltValueNullFieldError.checkNotNull(
                requestedQuantity,
                r'OrderResponseComparisonItemResource',
                'requestedQuantity'),
            orderUnitPrice: BuiltValueNullFieldError.checkNotNull(
                orderUnitPrice,
                r'OrderResponseComparisonItemResource',
                'orderUnitPrice'),
            supplier: supplier.build(),
            response: _response?.build(),
            selection: _selection?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'supplier';
        supplier.build();
        _$failedField = 'response';
        _response?.build();
        _$failedField = 'selection';
        _selection?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'OrderResponseComparisonItemResource',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
