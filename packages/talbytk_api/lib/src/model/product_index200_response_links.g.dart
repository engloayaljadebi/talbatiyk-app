// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_index200_response_links.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProductIndex200ResponseLinks extends ProductIndex200ResponseLinks {
  @override
  final String? first;
  @override
  final String? last;
  @override
  final String? prev;
  @override
  final String? next;

  factory _$ProductIndex200ResponseLinks(
          [void Function(ProductIndex200ResponseLinksBuilder)? updates]) =>
      (ProductIndex200ResponseLinksBuilder()..update(updates))._build();

  _$ProductIndex200ResponseLinks._(
      {this.first, this.last, this.prev, this.next})
      : super._();
  @override
  ProductIndex200ResponseLinks rebuild(
          void Function(ProductIndex200ResponseLinksBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductIndex200ResponseLinksBuilder toBuilder() =>
      ProductIndex200ResponseLinksBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductIndex200ResponseLinks &&
        first == other.first &&
        last == other.last &&
        prev == other.prev &&
        next == other.next;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, first.hashCode);
    _$hash = $jc(_$hash, last.hashCode);
    _$hash = $jc(_$hash, prev.hashCode);
    _$hash = $jc(_$hash, next.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProductIndex200ResponseLinks')
          ..add('first', first)
          ..add('last', last)
          ..add('prev', prev)
          ..add('next', next))
        .toString();
  }
}

class ProductIndex200ResponseLinksBuilder
    implements
        Builder<ProductIndex200ResponseLinks,
            ProductIndex200ResponseLinksBuilder> {
  _$ProductIndex200ResponseLinks? _$v;

  String? _first;
  String? get first => _$this._first;
  set first(String? first) => _$this._first = first;

  String? _last;
  String? get last => _$this._last;
  set last(String? last) => _$this._last = last;

  String? _prev;
  String? get prev => _$this._prev;
  set prev(String? prev) => _$this._prev = prev;

  String? _next;
  String? get next => _$this._next;
  set next(String? next) => _$this._next = next;

  ProductIndex200ResponseLinksBuilder() {
    ProductIndex200ResponseLinks._defaults(this);
  }

  ProductIndex200ResponseLinksBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _first = $v.first;
      _last = $v.last;
      _prev = $v.prev;
      _next = $v.next;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductIndex200ResponseLinks other) {
    _$v = other as _$ProductIndex200ResponseLinks;
  }

  @override
  void update(void Function(ProductIndex200ResponseLinksBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductIndex200ResponseLinks build() => _build();

  _$ProductIndex200ResponseLinks _build() {
    final _$result = _$v ??
        _$ProductIndex200ResponseLinks._(
          first: first,
          last: last,
          prev: prev,
          next: next,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
