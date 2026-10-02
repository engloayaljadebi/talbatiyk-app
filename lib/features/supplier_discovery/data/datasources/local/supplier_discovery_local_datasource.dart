import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../domain/entities/supplier_candidate_entity.dart';

final class SupplierDiscoveryLocalDataSource {
  const SupplierDiscoveryLocalDataSource(this._database);

  final AppDatabase _database;

  Future<void> replace({
    required String userId,
    required List<SupplierCandidateEntity> suppliers,
  }) async {
    await _database.transaction(() async {
      await _database.customStatement(
        'DELETE FROM supplier_discovery_cache WHERE user_id = ?',
        [userId],
      );
      for (final supplier in suppliers) {
        await _database.customStatement(
          'INSERT INTO supplier_discovery_cache (user_id, supplier_id, name) '
          'VALUES (?, ?, ?)',
          [userId, supplier.id, supplier.name],
        );
      }
    });
  }

  Future<List<SupplierCandidateEntity>> readSnapshot({
    required String userId,
  }) async {
    final rows = await _database
        .customSelect(
          'SELECT supplier_id, name FROM supplier_discovery_cache '
          'WHERE user_id = ? ORDER BY name, supplier_id',
          variables: [Variable.withString(userId)],
        )
        .get();

    return List.unmodifiable(
      rows.map(
        (row) => SupplierCandidateEntity(
          id: row.read<String>('supplier_id'),
          name: row.read<String>('name'),
          isFromCache: true,
        ),
      ),
    );
  }
}
