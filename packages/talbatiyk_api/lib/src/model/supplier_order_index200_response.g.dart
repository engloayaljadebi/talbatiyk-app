// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_order_index200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierOrderIndex200Response extends SupplierOrderIndex200Response {
  @override
  final BuiltList<OrderRecipientResource> data;

  factory _$SupplierOrderIndex200Response(
          [void Function(SupplierOrderIndex200ResponseBuilder)? updates]) =>
      (SupplierOrderIndex200ResponseBuilder()..update(updates))._build();

  _$SupplierOrderIndex200Response._({required this.data}) : super._();
  @override
  SupplierOrderIndex200Response rebuild(
          void Function(SupplierOrderIndex200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierOrderIndex200ResponseBuilder toBuilder() =>
      SupplierOrderIndex200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierOrderIndex200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'SupplierOrderIndex200Response')
          ..add('data', data))
        .toString();
  }
}

class SupplierOrderIndex200ResponseBuilder
    implements
        Builder<SupplierOrderIndex200Response,
            SupplierOrderIndex200ResponseBuilder> {
  _$SupplierOrderIndex200Response? _$v;

  ListBuilder<OrderRecipientResource>? _data;
  ListBuilder<OrderRecipientResource> get data =>
      _$this._data ??= ListBuilder<OrderRecipientResource>();
  set data(ListBuilder<OrderRecipientResource>? data) => _$this._data = data;

  SupplierOrderIndex200ResponseBuilder() {
    SupplierOrderIndex200Response._defaults(this);
  }

  SupplierOrderIndex200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierOrderIndex200Response other) {
    _$v = other as _$SupplierOrderIndex200Response;
  }

  @override
  void update(void Function(SupplierOrderIndex200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierOrderIndex200Response build() => _build();

  _$SupplierOrderIndex200Response _build() {
    _$SupplierOrderIndex200Response _$result;
    try {
      _$result = _$v ??
          _$SupplierOrderIndex200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupplierOrderIndex200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
