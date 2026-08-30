// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_recipient_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderRecipientResource extends OrderRecipientResource {
  @override
  final String id;
  @override
  final String orderId;
  @override
  final String supplierId;
  @override
  final String supplierName;
  @override
  final String orderStatus;
  @override
  final String? notes;
  @override
  final BuiltList<OrderRecipientItemResource> items;
  @override
  final OrderRecipientResponseResource? response;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$OrderRecipientResource(
          [void Function(OrderRecipientResourceBuilder)? updates]) =>
      (OrderRecipientResourceBuilder()..update(updates))._build();

  _$OrderRecipientResource._(
      {required this.id,
      required this.orderId,
      required this.supplierId,
      required this.supplierName,
      required this.orderStatus,
      this.notes,
      required this.items,
      this.response,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  OrderRecipientResource rebuild(
          void Function(OrderRecipientResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderRecipientResourceBuilder toBuilder() =>
      OrderRecipientResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderRecipientResource &&
        id == other.id &&
        orderId == other.orderId &&
        supplierId == other.supplierId &&
        supplierName == other.supplierName &&
        orderStatus == other.orderStatus &&
        notes == other.notes &&
        items == other.items &&
        response == other.response &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, orderId.hashCode);
    _$hash = $jc(_$hash, supplierId.hashCode);
    _$hash = $jc(_$hash, supplierName.hashCode);
    _$hash = $jc(_$hash, orderStatus.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, response.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderRecipientResource')
          ..add('id', id)
          ..add('orderId', orderId)
          ..add('supplierId', supplierId)
          ..add('supplierName', supplierName)
          ..add('orderStatus', orderStatus)
          ..add('notes', notes)
          ..add('items', items)
          ..add('response', response)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class OrderRecipientResourceBuilder
    implements Builder<OrderRecipientResource, OrderRecipientResourceBuilder> {
  _$OrderRecipientResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _orderId;
  String? get orderId => _$this._orderId;
  set orderId(String? orderId) => _$this._orderId = orderId;

  String? _supplierId;
  String? get supplierId => _$this._supplierId;
  set supplierId(String? supplierId) => _$this._supplierId = supplierId;

  String? _supplierName;
  String? get supplierName => _$this._supplierName;
  set supplierName(String? supplierName) => _$this._supplierName = supplierName;

  String? _orderStatus;
  String? get orderStatus => _$this._orderStatus;
  set orderStatus(String? orderStatus) => _$this._orderStatus = orderStatus;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ListBuilder<OrderRecipientItemResource>? _items;
  ListBuilder<OrderRecipientItemResource> get items =>
      _$this._items ??= ListBuilder<OrderRecipientItemResource>();
  set items(ListBuilder<OrderRecipientItemResource>? items) =>
      _$this._items = items;

  OrderRecipientResponseResourceBuilder? _response;
  OrderRecipientResponseResourceBuilder get response =>
      _$this._response ??= OrderRecipientResponseResourceBuilder();
  set response(OrderRecipientResponseResourceBuilder? response) =>
      _$this._response = response;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  OrderRecipientResourceBuilder() {
    OrderRecipientResource._defaults(this);
  }

  OrderRecipientResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _orderId = $v.orderId;
      _supplierId = $v.supplierId;
      _supplierName = $v.supplierName;
      _orderStatus = $v.orderStatus;
      _notes = $v.notes;
      _items = $v.items.toBuilder();
      _response = $v.response?.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderRecipientResource other) {
    _$v = other as _$OrderRecipientResource;
  }

  @override
  void update(void Function(OrderRecipientResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderRecipientResource build() => _build();

  _$OrderRecipientResource _build() {
    _$OrderRecipientResource _$result;
    try {
      _$result = _$v ??
          _$OrderRecipientResource._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OrderRecipientResource', 'id'),
            orderId: BuiltValueNullFieldError.checkNotNull(
                orderId, r'OrderRecipientResource', 'orderId'),
            supplierId: BuiltValueNullFieldError.checkNotNull(
                supplierId, r'OrderRecipientResource', 'supplierId'),
            supplierName: BuiltValueNullFieldError.checkNotNull(
                supplierName, r'OrderRecipientResource', 'supplierName'),
            orderStatus: BuiltValueNullFieldError.checkNotNull(
                orderStatus, r'OrderRecipientResource', 'orderStatus'),
            notes: notes,
            items: items.build(),
            response: _response?.build(),
            createdAt: createdAt,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
        _$failedField = 'response';
        _response?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OrderRecipientResource', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
