import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/supplier_discovery/data/datasources/local/supplier_discovery_local_datasource.dart';
import 'package:talbatiyk/features/supplier_discovery/domain/entities/supplier_candidate_entity.dart';

void main() {
  test(
    'v8 upgrade preserves orders and creates user-scoped supplier cache',
    () async {
      final directory = await Directory.systemTemp.createTemp('supplier-v9-');
      addTearDown(() => directory.delete(recursive: true));
      final file = File(
        '${directory.path}${Platform.pathSeparator}test.sqlite',
      );

      // Start with the current schema, then remove only the v9 addition to
      // simulate an installed v8 database with its existing tables intact.
      final initial = AppDatabase.forTesting(NativeDatabase(file));
      await initial.select(initial.orderRecords).get();
      await initial.customStatement(
        "INSERT INTO order_records (id, status, aggregate_status, notes, "
        "created_at, updated_at) VALUES ('existing', 'pending', "
        "'pending_responses', '', 1, 1)",
      );
      await initial.close();

      final raw = sqlite.sqlite3.open(file.path);
      raw.execute('DROP TABLE supplier_discovery_cache');
      raw.execute('PRAGMA user_version = 8');
      raw.close();

      final upgraded = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(upgraded.close);
      final local = SupplierDiscoveryLocalDataSource(upgraded);
      expect(
        (await upgraded.select(upgraded.orderRecords).get()).single.id,
        'existing',
      );
      await local.replace(
        userId: 'user-a',
        suppliers: const [SupplierCandidateEntity(id: 'supplier-a', name: 'A')],
      );
      expect(
        (await local.readSnapshot(userId: 'user-a')).single.id,
        'supplier-a',
      );
      expect(await local.readSnapshot(userId: 'user-b'), isEmpty);
      expect(upgraded.schemaVersion, 11);
    },
  );
}
