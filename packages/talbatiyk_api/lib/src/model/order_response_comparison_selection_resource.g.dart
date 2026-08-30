// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response_comparison_selection_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderResponseComparisonSelectionResource
    extends OrderResponseComparisonSelectionResource {
  @override
  final String id;
  @override
  final String orderRecipientItemResponseId;
  @override
  final int selectedQuantity;

  factory _$OrderResponseComparisonSelectionResource(
          [void Function(OrderResponseComparisonSelectionResourceBuilder)?
              updates]) =>
      (OrderResponseComparisonSelectionResourceBuilder()..update(updates))
          ._build();

  _$OrderResponseComparisonSelectionResource._(
      {required this.id,
      required this.orderRecipientItemResponseId,
      required this.selectedQuantity})
      : super._();
  @override
  OrderResponseComparisonSelectionResource rebuild(
          void Function(OrderResponseComparisonSelectionResourceBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderResponseComparisonSelectionResourceBuilder toBuilder() =>
      OrderResponseComparisonSelectionResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderResponseComparisonSelectionResource &&
        id == other.id &&
        orderRecipientItemResponseId == other.orderRecipientItemResponseId &&
        selectedQuantity == other.selectedQuantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, orderRecipientItemResponseId.hashCode);
    _$hash = $jc(_$hash, selectedQuantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'OrderResponseComparisonSelectionResource')
          ..add('id', id)
          ..add('orderRecipientItemResponseId', orderRecipientItemResponseId)
          ..add('selectedQuantity', selectedQuantity))
        .toString();
  }
}

class OrderResponseComparisonSelectionResourceBuilder
    implements
        Builder<OrderResponseComparisonSelectionResource,
            OrderResponseComparisonSelectionResourceBuilder> {
  _$OrderResponseComparisonSelectionResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _orderRecipientItemResponseId;
  String? get orderRecipientItemResponseId =>
      _$this._orderRecipientItemResponseId;
  set orderRecipientItemResponseId(String? orderRecipientItemResponseId) =>
      _$this._orderRecipientItemResponseId = orderRecipientItemResponseId;

  int? _selectedQuantity;
  int? get selectedQuantity => _$this._selectedQuantity;
  set selectedQuantity(int? selectedQuantity) =>
      _$this._selectedQuantity = selectedQuantity;

  OrderResponseComparisonSelectionResourceBuilder() {
    OrderResponseComparisonSelectionResource._defaults(this);
  }

  OrderResponseComparisonSelectionResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _orderRecipientItemResponseId = $v.orderRecipientItemResponseId;
      _selectedQuantity = $v.selectedQuantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderResponseComparisonSelectionResource other) {
    _$v = other as _$OrderResponseComparisonSelectionResource;
  }

  @override
  void update(
      void Function(OrderResponseComparisonSelectionResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderResponseComparisonSelectionResource build() => _build();

  _$OrderResponseComparisonSelectionResource _build() {
    final _$result = _$v ??
        _$OrderResponseComparisonSelectionResource._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OrderResponseComparisonSelectionResource', 'id'),
          orderRecipientItemResponseId: BuiltValueNullFieldError.checkNotNull(
              orderRecipientItemResponseId,
              r'OrderResponseComparisonSelectionResource',
              'orderRecipientItemResponseId'),
          selectedQuantity: BuiltValueNullFieldError.checkNotNull(
              selectedQuantity,
              r'OrderResponseComparisonSelectionResource',
              'selectedQuantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
