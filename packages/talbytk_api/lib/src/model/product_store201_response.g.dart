// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_store201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProductStore201Response extends ProductStore201Response {
  @override
  final ProductResource data;

  factory _$ProductStore201Response(
          [void Function(ProductStore201ResponseBuilder)? updates]) =>
      (ProductStore201ResponseBuilder()..update(updates))._build();

  _$ProductStore201Response._({required this.data}) : super._();
  @override
  ProductStore201Response rebuild(
          void Function(ProductStore201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductStore201ResponseBuilder toBuilder() =>
      ProductStore201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductStore201Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ProductStore201Response')
          ..add('data', data))
        .toString();
  }
}

class ProductStore201ResponseBuilder
    implements
        Builder<ProductStore201Response, ProductStore201ResponseBuilder> {
  _$ProductStore201Response? _$v;

  ProductResourceBuilder? _data;
  ProductResourceBuilder get data => _$this._data ??= ProductResourceBuilder();
  set data(ProductResourceBuilder? data) => _$this._data = data;

  ProductStore201ResponseBuilder() {
    ProductStore201Response._defaults(this);
  }

  ProductStore201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductStore201Response other) {
    _$v = other as _$ProductStore201Response;
  }

  @override
  void update(void Function(ProductStore201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductStore201Response build() => _build();

  _$ProductStore201Response _build() {
    _$ProductStore201Response _$result;
    try {
      _$result = _$v ??
          _$ProductStore201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProductStore201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
