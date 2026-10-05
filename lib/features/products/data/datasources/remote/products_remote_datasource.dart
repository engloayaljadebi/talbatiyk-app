import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

import '../../mappers/products_mapper.dart';
import '../../models/products_model.dart';
import '../products_datasource.dart';

/// Reads discoverable products from the generated OpenAPI client.
///
/// Reads, publishing, and supplier mutation requests use the generated OpenAPI client.
/// Outbox/retry/reconciliation policy remains outside this class.
final class ProductsRemoteDataSource
    implements
        ProductsDataSource,
        ProductsCreateDataSource,
        ProductsIdempotentCreateDataSource,
        ProductsMutationRemoteDataSource,
        ProductsSupplierManagementRemoteDataSource {
  ProductsRemoteDataSource(this._apiClient);

  static const int _perPage = 100;

  final GeneratedApiClient _apiClient;

  @override
  Future<List<ProductModel>> getProducts() async {
    final productsById = <String, ProductModel>{};

    var page = 1;

    while (true) {
      final response = await _apiClient.products.productIndex(
        page: page,
        perPage: _perPage,
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw StateError('Product discovery response does not contain data.');
      }

      for (final resource in responseBody.data) {
        final product = ProductsMapper.fromResource(resource);
        productsById[product.id] = product;
      }

      if (page >= responseBody.meta.lastPage) {
        break;
      }

      page += 1;
    }

    return List<ProductModel>.unmodifiable(productsById.values);
  }

  @override
  Future<List<ProductModel>> getBusinessProducts(String businessId) async {
    final normalizedBusinessId = businessId.trim();

    if (normalizedBusinessId.isEmpty) {
      throw ArgumentError('Business ID is required to load managed Products.');
    }

    final productsById = <String, ProductModel>{};

    var page = 1;

    while (true) {
      final response = await _apiClient.products.productBusinessIndex(
        business: normalizedBusinessId,
        page: page,
        perPage: _perPage,
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw StateError(
          'Supplier Product management response does not contain data.',
        );
      }

      for (final resource in responseBody.data) {
        final product = ProductsMapper.fromResource(resource);

        if (product.supplierId.trim() != normalizedBusinessId) {
          throw StateError(
            'Supplier Product management returned a Product outside '
            'the requested Business scope.',
          );
        }

        productsById[product.id] = product;
      }

      if (page >= responseBody.meta.lastPage) {
        break;
      }

      page += 1;
    }

    return List<ProductModel>.unmodifiable(productsById.values);
  }

  /// Publishes a supplier product directly to the server.
  ///
  /// This is intentionally online-only:
  /// - no local pendingCreate record is created here;
  /// - no Outbox operation is created here;
  /// - success means the server returned the persisted ProductResource.
  @override
  Future<ProductModel> createProduct(ProductModel product) {
    throw UnsupportedError(
      'Product Publishing requires a durable Idempotency-Key. '
      'Use createProductIdempotently().',
    );
  }

  @override
  Future<ProductModel> createProductIdempotently(
    ProductModel product, {
    required String idempotencyKey,
  }) async {
    final normalizedIdempotencyKey = idempotencyKey.trim();

    if (normalizedIdempotencyKey.isEmpty) {
      throw ArgumentError('مفتاح Idempotency مطلوب لنشر المنتج.');
    }
    final businessId = product.supplierId.trim();

    if (businessId.isEmpty) {
      throw ArgumentError('معرف النشاط التجاري مطلوب لنشر المنتج.');
    }

    final productName = product.name.trim();

    if (productName.isEmpty) {
      throw ArgumentError('اسم المنتج مطلوب.');
    }

    final category = product.category.trim();

    if (category.isEmpty) {
      throw ArgumentError('فئة المنتج مطلوبة.');
    }

    MultipartFile? image;

    final localImagePath = product.localImagePath?.trim();

    if (localImagePath != null && localImagePath.isNotEmpty) {
      final imageFile = File(localImagePath);

      if (!await imageFile.exists()) {
        throw StateError('صورة المنتج المحلية غير موجودة.');
      }

      image = await MultipartFile.fromFile(
        localImagePath,
        filename: imageFile.uri.pathSegments.last,
      );
    }

    final normalizedBrand = product.brand.trim();
    final normalizedDescription = product.description.trim();

    final response = await _apiClient.products.productStore(
      business: businessId,
      idempotencyKey: normalizedIdempotencyKey,
      name: productName,
      category: category,
      price: product.price,
      quantity: product.quantity,
      isAvailable: product.isAvailable,
      brand: normalizedBrand.isEmpty ? null : normalizedBrand,
      description: normalizedDescription.isEmpty ? null : normalizedDescription,
      image: image,
    );

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('استجابة نشر المنتج لا تحتوي على بيانات.');
    }

    /*
     * نعتمد هوية المنتج وبيانات المورد والرابط النهائي للصورة
     * من استجابة Laravel، وليس من المعرف المؤقت على الهاتف.
     */
    return ProductsMapper.fromResource(responseBody.data);
  }

  @override
  Future<ProductModel> updateProductMutation(
    ProductModel product, {
    required int expectedVersion,
    required bool removeImage,
  }) async {
    if (expectedVersion < 1) {
      throw ArgumentError.value(
        expectedVersion,
        'expectedVersion',
        'Expected Product version must be positive.',
      );
    }

    final businessId = product.supplierId.trim();
    final productId = product.id.trim();
    final name = product.name.trim();
    final category = product.category.trim();
    final brand = product.brand.trim();
    final description = product.description.trim();

    if (businessId.isEmpty || productId.isEmpty) {
      throw ArgumentError('Business ID and Product ID are required.');
    }

    if (name.isEmpty || category.isEmpty) {
      throw ArgumentError('Product name and category are required.');
    }

    final request = UpdateProductRequest(
      (builder) => builder
        ..expectedVersion = expectedVersion
        ..name = name
        ..description = description.isEmpty ? null : description
        ..category = category
        ..brand = brand.isEmpty ? null : brand
        ..price = product.price
        ..quantity = product.quantity
        ..isAvailable = product.isAvailable
        ..removeImage = removeImage,
    );

    final response = await _apiClient.products.productUpdate(
      business: businessId,
      product: productId,
      updateProductRequest: request,
    );

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('Product update response does not contain data.');
    }

    return ProductsMapper.fromResource(responseBody.data);
  }

  @override
  Future<ProductModel> updateProductImageMutation({
    required String businessId,
    required String productId,
    required int expectedVersion,
    required String localImagePath,
  }) async {
    final normalizedBusinessId = businessId.trim();
    final normalizedProductId = productId.trim();
    final normalizedImagePath = localImagePath.trim();

    if (normalizedBusinessId.isEmpty ||
        normalizedProductId.isEmpty ||
        normalizedImagePath.isEmpty) {
      throw ArgumentError(
        'Business ID, Product ID, and local image path are required.',
      );
    }

    if (expectedVersion < 1) {
      throw ArgumentError.value(
        expectedVersion,
        'expectedVersion',
        'Expected Product version must be positive.',
      );
    }

    final imageFile = File(normalizedImagePath);

    if (!await imageFile.exists()) {
      throw StateError('Local Product image does not exist.');
    }

    final image = await MultipartFile.fromFile(
      normalizedImagePath,
      filename: imageFile.uri.pathSegments.last,
    );

    final response = await _apiClient.products.productUpdateImage(
      business: normalizedBusinessId,
      product: normalizedProductId,
      expectedVersion: expectedVersion,
      image: image,
    );

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('Product image update response does not contain data.');
    }

    return ProductsMapper.fromResource(responseBody.data);
  }

  @override
  Future<void> deleteProductMutation({
    required String businessId,
    required String productId,
    required int expectedVersion,
  }) async {
    final normalizedBusinessId = businessId.trim();
    final normalizedProductId = productId.trim();

    if (normalizedBusinessId.isEmpty || normalizedProductId.isEmpty) {
      throw ArgumentError('Business ID and Product ID are required.');
    }

    if (expectedVersion < 1) {
      throw ArgumentError.value(
        expectedVersion,
        'expectedVersion',
        'Expected Product version must be positive.',
      );
    }

    await _apiClient.products.productDestroy(
      business: normalizedBusinessId,
      product: normalizedProductId,
      expectedVersion: expectedVersion,
    );
  }
}
