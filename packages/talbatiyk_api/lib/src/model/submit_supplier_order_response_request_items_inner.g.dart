// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_supplier_order_response_request_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SubmitSupplierOrderResponseRequestItemsInner
    extends SubmitSupplierOrderResponseRequestItemsInner {
  @override
  final String orderRecipientItemId;
  @override
  final AvailabilityStatus availabilityStatus;
  @override
  final int availableQuantity;
  @override
  final num? offeredUnitPrice;
  @override
  final String? responseNotes;

  factory _$SubmitSupplierOrderResponseRequestItemsInner(
          [void Function(SubmitSupplierOrderResponseRequestItemsInnerBuilder)?
              updates]) =>
      (SubmitSupplierOrderResponseRequestItemsInnerBuilder()..update(updates))
          ._build();

  _$SubmitSupplierOrderResponseRequestItemsInner._(
      {required this.orderRecipientItemId,
      required this.availabilityStatus,
      required this.availableQuantity,
      this.offeredUnitPrice,
      this.responseNotes})
      : super._();
  @override
  SubmitSupplierOrderResponseRequestItemsInner rebuild(
          void Function(SubmitSupplierOrderResponseRequestItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SubmitSupplierOrderResponseRequestItemsInnerBuilder toBuilder() =>
      SubmitSupplierOrderResponseRequestItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubmitSupplierOrderResponseRequestItemsInner &&
        orderRecipientItemId == other.orderRecipientItemId &&
        availabilityStatus == other.availabilityStatus &&
        availableQuantity == other.availableQuantity &&
        offeredUnitPrice == other.offeredUnitPrice &&
        responseNotes == other.responseNotes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, orderRecipientItemId.hashCode);
    _$hash = $jc(_$hash, availabilityStatus.hashCode);
    _$hash = $jc(_$hash, availableQuantity.hashCode);
    _$hash = $jc(_$hash, offeredUnitPrice.hashCode);
    _$hash = $jc(_$hash, responseNotes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SubmitSupplierOrderResponseRequestItemsInner')
          ..add('orderRecipientItemId', orderRecipientItemId)
          ..add('availabilityStatus', availabilityStatus)
          ..add('availableQuantity', availableQuantity)
          ..add('offeredUnitPrice', offeredUnitPrice)
          ..add('responseNotes', responseNotes))
        .toString();
  }
}

class SubmitSupplierOrderResponseRequestItemsInnerBuilder
    implements
        Builder<SubmitSupplierOrderResponseRequestItemsInner,
            SubmitSupplierOrderResponseRequestItemsInnerBuilder> {
  _$SubmitSupplierOrderResponseRequestItemsInner? _$v;

  String? _orderRecipientItemId;
  String? get orderRecipientItemId => _$this._orderRecipientItemId;
  set orderRecipientItemId(String? orderRecipientItemId) =>
      _$this._orderRecipientItemId = orderRecipientItemId;

  AvailabilityStatus? _availabilityStatus;
  AvailabilityStatus? get availabilityStatus => _$this._availabilityStatus;
  set availabilityStatus(AvailabilityStatus? availabilityStatus) =>
      _$this._availabilityStatus = availabilityStatus;

  int? _availableQuantity;
  int? get availableQuantity => _$this._availableQuantity;
  set availableQuantity(int? availableQuantity) =>
      _$this._availableQuantity = availableQuantity;

  num? _offeredUnitPrice;
  num? get offeredUnitPrice => _$this._offeredUnitPrice;
  set offeredUnitPrice(num? offeredUnitPrice) =>
      _$this._offeredUnitPrice = offeredUnitPrice;

  String? _responseNotes;
  String? get responseNotes => _$this._responseNotes;
  set responseNotes(String? responseNotes) =>
      _$this._responseNotes = responseNotes;

  SubmitSupplierOrderResponseRequestItemsInnerBuilder() {
    SubmitSupplierOrderResponseRequestItemsInner._defaults(this);
  }

  SubmitSupplierOrderResponseRequestItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _orderRecipientItemId = $v.orderRecipientItemId;
      _availabilityStatus = $v.availabilityStatus;
      _availableQuantity = $v.availableQuantity;
      _offeredUnitPrice = $v.offeredUnitPrice;
      _responseNotes = $v.responseNotes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubmitSupplierOrderResponseRequestItemsInner other) {
    _$v = other as _$SubmitSupplierOrderResponseRequestItemsInner;
  }

  @override
  void update(
      void Function(SubmitSupplierOrderResponseRequestItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SubmitSupplierOrderResponseRequestItemsInner build() => _build();

  _$SubmitSupplierOrderResponseRequestItemsInner _build() {
    final _$result = _$v ??
        _$SubmitSupplierOrderResponseRequestItemsInner._(
          orderRecipientItemId: BuiltValueNullFieldError.checkNotNull(
              orderRecipientItemId,
              r'SubmitSupplierOrderResponseRequestItemsInner',
              'orderRecipientItemId'),
          availabilityStatus: BuiltValueNullFieldError.checkNotNull(
              availabilityStatus,
              r'SubmitSupplierOrderResponseRequestItemsInner',
              'availabilityStatus'),
          availableQuantity: BuiltValueNullFieldError.checkNotNull(
              availableQuantity,
              r'SubmitSupplierOrderResponseRequestItemsInner',
              'availableQuantity'),
          offeredUnitPrice: offeredUnitPrice,
          responseNotes: responseNotes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
