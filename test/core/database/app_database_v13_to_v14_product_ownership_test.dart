import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:talbatiyk/core/database/app_database.dart';

void main() {
  test('fresh database uses ownership schema version 14', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final productColumns = await db
        .customSelect("PRAGMA table_info('product_records')")
        .get();

    final attemptColumns = await db
        .customSelect("PRAGMA table_info('product_publish_attempt_records')")
        .get();

    expect(db.schemaVersion, 14);

    expect(
      productColumns.any((row) => row.data['name'] == 'owner_user_id'),
      isTrue,
      reason: 'Product management records require an account owner.',
    );

    expect(
      attemptColumns.any((row) => row.data['name'] == 'owner_user_id'),
      isTrue,
      reason: 'Durable publish attempts require an account owner.',
    );
  });

  test('v13 migration preserves legacy rows with unknown ownership', () async {
    final directory = await Directory.systemTemp.createTemp(
      'product-ownership-v13-',
    );

    final file = File(
      '${directory.path}${Platform.pathSeparator}database.sqlite',
    );

    _createV13Fixture(file);

    final db = AppDatabase.forTesting(NativeDatabase(file));

    try {
      final products = await db
          .customSelect(
            'SELECT id, name, sync_status, server_version '
            'FROM product_records',
          )
          .get();

      final attempts = await db
          .customSelect(
            'SELECT idempotency_key, client_product_id, '
            'status, attempts, local_image_path '
            'FROM product_publish_attempt_records',
          )
          .get();

      expect(products, hasLength(1));
      expect(products.single.read<String>('id'), 'legacy-product');
      expect(products.single.read<String>('name'), 'Preserved product');
      expect(products.single.read<String>('sync_status'), 'pendingUpdate');
      expect(products.single.read<int>('server_version'), 3);

      expect(attempts, hasLength(1));
      expect(attempts.single.read<String>('idempotency_key'), 'legacy-key');
      expect(attempts.single.read<String>('client_product_id'), 'client-old');
      expect(attempts.single.read<String>('status'), 'retrying');
      expect(attempts.single.read<int>('attempts'), 2);
      expect(
        attempts.single.read<String>('local_image_path'),
        '/tmp/legacy-image.jpg',
      );

      final productOwners = await db
          .customSelect(
            'SELECT owner_user_id FROM product_records '
            'WHERE id = ?',
            variables: [Variable.withString('legacy-product')],
          )
          .get();

      final attemptOwners = await db
          .customSelect(
            'SELECT owner_user_id FROM product_publish_attempt_records '
            'WHERE idempotency_key = ?',
            variables: [Variable.withString('legacy-key')],
          )
          .get();

      expect(db.schemaVersion, 14);

      expect(
        productOwners.single.data['owner_user_id'],
        isNull,
        reason: 'Never invent a user owner during legacy migration.',
      );

      expect(
        attemptOwners.single.data['owner_user_id'],
        isNull,
        reason: 'Legacy idempotency payload must remain unclaimed.',
      );
    } finally {
      await db.close();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  });

  test(
    'two accounts can cache the same server product independently',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      for (final owner in ['account-A', 'account-B']) {
        await db.customInsert(
          'INSERT INTO product_records '
          '(id, owner_user_id, supplier_id, supplier_name, '
          'name, price, created_at, updated_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          variables: [
            Variable.withString('shared-server-product'),
            Variable.withString(owner),
            Variable.withString('shared-business'),
            Variable.withString('Supplier'),
            Variable.withString('Product for $owner'),
            Variable.withReal(1500),
            Variable.withInt(1790000000),
            Variable.withInt(1790000000),
          ],
        );
      }

      final rows = await db
          .customSelect(
            'SELECT owner_user_id, name FROM product_records '
            'WHERE id = ?',
            variables: [Variable.withString('shared-server-product')],
          )
          .get();

      expect(rows, hasLength(2));

      expect(rows.map((row) => row.read<String>('owner_user_id')).toSet(), {
        'account-A',
        'account-B',
      });
    },
  );

  test(
    'two accounts can hold independent client publication identities',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      for (final owner in ['account-A', 'account-B']) {
        await db.customInsert(
          'INSERT INTO product_publish_attempt_records '
          '(idempotency_key, client_product_id, owner_user_id, '
          'supplier_id, supplier_name, name, category, '
          'price, quantity, is_available, created_at, updated_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          variables: [
            Variable.withString('unique-key-$owner'),
            Variable.withString('shared-client-product'),
            Variable.withString(owner),
            Variable.withString('shared-business'),
            Variable.withString('Supplier'),
            Variable.withString('Draft $owner'),
            Variable.withString('Electronics'),
            Variable.withReal(1000),
            Variable.withInt(2),
            Variable.withInt(1),
            Variable.withInt(1790000000),
            Variable.withInt(1790000000),
          ],
        );
      }

      final rows = await db
          .customSelect(
            'SELECT owner_user_id, idempotency_key '
            'FROM product_publish_attempt_records '
            'WHERE client_product_id = ?',
            variables: [Variable.withString('shared-client-product')],
          )
          .get();

      expect(rows, hasLength(2));

      expect(rows.map((row) => row.read<String>('owner_user_id')).toSet(), {
        'account-A',
        'account-B',
      });
    },
  );
}

void _createV13Fixture(File file) {
  final raw = sqlite.sqlite3.open(file.path);

  try {
    raw.execute('''
      CREATE TABLE product_records (
        id TEXT NOT NULL PRIMARY KEY,
        supplier_id TEXT NOT NULL,
        supplier_name TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT '',
        brand TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        price REAL NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        is_available INTEGER NOT NULL DEFAULT 1,
        discount REAL NOT NULL DEFAULT 0,
        rating REAL NOT NULL DEFAULT 0,
        colors_json TEXT NOT NULL DEFAULT '[]',
        local_image_path TEXT NULL,
        remote_image_url TEXT NULL,
        server_version INTEGER NULL,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        sync_error TEXT NULL,
        sync_attempts INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER NULL
      );
    ''');

    raw.execute('''
      CREATE TABLE product_publish_attempt_records (
        idempotency_key TEXT NOT NULL PRIMARY KEY,
        client_product_id TEXT NOT NULL UNIQUE,
        supplier_id TEXT NOT NULL,
        supplier_name TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        brand TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        is_available INTEGER NOT NULL,
        local_image_path TEXT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT NULL,
        next_attempt_at INTEGER NULL,
        server_product_id TEXT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    raw.execute(
      'INSERT INTO product_records '
      '(id, supplier_id, supplier_name, name, price, '
      'server_version, sync_status, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'legacy-product',
        'supplier-old',
        'Supplier Old',
        'Preserved product',
        1500,
        3,
        'pendingUpdate',
        1790000000,
        1790000000,
      ],
    );

    raw.execute(
      'INSERT INTO product_publish_attempt_records '
      '(idempotency_key, client_product_id, supplier_id, '
      'supplier_name, name, category, price, quantity, '
      'is_available, local_image_path, status, attempts, '
      'created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'legacy-key',
        'client-old',
        'supplier-old',
        'Supplier Old',
        'Unfinished publication',
        'Electronics',
        500,
        1,
        1,
        '/tmp/legacy-image.jpg',
        'retrying',
        2,
        1790000000,
        1790000000,
      ],
    );

    raw.execute('PRAGMA user_version = 13;');
  } finally {
    raw.close();
  }
}
