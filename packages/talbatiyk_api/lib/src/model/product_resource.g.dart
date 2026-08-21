// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProductResource extends ProductResource {
  @override
  final String id;
  @override
  final String supplierId;
  @override
  final String supplierName;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String category;
  @override
  final String brand;
  @override
  final num price;
  @override
  final int quantity;
  @override
  final bool isAvailable;
  @override
  final String? imageUrl;
  @override
  final BuiltList<String> colors;
  @override
  final num discount;
  @override
  final num rating;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  factory _$ProductResource([void Function(ProductResourceBuilder)? updates]) =>
      (ProductResourceBuilder()..update(updates))._build();

  _$ProductResource._(
      {required this.id,
      required this.supplierId,
      required this.supplierName,
      required this.name,
      this.description,
      required this.category,
      required this.brand,
      required this.price,
      required this.quantity,
      required this.isAvailable,
      this.imageUrl,
      required this.colors,
      required this.discount,
      required this.rating,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  ProductResource rebuild(void Function(ProductResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductResourceBuilder toBuilder() => ProductResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductResource &&
        id == other.id &&
        supplierId == other.supplierId &&
        supplierName == other.supplierName &&
        name == other.name &&
        description == other.description &&
        category == other.category &&
        brand == other.brand &&
        price == other.price &&
        quantity == other.quantity &&
        isAvailable == other.isAvailable &&
        imageUrl == other.imageUrl &&
        colors == other.colors &&
        discount == other.discount &&
        rating == other.rating &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, supplierId.hashCode);
    _$hash = $jc(_$hash, supplierName.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, brand.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, isAvailable.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, colors.hashCode);
    _$hash = $jc(_$hash, discount.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProductResource')
          ..add('id', id)
          ..add('supplierId', supplierId)
          ..add('supplierName', supplierName)
          ..add('name', name)
          ..add('description', description)
          ..add('category', category)
          ..add('brand', brand)
          ..add('price', price)
          ..add('quantity', quantity)
          ..add('isAvailable', isAvailable)
          ..add('imageUrl', imageUrl)
          ..add('colors', colors)
          ..add('discount', discount)
          ..add('rating', rating)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class ProductResourceBuilder
    implements Builder<ProductResource, ProductResourceBuilder> {
  _$ProductResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _supplierId;
  String? get supplierId => _$this._supplierId;
  set supplierId(String? supplierId) => _$this._supplierId = supplierId;

  String? _supplierName;
  String? get supplierName => _$this._supplierName;
  set supplierName(String? supplierName) => _$this._supplierName = supplierName;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  String? _brand;
  String? get brand => _$this._brand;
  set brand(String? brand) => _$this._brand = brand;

  num? _price;
  num? get price => _$this._price;
  set price(num? price) => _$this._price = price;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  bool? _isAvailable;
  bool? get isAvailable => _$this._isAvailable;
  set isAvailable(bool? isAvailable) => _$this._isAvailable = isAvailable;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  ListBuilder<String>? _colors;
  ListBuilder<String> get colors => _$this._colors ??= ListBuilder<String>();
  set colors(ListBuilder<String>? colors) => _$this._colors = colors;

  num? _discount;
  num? get discount => _$this._discount;
  set discount(num? discount) => _$this._discount = discount;

  num? _rating;
  num? get rating => _$this._rating;
  set rating(num? rating) => _$this._rating = rating;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  String? _updatedAt;
  String? get updatedAt => _$this._updatedAt;
  set updatedAt(String? updatedAt) => _$this._updatedAt = updatedAt;

  ProductResourceBuilder() {
    ProductResource._defaults(this);
  }

  ProductResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _supplierId = $v.supplierId;
      _supplierName = $v.supplierName;
      _name = $v.name;
      _description = $v.description;
      _category = $v.category;
      _brand = $v.brand;
      _price = $v.price;
      _quantity = $v.quantity;
      _isAvailable = $v.isAvailable;
      _imageUrl = $v.imageUrl;
      _colors = $v.colors.toBuilder();
      _discount = $v.discount;
      _rating = $v.rating;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductResource other) {
    _$v = other as _$ProductResource;
  }

  @override
  void update(void Function(ProductResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductResource build() => _build();

  _$ProductResource _build() {
    _$ProductResource _$result;
    try {
      _$result = _$v ??
          _$ProductResource._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ProductResource', 'id'),
            supplierId: BuiltValueNullFieldError.checkNotNull(
                supplierId, r'ProductResource', 'supplierId'),
            supplierName: BuiltValueNullFieldError.checkNotNull(
                supplierName, r'ProductResource', 'supplierName'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ProductResource', 'name'),
            description: description,
            category: BuiltValueNullFieldError.checkNotNull(
                category, r'ProductResource', 'category'),
            brand: BuiltValueNullFieldError.checkNotNull(
                brand, r'ProductResource', 'brand'),
            price: BuiltValueNullFieldError.checkNotNull(
                price, r'ProductResource', 'price'),
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'ProductResource', 'quantity'),
            isAvailable: BuiltValueNullFieldError.checkNotNull(
                isAvailable, r'ProductResource', 'isAvailable'),
            imageUrl: imageUrl,
            colors: colors.build(),
            discount: BuiltValueNullFieldError.checkNotNull(
                discount, r'ProductResource', 'discount'),
            rating: BuiltValueNullFieldError.checkNotNull(
                rating, r'ProductResource', 'rating'),
            createdAt: createdAt,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'colors';
        colors.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProductResource', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
