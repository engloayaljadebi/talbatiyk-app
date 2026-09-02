// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_index200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderIndex200Response extends OrderIndex200Response {
  @override
  final BuiltList<OrderResource> data;

  factory _$OrderIndex200Response(
          [void Function(OrderIndex200ResponseBuilder)? updates]) =>
      (OrderIndex200ResponseBuilder()..update(updates))._build();

  _$OrderIndex200Response._({required this.data}) : super._();
  @override
  OrderIndex200Response rebuild(
          void Function(OrderIndex200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderIndex200ResponseBuilder toBuilder() =>
      OrderIndex200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderIndex200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OrderIndex200Response')
          ..add('data', data))
        .toString();
  }
}

class OrderIndex200ResponseBuilder
    implements Builder<OrderIndex200Response, OrderIndex200ResponseBuilder> {
  _$OrderIndex200Response? _$v;

  ListBuilder<OrderResource>? _data;
  ListBuilder<OrderResource> get data =>
      _$this._data ??= ListBuilder<OrderResource>();
  set data(ListBuilder<OrderResource>? data) => _$this._data = data;

  OrderIndex200ResponseBuilder() {
    OrderIndex200Response._defaults(this);
  }

  OrderIndex200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderIndex200Response other) {
    _$v = other as _$OrderIndex200Response;
  }

  @override
  void update(void Function(OrderIndex200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderIndex200Response build() => _build();

  _$OrderIndex200Response _build() {
    _$OrderIndex200Response _$result;
    try {
      _$result = _$v ??
          _$OrderIndex200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OrderIndex200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
