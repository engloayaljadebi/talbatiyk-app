import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';

import '../../mappers/products_mapper.dart';
import '../../models/products_model.dart';
import '../products_datasource.dart';

/// Reads discoverable products from the generated OpenAPI client.
///
/// This source is intentionally read-only. Local product writes remain on the
/// existing local datasource until their dedicated synchronization gate.
final class ProductsRemoteDataSource
    implements
        ProductsDataSource,
        ProductsCreateDataSource,
        ProductsIdempotentCreateDataSource {
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
}
