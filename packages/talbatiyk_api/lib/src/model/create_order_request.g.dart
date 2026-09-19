// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateOrderRequest extends CreateOrderRequest {
  @override
  final String? notes;
  @override
  final BuiltList<String> supplierIds;
  @override
  final BuiltList<CreateOrderRequestItemsInner> items;

  factory _$CreateOrderRequest(
          [void Function(CreateOrderRequestBuilder)? updates]) =>
      (CreateOrderRequestBuilder()..update(updates))._build();

  _$CreateOrderRequest._(
      {this.notes, required this.supplierIds, required this.items})
      : super._();
  @override
  CreateOrderRequest rebuild(
          void Function(CreateOrderRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateOrderRequestBuilder toBuilder() =>
      CreateOrderRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateOrderRequest &&
        notes == other.notes &&
        supplierIds == other.supplierIds &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, supplierIds.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateOrderRequest')
          ..add('notes', notes)
          ..add('supplierIds', supplierIds)
          ..add('items', items))
        .toString();
  }
}

class CreateOrderRequestBuilder
    implements Builder<CreateOrderRequest, CreateOrderRequestBuilder> {
  _$CreateOrderRequest? _$v;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ListBuilder<String>? _supplierIds;
  ListBuilder<String> get supplierIds =>
      _$this._supplierIds ??= ListBuilder<String>();
  set supplierIds(ListBuilder<String>? supplierIds) =>
      _$this._supplierIds = supplierIds;

  ListBuilder<CreateOrderRequestItemsInner>? _items;
  ListBuilder<CreateOrderRequestItemsInner> get items =>
      _$this._items ??= ListBuilder<CreateOrderRequestItemsInner>();
  set items(ListBuilder<CreateOrderRequestItemsInner>? items) =>
      _$this._items = items;

  CreateOrderRequestBuilder() {
    CreateOrderRequest._defaults(this);
  }

  CreateOrderRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _notes = $v.notes;
      _supplierIds = $v.supplierIds.toBuilder();
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateOrderRequest other) {
    _$v = other as _$CreateOrderRequest;
  }

  @override
  void update(void Function(CreateOrderRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateOrderRequest build() => _build();

  _$CreateOrderRequest _build() {
    _$CreateOrderRequest _$result;
    try {
      _$result = _$v ??
          _$CreateOrderRequest._(
            notes: notes,
            supplierIds: supplierIds.build(),
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'supplierIds';
        supplierIds.build();
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CreateOrderRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
