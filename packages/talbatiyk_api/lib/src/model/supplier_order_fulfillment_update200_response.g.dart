// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_order_fulfillment_update200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierOrderFulfillmentUpdate200Response
    extends SupplierOrderFulfillmentUpdate200Response {
  @override
  final OrderRecipientResource data;

  factory _$SupplierOrderFulfillmentUpdate200Response(
          [void Function(SupplierOrderFulfillmentUpdate200ResponseBuilder)?
              updates]) =>
      (SupplierOrderFulfillmentUpdate200ResponseBuilder()..update(updates))
          ._build();

  _$SupplierOrderFulfillmentUpdate200Response._({required this.data})
      : super._();
  @override
  SupplierOrderFulfillmentUpdate200Response rebuild(
          void Function(SupplierOrderFulfillmentUpdate200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierOrderFulfillmentUpdate200ResponseBuilder toBuilder() =>
      SupplierOrderFulfillmentUpdate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierOrderFulfillmentUpdate200Response &&
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
            r'SupplierOrderFulfillmentUpdate200Response')
          ..add('data', data))
        .toString();
  }
}

class SupplierOrderFulfillmentUpdate200ResponseBuilder
    implements
        Builder<SupplierOrderFulfillmentUpdate200Response,
            SupplierOrderFulfillmentUpdate200ResponseBuilder> {
  _$SupplierOrderFulfillmentUpdate200Response? _$v;

  OrderRecipientResourceBuilder? _data;
  OrderRecipientResourceBuilder get data =>
      _$this._data ??= OrderRecipientResourceBuilder();
  set data(OrderRecipientResourceBuilder? data) => _$this._data = data;

  SupplierOrderFulfillmentUpdate200ResponseBuilder() {
    SupplierOrderFulfillmentUpdate200Response._defaults(this);
  }

  SupplierOrderFulfillmentUpdate200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierOrderFulfillmentUpdate200Response other) {
    _$v = other as _$SupplierOrderFulfillmentUpdate200Response;
  }

  @override
  void update(
      void Function(SupplierOrderFulfillmentUpdate200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierOrderFulfillmentUpdate200Response build() => _build();

  _$SupplierOrderFulfillmentUpdate200Response _build() {
    _$SupplierOrderFulfillmentUpdate200Response _$result;
    try {
      _$result = _$v ??
          _$SupplierOrderFulfillmentUpdate200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupplierOrderFulfillmentUpdate200Response',
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
