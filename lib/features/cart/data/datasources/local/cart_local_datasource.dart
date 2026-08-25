import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../products/domain/entities/products_entity.dart';
import '../../../domain/entities/cart_item_entity.dart';

final class CartLocalDataSource {
  CartLocalDataSource(this.database);

  final AppDatabase database;

  Future<List<CartItemEntity>> getItems() async {
    final query = database.select(database.cartItemRecords)
      ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]);

    final records = await query.get();

    return List<CartItemEntity>.unmodifiable(
      records.map((record) {
        return CartItemEntity(
          product: ProductEntity(
            id: record.productId,
            supplierId: record.supplierId,
            supplierName: record.supplierName,
            name: record.productName,
            price: record.price,
            imageUrl: record.imageUrl,
            localImagePath: record.localImagePath,
            category: record.category,
            brand: record.brand,
            isAvailable: record.isAvailable,
            description: record.description,
            colors: _decodeColors(record.colorsJson),
            quantity: record.productQuantity,
            discount: record.discount,
            rating: record.rating,
            syncStatus: _decodeSyncStatus(record.syncStatus),
            syncError: record.syncError,
            createdAt: record.productCreatedAt?.toUtc(),
            updatedAt: record.productUpdatedAt?.toUtc(),
          ),
          quantity: record.cartQuantity,
        );
      }),
    );
  }

  Future<void> replaceItems(List<CartItemEntity> items) async {
    final now = DateTime.now().toUtc();

    await database.transaction(() async {
      await database.delete(database.cartItemRecords).go();

      for (var index = 0; index < items.length; index++) {
        final item = items[index];
        final product = item.product;

        await database
            .into(database.cartItemRecords)
            .insert(
              CartItemRecordsCompanion.insert(
                productId: product.id,
                supplierId: Value(product.supplierId),
                supplierName: Value(product.supplierName),
                productName: product.name,
                price: product.price,
                imageUrl: Value(product.imageUrl),
                localImagePath: Value(product.localImagePath),
                category: Value(product.category),
                brand: Value(product.brand),
                isAvailable: Value(product.isAvailable),
                description: Value(product.description),
                colorsJson: Value(jsonEncode(product.colors)),
                productQuantity: Value(product.quantity),
                discount: Value(product.discount),
                rating: Value(product.rating),
                syncStatus: Value(product.syncStatus.name),
                syncError: Value(product.syncError),
                productCreatedAt: Value(product.createdAt?.toUtc()),
                productUpdatedAt: Value(product.updatedAt?.toUtc()),
                cartQuantity: item.quantity,
                sortOrder: index,
                updatedAt: now,
              ),
            );
      }
    });
  }

  List<String> _decodeColors(String value) {
    try {
      final decoded = jsonDecode(value);

      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } catch (_) {
      // Corrupt optional metadata must not prevent Cart restoration.
    }

    return const [];
  }

  ProductSyncStatus _decodeSyncStatus(String value) {
    for (final status in ProductSyncStatus.values) {
      if (status.name == value) {
        return status;
      }
    }

    return ProductSyncStatus.synced;
  }
}
