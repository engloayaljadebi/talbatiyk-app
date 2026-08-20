// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_store201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderStore201Response extends OrderStore201Response {
  @override
  final OrderResource data;

  factory _$OrderStore201Response(
          [void Function(OrderStore201ResponseBuilder)? updates]) =>
      (OrderStore201ResponseBuilder()..update(updates))._build();

  _$OrderStore201Response._({required this.data}) : super._();
  @override
  OrderStore201Response rebuild(
          void Function(OrderStore201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderStore201ResponseBuilder toBuilder() =>
      OrderStore201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderStore201Response && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderStore201Response')
          ..add('data', data))
        .toString();
  }
}

class OrderStore201ResponseBuilder
    implements Builder<OrderStore201Response, OrderStore201ResponseBuilder> {
  _$OrderStore201Response? _$v;

  OrderResourceBuilder? _data;
  OrderResourceBuilder get data => _$this._data ??= OrderResourceBuilder();
  set data(OrderResourceBuilder? data) => _$this._data = data;

  OrderStore201ResponseBuilder() {
    OrderStore201Response._defaults(this);
  }

  OrderStore201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderStore201Response other) {
    _$v = other as _$OrderStore201Response;
  }

  @override
  void update(void Function(OrderStore201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderStore201Response build() => _build();

  _$OrderStore201Response _build() {
    _$OrderStore201Response _$result;
    try {
      _$result = _$v ??
          _$OrderStore201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OrderStore201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
