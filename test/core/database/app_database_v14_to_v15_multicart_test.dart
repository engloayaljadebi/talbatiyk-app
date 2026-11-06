import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:talbatiyk/core/database/app_database.dart';

void main() {
  test('v15 supports independent carts and manual items', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 16);

    for (final owner in ['account-A', 'account-B']) {
      await db.customInsert(
        'INSERT INTO cart_records '
        '(id, owner_user_id, name, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?)',
        variables: [
          Variable.withString('cart-$owner'),
          Variable.withString(owner),
          Variable.withString('Cart for $owner'),
          Variable.withInt(1790000000),
          Variable.withInt(1790000000),
        ],
      );

      await db.customInsert(
        'INSERT INTO cart_item_records '
        '(id, cart_id, kind, product_id, product_name, '
        'price, cart_quantity, sort_order, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        variables: [
          Variable.withString('item-$owner'),
          Variable.withString('cart-$owner'),
          Variable.withString('catalog'),
          Variable.withString('same-product'),
          Variable.withString('Shared product'),
          Variable.withReal(1500),
          Variable.withInt(2),
          Variable.withInt(0),
          Variable.withInt(1790000000),
        ],
      );
    }

    await db.customInsert(
      'INSERT INTO cart_item_records '
      '(id, cart_id, kind, product_id, product_name, '
      'price, cart_quantity, sort_order, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString('manual-item'),
        Variable.withString('cart-account-A'),
        Variable.withString('manual'),
        const Variable<String>(null),
        Variable.withString('Manual product'),
        Variable.withReal(500),
        Variable.withInt(3),
        Variable.withInt(1),
        Variable.withInt(1790000000),
      ],
    );

    final rows = await db
        .customSelect(
          'SELECT id, cart_id, kind, product_id '
          'FROM cart_item_records ORDER BY id',
        )
        .get();

    expect(rows, hasLength(3));

    final catalogItems = rows.where(
      (row) => row.read<String>('kind') == 'catalog',
    );

    expect(catalogItems.length, 2);
    expect(catalogItems.map((row) => row.read<String>('cart_id')).toSet(), {
      'cart-account-A',
      'cart-account-B',
    });

    final manual = rows.singleWhere(
      (row) => row.read<String>('id') == 'manual-item',
    );

    expect(manual.data['product_id'], isNull);
    expect(manual.read<String>('kind'), 'manual');
  });

  test('v14 to v15 preserves cart, orders and outbox', () async {
    final directory = await Directory.systemTemp.createTemp(
      'talbatiyk-multicart-v14-',
    );

    try {
      final file = File(
        '${directory.path}${Platform.pathSeparator}test.sqlite',
      );

      final raw = sqlite.sqlite3.open(file.path);

      try {
        raw.execute('''
          CREATE TABLE cart_item_records (
            product_id TEXT NOT NULL PRIMARY KEY,
            supplier_id TEXT NOT NULL DEFAULT '',
            supplier_name TEXT NOT NULL DEFAULT '',
            product_name TEXT NOT NULL,
            price REAL NOT NULL,
            image_url TEXT NOT NULL DEFAULT '',
            local_image_path TEXT,
            category TEXT NOT NULL DEFAULT '',
            brand TEXT NOT NULL DEFAULT '',
            is_available INTEGER NOT NULL DEFAULT 1,
            description TEXT NOT NULL DEFAULT '',
            colors_json TEXT NOT NULL DEFAULT '[]',
            product_quantity INTEGER NOT NULL DEFAULT 0,
            discount REAL NOT NULL DEFAULT 0,
            rating REAL NOT NULL DEFAULT 0,
            sync_status TEXT NOT NULL DEFAULT 'synced',
            sync_error TEXT,
            product_created_at INTEGER,
            product_updated_at INTEGER,
            cart_quantity INTEGER NOT NULL,
            sort_order INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          );

          CREATE TABLE order_records (
            id TEXT NOT NULL PRIMARY KEY,
            owner_user_id TEXT,
            status TEXT NOT NULL DEFAULT 'pending',
            aggregate_status TEXT NOT NULL DEFAULT 'pending_responses',
            notes TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          );

          CREATE TABLE order_item_records (
            id TEXT NOT NULL PRIMARY KEY,
            order_id TEXT NOT NULL REFERENCES order_records(id)
              ON DELETE CASCADE,
            product_id TEXT NOT NULL,
            supplier_id TEXT NOT NULL,
            supplier_name TEXT NOT NULL DEFAULT '',
            product_name TEXT NOT NULL,
            unit_price REAL NOT NULL,
            quantity INTEGER NOT NULL,
            image_url TEXT NOT NULL DEFAULT ''
          );

          CREATE TABLE sync_operations (
            id TEXT NOT NULL PRIMARY KEY,
            owner_user_id TEXT,
            entity_type TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            operation TEXT NOT NULL,
            payload_json TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending',
            attempts INTEGER NOT NULL DEFAULT 0,
            last_error TEXT,
            next_attempt_at INTEGER,
            created_at INTEGER NOT NULL
          );
        ''');

        raw.execute('PRAGMA user_version = 14;');
        expect(raw.select('PRAGMA user_version').single.values.single, 14);

        raw.execute('''
          INSERT INTO cart_item_records
          (product_id, product_name, price, cart_quantity,
           sort_order, updated_at)
          VALUES ('product-old', 'Legacy product', 1500, 3,
                  0, 1790000000);
        ''');

        raw.execute('''
          INSERT INTO order_records
          (id, notes, created_at, updated_at)
          VALUES ('order-old', 'Preserve order',
                  1790000000, 1790000000);
        ''');

        raw.execute('''
          INSERT INTO order_item_records
          (id, order_id, product_id, supplier_id,
           product_name, unit_price, quantity)
          VALUES ('item-old', 'order-old', 'product-old',
                  'supplier-old', 'Legacy product', 1500, 3);
        ''');

        raw.execute('''
          INSERT INTO sync_operations
          (id, entity_type, entity_id, operation,
           payload_json, created_at)
          VALUES ('sync-old', 'order', 'order-old',
                  'create', '{"preserve":true}', 1790000000);
        ''');
      } finally {
        raw.close();
      }

      final upgraded = AppDatabase.forTesting(NativeDatabase(file));

      try {
        await upgraded.customSelect('SELECT 1').get();

        expect(upgraded.schemaVersion, 16);

        final carts = await upgraded
            .customSelect('SELECT id, owner_user_id FROM cart_records')
            .get();

        final items = await upgraded
            .customSelect(
              'SELECT id, cart_id, kind, product_id, '
              'product_name, cart_quantity FROM cart_item_records',
            )
            .get();

        expect(carts, hasLength(1));
        expect(carts.single.data['owner_user_id'], isNull);

        expect(items, hasLength(1));
        expect(items.single.data['cart_id'], carts.single.data['id']);
        expect(items.single.data['kind'], 'catalog');
        expect(items.single.data['product_id'], 'product-old');
        expect(items.single.data['cart_quantity'], 3);

        final orders = await upgraded
            .customSelect('SELECT id, notes FROM order_records')
            .get();

        final orderItems = await upgraded
            .customSelect('SELECT id, order_id FROM order_item_records')
            .get();

        final outbox = await upgraded
            .customSelect('SELECT id, payload_json FROM sync_operations')
            .get();

        expect(orders.single.data['id'], 'order-old');
        expect(orders.single.data['notes'], 'Preserve order');
        expect(orderItems.single.data['order_id'], 'order-old');
        expect(outbox.single.data['id'], 'sync-old');
        expect(outbox.single.data['payload_json'], '{"preserve":true}');
      } finally {
        await upgraded.close();
      }
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
