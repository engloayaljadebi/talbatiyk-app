// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_index200_response_meta_links_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProductIndex200ResponseMetaLinksInner
    extends ProductIndex200ResponseMetaLinksInner {
  @override
  final String? url;
  @override
  final String label;
  @override
  final bool active;

  factory _$ProductIndex200ResponseMetaLinksInner(
          [void Function(ProductIndex200ResponseMetaLinksInnerBuilder)?
              updates]) =>
      (ProductIndex200ResponseMetaLinksInnerBuilder()..update(updates))
          ._build();

  _$ProductIndex200ResponseMetaLinksInner._(
      {this.url, required this.label, required this.active})
      : super._();
  @override
  ProductIndex200ResponseMetaLinksInner rebuild(
          void Function(ProductIndex200ResponseMetaLinksInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductIndex200ResponseMetaLinksInnerBuilder toBuilder() =>
      ProductIndex200ResponseMetaLinksInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductIndex200ResponseMetaLinksInner &&
        url == other.url &&
        label == other.label &&
        active == other.active;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ProductIndex200ResponseMetaLinksInner')
          ..add('url', url)
          ..add('label', label)
          ..add('active', active))
        .toString();
  }
}

class ProductIndex200ResponseMetaLinksInnerBuilder
    implements
        Builder<ProductIndex200ResponseMetaLinksInner,
            ProductIndex200ResponseMetaLinksInnerBuilder> {
  _$ProductIndex200ResponseMetaLinksInner? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  ProductIndex200ResponseMetaLinksInnerBuilder() {
    ProductIndex200ResponseMetaLinksInner._defaults(this);
  }

  ProductIndex200ResponseMetaLinksInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _label = $v.label;
      _active = $v.active;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductIndex200ResponseMetaLinksInner other) {
    _$v = other as _$ProductIndex200ResponseMetaLinksInner;
  }

  @override
  void update(
      void Function(ProductIndex200ResponseMetaLinksInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductIndex200ResponseMetaLinksInner build() => _build();

  _$ProductIndex200ResponseMetaLinksInner _build() {
    final _$result = _$v ??
        _$ProductIndex200ResponseMetaLinksInner._(
          url: url,
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'ProductIndex200ResponseMetaLinksInner', 'label'),
          active: BuiltValueNullFieldError.checkNotNull(
              active, r'ProductIndex200ResponseMetaLinksInner', 'active'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
