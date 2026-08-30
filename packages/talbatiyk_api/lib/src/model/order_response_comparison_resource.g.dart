// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response_comparison_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderResponseComparisonResource
    extends OrderResponseComparisonResource {
  @override
  final String id;
  @override
  final int version;
  @override
  final String status;
  @override
  final OrderAggregateStatus aggregateStatus;
  @override
  final String? notes;
  @override
  final BuiltList<OrderResponseComparisonItemResource> items;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$OrderResponseComparisonResource(
          [void Function(OrderResponseComparisonResourceBuilder)? updates]) =>
      (OrderResponseComparisonResourceBuilder()..update(updates))._build();

  _$OrderResponseComparisonResource._(
      {required this.id,
      required this.version,
      required this.status,
      required this.aggregateStatus,
      this.notes,
      required this.items,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  OrderResponseComparisonResource rebuild(
          void Function(OrderResponseComparisonResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderResponseComparisonResourceBuilder toBuilder() =>
      OrderResponseComparisonResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderResponseComparisonResource &&
        id == other.id &&
        version == other.version &&
        status == other.status &&
        aggregateStatus == other.aggregateStatus &&
        notes == other.notes &&
        items == other.items &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, aggregateStatus.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderResponseComparisonResource')
          ..add('id', id)
          ..add('version', version)
          ..add('status', status)
          ..add('aggregateStatus', aggregateStatus)
          ..add('notes', notes)
          ..add('items', items)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class OrderResponseComparisonResourceBuilder
    implements
        Builder<OrderResponseComparisonResource,
            OrderResponseComparisonResourceBuilder> {
  _$OrderResponseComparisonResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  OrderAggregateStatus? _aggregateStatus;
  OrderAggregateStatus? get aggregateStatus => _$this._aggregateStatus;
  set aggregateStatus(OrderAggregateStatus? aggregateStatus) =>
      _$this._aggregateStatus = aggregateStatus;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ListBuilder<OrderResponseComparisonItemResource>? _items;
  ListBuilder<OrderResponseComparisonItemResource> get items =>
      _$this._items ??= ListBuilder<OrderResponseComparisonItemResource>();
  set items(ListBuilder<OrderResponseComparisonItemResource>? items) =>
      _$this._items = items;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  OrderResponseComparisonResourceBuilder() {
    OrderResponseComparisonResource._defaults(this);
  }

  OrderResponseComparisonResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _version = $v.version;
      _status = $v.status;
      _aggregateStatus = $v.aggregateStatus;
      _notes = $v.notes;
      _items = $v.items.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderResponseComparisonResource other) {
    _$v = other as _$OrderResponseComparisonResource;
  }

  @override
  void update(void Function(OrderResponseComparisonResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderResponseComparisonResource build() => _build();

  _$OrderResponseComparisonResource _build() {
    _$OrderResponseComparisonResource _$result;
    try {
      _$result = _$v ??
          _$OrderResponseComparisonResource._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OrderResponseComparisonResource', 'id'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'OrderResponseComparisonResource', 'version'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'OrderResponseComparisonResource', 'status'),
            aggregateStatus: BuiltValueNullFieldError.checkNotNull(
                aggregateStatus,
                r'OrderResponseComparisonResource',
                'aggregateStatus'),
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
            r'OrderResponseComparisonResource', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
