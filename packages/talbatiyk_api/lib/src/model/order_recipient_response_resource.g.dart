// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_recipient_response_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderRecipientResponseResource extends OrderRecipientResponseResource {
  @override
  final String id;
  @override
  final String orderRecipientId;
  @override
  final BuiltList<OrderRecipientItemResponseResource> items;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$OrderRecipientResponseResource(
          [void Function(OrderRecipientResponseResourceBuilder)? updates]) =>
      (OrderRecipientResponseResourceBuilder()..update(updates))._build();

  _$OrderRecipientResponseResource._(
      {required this.id,
      required this.orderRecipientId,
      required this.items,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  OrderRecipientResponseResource rebuild(
          void Function(OrderRecipientResponseResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderRecipientResponseResourceBuilder toBuilder() =>
      OrderRecipientResponseResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderRecipientResponseResource &&
        id == other.id &&
        orderRecipientId == other.orderRecipientId &&
        items == other.items &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, orderRecipientId.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderRecipientResponseResource')
          ..add('id', id)
          ..add('orderRecipientId', orderRecipientId)
          ..add('items', items)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class OrderRecipientResponseResourceBuilder
    implements
        Builder<OrderRecipientResponseResource,
            OrderRecipientResponseResourceBuilder> {
  _$OrderRecipientResponseResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _orderRecipientId;
  String? get orderRecipientId => _$this._orderRecipientId;
  set orderRecipientId(String? orderRecipientId) =>
      _$this._orderRecipientId = orderRecipientId;

  ListBuilder<OrderRecipientItemResponseResource>? _items;
  ListBuilder<OrderRecipientItemResponseResource> get items =>
      _$this._items ??= ListBuilder<OrderRecipientItemResponseResource>();
  set items(ListBuilder<OrderRecipientItemResponseResource>? items) =>
      _$this._items = items;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  OrderRecipientResponseResourceBuilder() {
    OrderRecipientResponseResource._defaults(this);
  }

  OrderRecipientResponseResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _orderRecipientId = $v.orderRecipientId;
      _items = $v.items.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderRecipientResponseResource other) {
    _$v = other as _$OrderRecipientResponseResource;
  }

  @override
  void update(void Function(OrderRecipientResponseResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderRecipientResponseResource build() => _build();

  _$OrderRecipientResponseResource _build() {
    _$OrderRecipientResponseResource _$result;
    try {
      _$result = _$v ??
          _$OrderRecipientResponseResource._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OrderRecipientResponseResource', 'id'),
            orderRecipientId: BuiltValueNullFieldError.checkNotNull(
                orderRecipientId,
                r'OrderRecipientResponseResource',
                'orderRecipientId'),
            items: items.build(),
            createdAt: createdAt,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OrderRecipientResponseResource', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
