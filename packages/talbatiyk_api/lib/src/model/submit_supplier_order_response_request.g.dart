// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_supplier_order_response_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SubmitSupplierOrderResponseRequest
    extends SubmitSupplierOrderResponseRequest {
  @override
  final BuiltList<SubmitSupplierOrderResponseRequestItemsInner> items;

  factory _$SubmitSupplierOrderResponseRequest(
          [void Function(SubmitSupplierOrderResponseRequestBuilder)?
              updates]) =>
      (SubmitSupplierOrderResponseRequestBuilder()..update(updates))._build();

  _$SubmitSupplierOrderResponseRequest._({required this.items}) : super._();
  @override
  SubmitSupplierOrderResponseRequest rebuild(
          void Function(SubmitSupplierOrderResponseRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SubmitSupplierOrderResponseRequestBuilder toBuilder() =>
      SubmitSupplierOrderResponseRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubmitSupplierOrderResponseRequest && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SubmitSupplierOrderResponseRequest')
          ..add('items', items))
        .toString();
  }
}

class SubmitSupplierOrderResponseRequestBuilder
    implements
        Builder<SubmitSupplierOrderResponseRequest,
            SubmitSupplierOrderResponseRequestBuilder> {
  _$SubmitSupplierOrderResponseRequest? _$v;

  ListBuilder<SubmitSupplierOrderResponseRequestItemsInner>? _items;
  ListBuilder<SubmitSupplierOrderResponseRequestItemsInner> get items =>
      _$this._items ??=
          ListBuilder<SubmitSupplierOrderResponseRequestItemsInner>();
  set items(ListBuilder<SubmitSupplierOrderResponseRequestItemsInner>? items) =>
      _$this._items = items;

  SubmitSupplierOrderResponseRequestBuilder() {
    SubmitSupplierOrderResponseRequest._defaults(this);
  }

  SubmitSupplierOrderResponseRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubmitSupplierOrderResponseRequest other) {
    _$v = other as _$SubmitSupplierOrderResponseRequest;
  }

  @override
  void update(
      void Function(SubmitSupplierOrderResponseRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubmitSupplierOrderResponseRequest build() => _build();

  _$SubmitSupplierOrderResponseRequest _build() {
    _$SubmitSupplierOrderResponseRequest _$result;
    try {
      _$result = _$v ??
          _$SubmitSupplierOrderResponseRequest._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SubmitSupplierOrderResponseRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
