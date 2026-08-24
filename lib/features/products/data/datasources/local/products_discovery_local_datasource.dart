import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../domain/entities/products_entity.dart';
import '../../models/products_model.dart';
import '../products_datasource.dart';

/// Drift cache dedicated to customer Product Discovery.
///
/// The server snapshot is authoritative for this table. Supplier-management
/// records and Outbox operations live elsewhere and are never touched here.
final class ProductsDiscoveryLocalDataSource
    implements ProductsCacheDataSource {
  ProductsDiscoveryLocalDataSource(this.database);

  final AppDatabase database;

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final query = database.select(database.productDiscoveryRecords)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);

    final records = await query.get();

    return List<ProductModel>.unmodifiable(
      records.map((record) {
        return ProductModel(
          id: record.id,
          supplierId: record.supplierId,
          supplierName: record.supplierName,
          name: record.name,
          price: record.price,
          imageUrl: record.remoteImageUrl ?? '',
          category: record.category,
          brand: record.brand,
          isAvailable: record.isAvailable,
          description: record.description,
          colors: _decodeColors(record.colorsJson),
          quantity: record.quantity,
          discount: record.discount,
          rating: record.rating,
          syncStatus: ProductSyncStatus.synced,
          createdAt: record.createdAt,
          updatedAt: record.updatedAt,
        );
      }),
    );
  }

  @override
  Future<void> replaceCachedProducts(List<ProductModel> products) async {
    final now = DateTime.now().toUtc();

    // Defensive deduplication keeps one authoritative row per server ID even
    // if an unexpected duplicate reaches this boundary.
    final productsById = <String, ProductModel>{
      for (final product in products) product.id: product,
    };

    await database.transaction(() async {
      // This table contains only the previous server discovery snapshot,
      // therefore a successful refresh may safely replace it in full.
      await database.delete(database.productDiscoveryRecords).go();

      for (final product in productsById.values) {
        final createdAt = (product.createdAt ?? now).toUtc();
        final updatedAt = (product.updatedAt ?? now).toUtc();

        await database
            .into(database.productDiscoveryRecords)
            .insertOnConflictUpdate(
              ProductDiscoveryRecordsCompanion.insert(
                id: product.id,
                supplierId: product.supplierId,
                supplierName: product.supplierName,
                name: product.name,
                price: product.price,
                category: Value(product.category),
                brand: Value(product.brand),
                description: Value(product.description),
                quantity: Value(product.quantity),
                isAvailable: Value(product.isAvailable),
                discount: Value(product.discount),
                rating: Value(product.rating),
                colorsJson: Value(jsonEncode(product.colors)),
                remoteImageUrl: Value(
                  product.imageUrl.trim().isEmpty ? null : product.imageUrl,
                ),
                createdAt: createdAt,
                updatedAt: updatedAt,
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
      // Corrupted cache data should degrade to an empty color list instead of
      // preventing the rest of the offline catalog from loading.
    }

    return const [];
  }
}
