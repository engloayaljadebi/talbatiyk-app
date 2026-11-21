// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_product_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateProductRequest extends UpdateProductRequest {
  @override
  final int expectedVersion;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String category;
  @override
  final String? brand;
  @override
  final num price;
  @override
  final int quantity;
  @override
  final bool isAvailable;
  @override
  final bool? removeImage;
  @override
  final String? supplierId;
  @override
  final String? supplierName;
  @override
  final String? imageUrl;
  @override
  final String? version;
  @override
  final String? rating;
  @override
  final String? discount;
  @override
  final String? colors;
  @override
  final String? idempotencyKey;
  @override
  final String? idempotencyPayloadHash;
  @override
  final String? deletedAt;

  factory _$UpdateProductRequest(
          [void Function(UpdateProductRequestBuilder)? updates]) =>
      (UpdateProductRequestBuilder()..update(updates))._build();

  _$UpdateProductRequest._(
      {required this.expectedVersion,
      required this.name,
      this.description,
      required this.category,
      this.brand,
      required this.price,
      required this.quantity,
      required this.isAvailable,
      this.removeImage,
      this.supplierId,
      this.supplierName,
      this.imageUrl,
      this.version,
      this.rating,
      this.discount,
      this.colors,
      this.idempotencyKey,
      this.idempotencyPayloadHash,
      this.deletedAt})
      : super._();
  @override
  UpdateProductRequest rebuild(
          void Function(UpdateProductRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateProductRequestBuilder toBuilder() =>
      UpdateProductRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateProductRequest &&
        expectedVersion == other.expectedVersion &&
        name == other.name &&
        description == other.description &&
        category == other.category &&
        brand == other.brand &&
        price == other.price &&
        quantity == other.quantity &&
        isAvailable == other.isAvailable &&
        removeImage == other.removeImage &&
        supplierId == other.supplierId &&
        supplierName == other.supplierName &&
        imageUrl == other.imageUrl &&
        version == other.version &&
        rating == other.rating &&
        discount == other.discount &&
        colors == other.colors &&
        idempotencyKey == other.idempotencyKey &&
        idempotencyPayloadHash == other.idempotencyPayloadHash &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedVersion.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, brand.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, isAvailable.hashCode);
    _$hash = $jc(_$hash, removeImage.hashCode);
    _$hash = $jc(_$hash, supplierId.hashCode);
    _$hash = $jc(_$hash, supplierName.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jc(_$hash, discount.hashCode);
    _$hash = $jc(_$hash, colors.hashCode);
    _$hash = $jc(_$hash, idempotencyKey.hashCode);
    _$hash = $jc(_$hash, idempotencyPayloadHash.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateProductRequest')
          ..add('expectedVersion', expectedVersion)
          ..add('name', name)
          ..add('description', description)
          ..add('category', category)
          ..add('brand', brand)
          ..add('price', price)
          ..add('quantity', quantity)
          ..add('isAvailable', isAvailable)
          ..add('removeImage', removeImage)
          ..add('supplierId', supplierId)
          ..add('supplierName', supplierName)
          ..add('imageUrl', imageUrl)
          ..add('version', version)
          ..add('rating', rating)
          ..add('discount', discount)
          ..add('colors', colors)
          ..add('idempotencyKey', idempotencyKey)
          ..add('idempotencyPayloadHash', idempotencyPayloadHash)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class UpdateProductRequestBuilder
    implements Builder<UpdateProductRequest, UpdateProductRequestBuilder> {
  _$UpdateProductRequest? _$v;

  int? _expectedVersion;
  int? get expectedVersion => _$this._expectedVersion;
  set expectedVersion(int? expectedVersion) =>
      _$this._expectedVersion = expectedVersion;

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

  bool? _removeImage;
  bool? get removeImage => _$this._removeImage;
  set removeImage(bool? removeImage) => _$this._removeImage = removeImage;

  String? _supplierId;
  String? get supplierId => _$this._supplierId;
  set supplierId(String? supplierId) => _$this._supplierId = supplierId;

  String? _supplierName;
  String? get supplierName => _$this._supplierName;
  set supplierName(String? supplierName) => _$this._supplierName = supplierName;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  String? _rating;
  String? get rating => _$this._rating;
  set rating(String? rating) => _$this._rating = rating;

  String? _discount;
  String? get discount => _$this._discount;
  set discount(String? discount) => _$this._discount = discount;

  String? _colors;
  String? get colors => _$this._colors;
  set colors(String? colors) => _$this._colors = colors;

  String? _idempotencyKey;
  String? get idempotencyKey => _$this._idempotencyKey;
  set idempotencyKey(String? idempotencyKey) =>
      _$this._idempotencyKey = idempotencyKey;

  String? _idempotencyPayloadHash;
  String? get idempotencyPayloadHash => _$this._idempotencyPayloadHash;
  set idempotencyPayloadHash(String? idempotencyPayloadHash) =>
      _$this._idempotencyPayloadHash = idempotencyPayloadHash;

  String? _deletedAt;
  String? get deletedAt => _$this._deletedAt;
  set deletedAt(String? deletedAt) => _$this._deletedAt = deletedAt;

  UpdateProductRequestBuilder() {
    UpdateProductRequest._defaults(this);
  }

  UpdateProductRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedVersion = $v.expectedVersion;
      _name = $v.name;
      _description = $v.description;
      _category = $v.category;
      _brand = $v.brand;
      _price = $v.price;
      _quantity = $v.quantity;
      _isAvailable = $v.isAvailable;
      _removeImage = $v.removeImage;
      _supplierId = $v.supplierId;
      _supplierName = $v.supplierName;
      _imageUrl = $v.imageUrl;
      _version = $v.version;
      _rating = $v.rating;
      _discount = $v.discount;
      _colors = $v.colors;
      _idempotencyKey = $v.idempotencyKey;
      _idempotencyPayloadHash = $v.idempotencyPayloadHash;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateProductRequest other) {
    _$v = other as _$UpdateProductRequest;
  }

  @override
  void update(void Function(UpdateProductRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateProductRequest build() => _build();

  _$UpdateProductRequest _build() {
    final _$result = _$v ??
        _$UpdateProductRequest._(
          expectedVersion: BuiltValueNullFieldError.checkNotNull(
              expectedVersion, r'UpdateProductRequest', 'expectedVersion'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'UpdateProductRequest', 'name'),
          description: description,
          category: BuiltValueNullFieldError.checkNotNull(
              category, r'UpdateProductRequest', 'category'),
          brand: brand,
          price: BuiltValueNullFieldError.checkNotNull(
              price, r'UpdateProductRequest', 'price'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'UpdateProductRequest', 'quantity'),
          isAvailable: BuiltValueNullFieldError.checkNotNull(
              isAvailable, r'UpdateProductRequest', 'isAvailable'),
          removeImage: removeImage,
          supplierId: supplierId,
          supplierName: supplierName,
          imageUrl: imageUrl,
          version: version,
          rating: rating,
          discount: discount,
          colors: colors,
          idempotencyKey: idempotencyKey,
          idempotencyPayloadHash: idempotencyPayloadHash,
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
