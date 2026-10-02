import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/products/data/datasources/local/products_discovery_local_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';

void main() {
  test('Product Discovery persists supplier governorate offline', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    addTearDown(database.close);

    final local = ProductsDiscoveryLocalDataSource(database);

    await local.replaceCachedProducts(const [
      ProductModel(
        id: 'governorate-product',
        supplierId: 'supplier-1',
        supplierName: 'Supplier',
        supplierGovernorate: 'صنعاء',
        name: 'Governorate Product',
        price: 1500,
        imageUrl: '',
        category: 'Electronics',
        brand: 'Talbatiyk',
        isAvailable: true,
        quantity: 2,
      ),
    ]);

    final cached = await local.getCachedProducts();

    expect(cached, hasLength(1));

    expect(cached.single.supplierGovernorate, 'صنعاء');
  });
}
