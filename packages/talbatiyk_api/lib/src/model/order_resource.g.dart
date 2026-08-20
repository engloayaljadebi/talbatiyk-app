// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderResource extends OrderResource {
  @override
  final String id;
  @override
  final String status;
  @override
  final String? notes;
  @override
  final BuiltList<OrderItemResource> items;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$OrderResource([void Function(OrderResourceBuilder)? updates]) =>
      (OrderResourceBuilder()..update(updates))._build();

  _$OrderResource._(
      {required this.id,
      required this.status,
      this.notes,
      required this.items,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  OrderResource rebuild(void Function(OrderResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderResourceBuilder toBuilder() => OrderResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderResource &&
        id == other.id &&
        status == other.status &&
        notes == other.notes &&
        items == other.items &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderResource')
          ..add('id', id)
          ..add('status', status)
          ..add('notes', notes)
          ..add('items', items)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class OrderResourceBuilder
    implements Builder<OrderResource, OrderResourceBuilder> {
  _$OrderResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ListBuilder<OrderItemResource>? _items;
  ListBuilder<OrderItemResource> get items =>
      _$this._items ??= ListBuilder<OrderItemResource>();
  set items(ListBuilder<OrderItemResource>? items) => _$this._items = items;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  OrderResourceBuilder() {
    OrderResource._defaults(this);
  }

  OrderResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _notes = $v.notes;
      _items = $v.items.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderResource other) {
    _$v = other as _$OrderResource;
  }

  @override
  void update(void Function(OrderResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderResource build() => _build();

  _$OrderResource _build() {
    _$OrderResource _$result;
    try {
      _$result = _$v ??
          _$OrderResource._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OrderResource', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'OrderResource', 'status'),
            notes: notes,
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
            r'OrderResource', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
