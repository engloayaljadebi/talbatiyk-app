// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_order_supplier_responses_request_selections_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SelectOrderSupplierResponsesRequestSelectionsInner
    extends SelectOrderSupplierResponsesRequestSelectionsInner {
  @override
  final String orderRecipientItemResponseId;
  @override
  final int selectedQuantity;

  factory _$SelectOrderSupplierResponsesRequestSelectionsInner(
          [void Function(
                  SelectOrderSupplierResponsesRequestSelectionsInnerBuilder)?
              updates]) =>
      (SelectOrderSupplierResponsesRequestSelectionsInnerBuilder()
            ..update(updates))
          ._build();

  _$SelectOrderSupplierResponsesRequestSelectionsInner._(
      {required this.orderRecipientItemResponseId,
      required this.selectedQuantity})
      : super._();
  @override
  SelectOrderSupplierResponsesRequestSelectionsInner rebuild(
          void Function(
                  SelectOrderSupplierResponsesRequestSelectionsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SelectOrderSupplierResponsesRequestSelectionsInnerBuilder toBuilder() =>
      SelectOrderSupplierResponsesRequestSelectionsInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SelectOrderSupplierResponsesRequestSelectionsInner &&
        orderRecipientItemResponseId == other.orderRecipientItemResponseId &&
        selectedQuantity == other.selectedQuantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, orderRecipientItemResponseId.hashCode);
    _$hash = $jc(_$hash, selectedQuantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SelectOrderSupplierResponsesRequestSelectionsInner')
          ..add('orderRecipientItemResponseId', orderRecipientItemResponseId)
          ..add('selectedQuantity', selectedQuantity))
        .toString();
  }
}

class SelectOrderSupplierResponsesRequestSelectionsInnerBuilder
    implements
        Builder<SelectOrderSupplierResponsesRequestSelectionsInner,
            SelectOrderSupplierResponsesRequestSelectionsInnerBuilder> {
  _$SelectOrderSupplierResponsesRequestSelectionsInner? _$v;

  String? _orderRecipientItemResponseId;
  String? get orderRecipientItemResponseId =>
      _$this._orderRecipientItemResponseId;
  set orderRecipientItemResponseId(String? orderRecipientItemResponseId) =>
      _$this._orderRecipientItemResponseId = orderRecipientItemResponseId;

  int? _selectedQuantity;
  int? get selectedQuantity => _$this._selectedQuantity;
  set selectedQuantity(int? selectedQuantity) =>
      _$this._selectedQuantity = selectedQuantity;

  SelectOrderSupplierResponsesRequestSelectionsInnerBuilder() {
    SelectOrderSupplierResponsesRequestSelectionsInner._defaults(this);
  }

  SelectOrderSupplierResponsesRequestSelectionsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _orderRecipientItemResponseId = $v.orderRecipientItemResponseId;
      _selectedQuantity = $v.selectedQuantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SelectOrderSupplierResponsesRequestSelectionsInner other) {
    _$v = other as _$SelectOrderSupplierResponsesRequestSelectionsInner;
  }

  @override
  void update(
      void Function(SelectOrderSupplierResponsesRequestSelectionsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SelectOrderSupplierResponsesRequestSelectionsInner build() => _build();

  _$SelectOrderSupplierResponsesRequestSelectionsInner _build() {
    final _$result = _$v ??
        _$SelectOrderSupplierResponsesRequestSelectionsInner._(
          orderRecipientItemResponseId: BuiltValueNullFieldError.checkNotNull(
              orderRecipientItemResponseId,
              r'SelectOrderSupplierResponsesRequestSelectionsInner',
              'orderRecipientItemResponseId'),
          selectedQuantity: BuiltValueNullFieldError.checkNotNull(
              selectedQuantity,
              r'SelectOrderSupplierResponsesRequestSelectionsInner',
              'selectedQuantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
