// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_index200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProductIndex200Response extends ProductIndex200Response {
  @override
  final BuiltList<ProductResource> data;
  @override
  final ProductIndex200ResponseLinks links;
  @override
  final ProductIndex200ResponseMeta meta;

  factory _$ProductIndex200Response(
          [void Function(ProductIndex200ResponseBuilder)? updates]) =>
      (ProductIndex200ResponseBuilder()..update(updates))._build();

  _$ProductIndex200Response._(
      {required this.data, required this.links, required this.meta})
      : super._();
  @override
  ProductIndex200Response rebuild(
          void Function(ProductIndex200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductIndex200ResponseBuilder toBuilder() =>
      ProductIndex200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductIndex200Response &&
        data == other.data &&
        links == other.links &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, links.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProductIndex200Response')
          ..add('data', data)
          ..add('links', links)
          ..add('meta', meta))
        .toString();
  }
}

class ProductIndex200ResponseBuilder
    implements
        Builder<ProductIndex200Response, ProductIndex200ResponseBuilder> {
  _$ProductIndex200Response? _$v;

  ListBuilder<ProductResource>? _data;
  ListBuilder<ProductResource> get data =>
      _$this._data ??= ListBuilder<ProductResource>();
  set data(ListBuilder<ProductResource>? data) => _$this._data = data;

  ProductIndex200ResponseLinksBuilder? _links;
  ProductIndex200ResponseLinksBuilder get links =>
      _$this._links ??= ProductIndex200ResponseLinksBuilder();
  set links(ProductIndex200ResponseLinksBuilder? links) =>
      _$this._links = links;

  ProductIndex200ResponseMetaBuilder? _meta;
  ProductIndex200ResponseMetaBuilder get meta =>
      _$this._meta ??= ProductIndex200ResponseMetaBuilder();
  set meta(ProductIndex200ResponseMetaBuilder? meta) => _$this._meta = meta;

  ProductIndex200ResponseBuilder() {
    ProductIndex200Response._defaults(this);
  }

  ProductIndex200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _links = $v.links.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductIndex200Response other) {
    _$v = other as _$ProductIndex200Response;
  }

  @override
  void update(void Function(ProductIndex200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductIndex200Response build() => _build();

  _$ProductIndex200Response _build() {
    _$ProductIndex200Response _$result;
    try {
      _$result = _$v ??
          _$ProductIndex200Response._(
            data: data.build(),
            links: links.build(),
            meta: meta.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'links';
        links.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProductIndex200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
