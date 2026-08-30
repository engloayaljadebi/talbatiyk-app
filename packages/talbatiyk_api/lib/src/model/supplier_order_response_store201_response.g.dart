// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_order_response_store201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierOrderResponseStore201Response
    extends SupplierOrderResponseStore201Response {
  @override
  final OrderRecipientResponseResource data;

  factory _$SupplierOrderResponseStore201Response(
          [void Function(SupplierOrderResponseStore201ResponseBuilder)?
              updates]) =>
      (SupplierOrderResponseStore201ResponseBuilder()..update(updates))
          ._build();

  _$SupplierOrderResponseStore201Response._({required this.data}) : super._();
  @override
  SupplierOrderResponseStore201Response rebuild(
          void Function(SupplierOrderResponseStore201ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierOrderResponseStore201ResponseBuilder toBuilder() =>
      SupplierOrderResponseStore201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierOrderResponseStore201Response && data == other.data;
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
            r'SupplierOrderResponseStore201Response')
          ..add('data', data))
        .toString();
  }
}

class SupplierOrderResponseStore201ResponseBuilder
    implements
        Builder<SupplierOrderResponseStore201Response,
            SupplierOrderResponseStore201ResponseBuilder> {
  _$SupplierOrderResponseStore201Response? _$v;

  OrderRecipientResponseResourceBuilder? _data;
  OrderRecipientResponseResourceBuilder get data =>
      _$this._data ??= OrderRecipientResponseResourceBuilder();
  set data(OrderRecipientResponseResourceBuilder? data) => _$this._data = data;

  SupplierOrderResponseStore201ResponseBuilder() {
    SupplierOrderResponseStore201Response._defaults(this);
  }

  SupplierOrderResponseStore201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierOrderResponseStore201Response other) {
    _$v = other as _$SupplierOrderResponseStore201Response;
  }

  @override
  void update(
      void Function(SupplierOrderResponseStore201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierOrderResponseStore201Response build() => _build();

  _$SupplierOrderResponseStore201Response _build() {
    _$SupplierOrderResponseStore201Response _$result;
    try {
      _$result = _$v ??
          _$SupplierOrderResponseStore201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupplierOrderResponseStore201Response',
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
