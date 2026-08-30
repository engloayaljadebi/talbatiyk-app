// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_recipient_item_response_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderRecipientItemResponseResource
    extends OrderRecipientItemResponseResource {
  @override
  final String id;
  @override
  final String orderRecipientItemId;
  @override
  final int requestedQuantity;
  @override
  final int availableQuantity;
  @override
  final AvailabilityStatus availabilityStatus;
  @override
  final String? offeredUnitPrice;
  @override
  final String? responseNotes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$OrderRecipientItemResponseResource(
          [void Function(OrderRecipientItemResponseResourceBuilder)?
              updates]) =>
      (OrderRecipientItemResponseResourceBuilder()..update(updates))._build();

  _$OrderRecipientItemResponseResource._(
      {required this.id,
      required this.orderRecipientItemId,
      required this.requestedQuantity,
      required this.availableQuantity,
      required this.availabilityStatus,
      this.offeredUnitPrice,
      this.responseNotes,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  OrderRecipientItemResponseResource rebuild(
          void Function(OrderRecipientItemResponseResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderRecipientItemResponseResourceBuilder toBuilder() =>
      OrderRecipientItemResponseResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderRecipientItemResponseResource &&
        id == other.id &&
        orderRecipientItemId == other.orderRecipientItemId &&
        requestedQuantity == other.requestedQuantity &&
        availableQuantity == other.availableQuantity &&
        availabilityStatus == other.availabilityStatus &&
        offeredUnitPrice == other.offeredUnitPrice &&
        responseNotes == other.responseNotes &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, orderRecipientItemId.hashCode);
    _$hash = $jc(_$hash, requestedQuantity.hashCode);
    _$hash = $jc(_$hash, availableQuantity.hashCode);
    _$hash = $jc(_$hash, availabilityStatus.hashCode);
    _$hash = $jc(_$hash, offeredUnitPrice.hashCode);
    _$hash = $jc(_$hash, responseNotes.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderRecipientItemResponseResource')
          ..add('id', id)
          ..add('orderRecipientItemId', orderRecipientItemId)
          ..add('requestedQuantity', requestedQuantity)
          ..add('availableQuantity', availableQuantity)
          ..add('availabilityStatus', availabilityStatus)
          ..add('offeredUnitPrice', offeredUnitPrice)
          ..add('responseNotes', responseNotes)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class OrderRecipientItemResponseResourceBuilder
    implements
        Builder<OrderRecipientItemResponseResource,
            OrderRecipientItemResponseResourceBuilder> {
  _$OrderRecipientItemResponseResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _orderRecipientItemId;
  String? get orderRecipientItemId => _$this._orderRecipientItemId;
  set orderRecipientItemId(String? orderRecipientItemId) =>
      _$this._orderRecipientItemId = orderRecipientItemId;

  int? _requestedQuantity;
  int? get requestedQuantity => _$this._requestedQuantity;
  set requestedQuantity(int? requestedQuantity) =>
      _$this._requestedQuantity = requestedQuantity;

  int? _availableQuantity;
  int? get availableQuantity => _$this._availableQuantity;
  set availableQuantity(int? availableQuantity) =>
      _$this._availableQuantity = availableQuantity;

  AvailabilityStatus? _availabilityStatus;
  AvailabilityStatus? get availabilityStatus => _$this._availabilityStatus;
  set availabilityStatus(AvailabilityStatus? availabilityStatus) =>
      _$this._availabilityStatus = availabilityStatus;

  String? _offeredUnitPrice;
  String? get offeredUnitPrice => _$this._offeredUnitPrice;
  set offeredUnitPrice(String? offeredUnitPrice) =>
      _$this._offeredUnitPrice = offeredUnitPrice;

  String? _responseNotes;
  String? get responseNotes => _$this._responseNotes;
  set responseNotes(String? responseNotes) =>
      _$this._responseNotes = responseNotes;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  OrderRecipientItemResponseResourceBuilder() {
    OrderRecipientItemResponseResource._defaults(this);
  }

  OrderRecipientItemResponseResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _orderRecipientItemId = $v.orderRecipientItemId;
      _requestedQuantity = $v.requestedQuantity;
      _availableQuantity = $v.availableQuantity;
      _availabilityStatus = $v.availabilityStatus;
      _offeredUnitPrice = $v.offeredUnitPrice;
      _responseNotes = $v.responseNotes;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderRecipientItemResponseResource other) {
    _$v = other as _$OrderRecipientItemResponseResource;
  }

  @override
  void update(
      void Function(OrderRecipientItemResponseResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderRecipientItemResponseResource build() => _build();

  _$OrderRecipientItemResponseResource _build() {
    final _$result = _$v ??
        _$OrderRecipientItemResponseResource._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OrderRecipientItemResponseResource', 'id'),
          orderRecipientItemId: BuiltValueNullFieldError.checkNotNull(
              orderRecipientItemId,
              r'OrderRecipientItemResponseResource',
              'orderRecipientItemId'),
          requestedQuantity: BuiltValueNullFieldError.checkNotNull(
              requestedQuantity,
              r'OrderRecipientItemResponseResource',
              'requestedQuantity'),
          availableQuantity: BuiltValueNullFieldError.checkNotNull(
              availableQuantity,
              r'OrderRecipientItemResponseResource',
              'availableQuantity'),
          availabilityStatus: BuiltValueNullFieldError.checkNotNull(
              availabilityStatus,
              r'OrderRecipientItemResponseResource',
              'availabilityStatus'),
          offeredUnitPrice: offeredUnitPrice,
          responseNotes: responseNotes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
