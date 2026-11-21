// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response_comparison_show200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderResponseComparisonShow200Response
    extends OrderResponseComparisonShow200Response {
  @override
  final OrderResponseComparisonResource data;

  factory _$OrderResponseComparisonShow200Response(
          [void Function(OrderResponseComparisonShow200ResponseBuilder)?
              updates]) =>
      (OrderResponseComparisonShow200ResponseBuilder()..update(updates))
          ._build();

  _$OrderResponseComparisonShow200Response._({required this.data}) : super._();
  @override
  OrderResponseComparisonShow200Response rebuild(
          void Function(OrderResponseComparisonShow200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderResponseComparisonShow200ResponseBuilder toBuilder() =>
      OrderResponseComparisonShow200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderResponseComparisonShow200Response &&
        data == other.data;
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
    return (newBuiltValueToStringHelper(
            r'OrderResponseComparisonShow200Response')
          ..add('data', data))
        .toString();
  }
}

class OrderResponseComparisonShow200ResponseBuilder
    implements
        Builder<OrderResponseComparisonShow200Response,
            OrderResponseComparisonShow200ResponseBuilder> {
  _$OrderResponseComparisonShow200Response? _$v;

  OrderResponseComparisonResourceBuilder? _data;
  OrderResponseComparisonResourceBuilder get data =>
      _$this._data ??= OrderResponseComparisonResourceBuilder();
  set data(OrderResponseComparisonResourceBuilder? data) => _$this._data = data;

  OrderResponseComparisonShow200ResponseBuilder() {
    OrderResponseComparisonShow200Response._defaults(this);
  }

  OrderResponseComparisonShow200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderResponseComparisonShow200Response other) {
    _$v = other as _$OrderResponseComparisonShow200Response;
  }

  @override
  void update(
      void Function(OrderResponseComparisonShow200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderResponseComparisonShow200Response build() => _build();

  _$OrderResponseComparisonShow200Response _build() {
    _$OrderResponseComparisonShow200Response _$result;
    try {
      _$result = _$v ??
          _$OrderResponseComparisonShow200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OrderResponseComparisonShow200Response',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
