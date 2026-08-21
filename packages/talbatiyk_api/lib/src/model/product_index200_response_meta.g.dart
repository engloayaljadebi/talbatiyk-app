// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_index200_response_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProductIndex200ResponseMeta extends ProductIndex200ResponseMeta {
  @override
  final int currentPage;
  @override
  final int? from;
  @override
  final int lastPage;
  @override
  final BuiltList<ProductIndex200ResponseMetaLinksInner> links;
  @override
  final String? path;
  @override
  final int perPage;
  @override
  final int? to;
  @override
  final int total;

  factory _$ProductIndex200ResponseMeta(
          [void Function(ProductIndex200ResponseMetaBuilder)? updates]) =>
      (ProductIndex200ResponseMetaBuilder()..update(updates))._build();

  _$ProductIndex200ResponseMeta._(
      {required this.currentPage,
      this.from,
      required this.lastPage,
      required this.links,
      this.path,
      required this.perPage,
      this.to,
      required this.total})
      : super._();
  @override
  ProductIndex200ResponseMeta rebuild(
          void Function(ProductIndex200ResponseMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductIndex200ResponseMetaBuilder toBuilder() =>
      ProductIndex200ResponseMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductIndex200ResponseMeta &&
        currentPage == other.currentPage &&
        from == other.from &&
        lastPage == other.lastPage &&
        links == other.links &&
        path == other.path &&
        perPage == other.perPage &&
        to == other.to &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currentPage.hashCode);
    _$hash = $jc(_$hash, from.hashCode);
    _$hash = $jc(_$hash, lastPage.hashCode);
    _$hash = $jc(_$hash, links.hashCode);
    _$hash = $jc(_$hash, path.hashCode);
    _$hash = $jc(_$hash, perPage.hashCode);
    _$hash = $jc(_$hash, to.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProductIndex200ResponseMeta')
          ..add('currentPage', currentPage)
          ..add('from', from)
          ..add('lastPage', lastPage)
          ..add('links', links)
          ..add('path', path)
          ..add('perPage', perPage)
          ..add('to', to)
          ..add('total', total))
        .toString();
  }
}

class ProductIndex200ResponseMetaBuilder
    implements
        Builder<ProductIndex200ResponseMeta,
            ProductIndex200ResponseMetaBuilder> {
  _$ProductIndex200ResponseMeta? _$v;

  int? _currentPage;
  int? get currentPage => _$this._currentPage;
  set currentPage(int? currentPage) => _$this._currentPage = currentPage;

  int? _from;
  int? get from => _$this._from;
  set from(int? from) => _$this._from = from;

  int? _lastPage;
  int? get lastPage => _$this._lastPage;
  set lastPage(int? lastPage) => _$this._lastPage = lastPage;

  ListBuilder<ProductIndex200ResponseMetaLinksInner>? _links;
  ListBuilder<ProductIndex200ResponseMetaLinksInner> get links =>
      _$this._links ??= ListBuilder<ProductIndex200ResponseMetaLinksInner>();
  set links(ListBuilder<ProductIndex200ResponseMetaLinksInner>? links) =>
      _$this._links = links;

  String? _path;
  String? get path => _$this._path;
  set path(String? path) => _$this._path = path;

  int? _perPage;
  int? get perPage => _$this._perPage;
  set perPage(int? perPage) => _$this._perPage = perPage;

  int? _to;
  int? get to => _$this._to;
  set to(int? to) => _$this._to = to;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  ProductIndex200ResponseMetaBuilder() {
    ProductIndex200ResponseMeta._defaults(this);
  }

  ProductIndex200ResponseMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _currentPage = $v.currentPage;
      _from = $v.from;
      _lastPage = $v.lastPage;
      _links = $v.links.toBuilder();
      _path = $v.path;
      _perPage = $v.perPage;
      _to = $v.to;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductIndex200ResponseMeta other) {
    _$v = other as _$ProductIndex200ResponseMeta;
  }

  @override
  void update(void Function(ProductIndex200ResponseMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductIndex200ResponseMeta build() => _build();

  _$ProductIndex200ResponseMeta _build() {
    _$ProductIndex200ResponseMeta _$result;
    try {
      _$result = _$v ??
          _$ProductIndex200ResponseMeta._(
            currentPage: BuiltValueNullFieldError.checkNotNull(
                currentPage, r'ProductIndex200ResponseMeta', 'currentPage'),
            from: from,
            lastPage: BuiltValueNullFieldError.checkNotNull(
                lastPage, r'ProductIndex200ResponseMeta', 'lastPage'),
            links: links.build(),
            path: path,
            perPage: BuiltValueNullFieldError.checkNotNull(
                perPage, r'ProductIndex200ResponseMeta', 'perPage'),
            to: to,
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'ProductIndex200ResponseMeta', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'links';
        links.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProductIndex200ResponseMeta', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
