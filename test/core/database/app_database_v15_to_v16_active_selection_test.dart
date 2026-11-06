import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:talbatiyk/core/database/app_database.dart';

void main() {
  test('v15 to v16 preserves data and adds active cart selection', () async {
    final directory = await Directory.systemTemp.createTemp(
      'talbatiyk-v15-v16-',
    );

    final file = File(
      '${directory.path}${Platform.pathSeparator}migration.sqlite',
    );

    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final timestamp =
        DateTime.utc(2026, 11, 4, 12).millisecondsSinceEpoch ~/ 1000;

    // Prepare a v15-equivalent fixture from the current schema.
    // The only v16 addition is removed before setting user_version=15.
    final original = AppDatabase.forTesting(NativeDatabase(file));

    try {
      for (final cart in [
        ('cart-a', 'account-A', 'طلبية المحل'),
        ('cart-b', 'account-B', 'عميل خاص'),
      ]) {
        await original.customStatement(
          'INSERT INTO cart_records '
          '(id, owner_user_id, name, created_at, updated_at) '
          'VALUES (?, ?, ?, ?, ?);',
          [cart.$1, cart.$2, cart.$3, timestamp, timestamp],
        );
      }

      await original.customStatement(
        'INSERT INTO cart_item_records '
        '(id, cart_id, kind, product_id, product_name, '
        'price, cart_quantity, sort_order, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);',
        [
          'item-catalog',
          'cart-a',
          'catalog',
          'product-1',
          'Catalog Product',
          4500.0,
          3,
          0,
          timestamp,
        ],
      );

      await original.customStatement(
        'INSERT INTO cart_item_records '
        '(id, cart_id, kind, product_id, product_name, '
        'price, cart_quantity, sort_order, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);',
        [
          'item-manual',
          'cart-b',
          'manual',
          null,
          'Manual Product',
          2500.0,
          2,
          0,
          timestamp,
        ],
      );

      await original.customStatement(
        'INSERT INTO order_records '
        '(id, owner_user_id, status, notes, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?);',
        [
          'order-before-v16',
          'account-A',
          'pending',
          'preserve-order',
          timestamp,
          timestamp,
        ],
      );

      await original.customStatement(
        'INSERT INTO sync_operations '
        '(id, owner_user_id, entity_type, entity_id, '
        'operation, payload_json, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?);',
        [
          'sync-before-v16',
          'account-A',
          'order',
          'order-before-v16',
          'create',
          '{"preserve":true}',
          timestamp,
        ],
      );
    } finally {
      await original.close();
    }

    final raw = sqlite.sqlite3.open(file.path);

    try {
      expect(raw.select('PRAGMA user_version;').single.values.single, 16);

      final selectionTable = raw.select(
        "SELECT name FROM sqlite_master "
        "WHERE type = 'table' "
        "AND name = 'cart_active_selection_records';",
      );

      expect(selectionTable, hasLength(1));

      // Reconstruct the previous v15 schema boundary.
      raw.execute('DROP TABLE cart_active_selection_records;');
      raw.execute('PRAGMA user_version = 15;');

      expect(raw.select('PRAGMA user_version;').single.values.single, 15);

      expect(
        raw.select(
          "SELECT name FROM sqlite_master "
          "WHERE name = 'cart_active_selection_records';",
        ),
        isEmpty,
      );
    } finally {
      raw.close();
    }

    final upgraded = AppDatabase.forTesting(NativeDatabase(file));

    try {
      // Reading the new table triggers the actual v15 -> v16 upgrade.
      final selections = await upgraded
          .select(upgraded.cartActiveSelectionRecords)
          .get();

      expect(upgraded.schemaVersion, 16);
      expect(selections, isEmpty);

      final version = await upgraded
          .customSelect('PRAGMA user_version;')
          .getSingle();

      expect(version.read<int>('user_version'), 16);

      final carts = await upgraded
          .customSelect(
            'SELECT id, owner_user_id, name '
            'FROM cart_records ORDER BY id;',
          )
          .get();

      expect(carts, hasLength(2));
      expect(carts[0].read<String>('id'), 'cart-a');
      expect(carts[0].read<String>('owner_user_id'), 'account-A');
      expect(carts[0].read<String>('name'), 'طلبية المحل');
      expect(carts[1].read<String>('id'), 'cart-b');
      expect(carts[1].read<String>('owner_user_id'), 'account-B');

      final items = await upgraded
          .customSelect(
            'SELECT id, cart_id, kind, product_id, '
            'product_name, cart_quantity '
            'FROM cart_item_records ORDER BY id;',
          )
          .get();

      expect(items, hasLength(2));
      expect(items[0].read<String>('id'), 'item-catalog');
      expect(items[0].read<String>('cart_id'), 'cart-a');
      expect(items[0].read<String>('kind'), 'catalog');
      expect(items[0].read<String>('product_id'), 'product-1');
      expect(items[0].read<int>('cart_quantity'), 3);

      expect(items[1].read<String>('id'), 'item-manual');
      expect(items[1].read<String>('cart_id'), 'cart-b');
      expect(items[1].read<String>('kind'), 'manual');
      expect(items[1].data['product_id'], isNull);
      expect(items[1].read<String>('product_name'), 'Manual Product');
      expect(items[1].read<int>('cart_quantity'), 2);

      final orders = await upgraded
          .customSelect(
            'SELECT id, owner_user_id, notes FROM order_records '
            "WHERE id = 'order-before-v16';",
          )
          .get();

      expect(orders, hasLength(1));
      expect(orders.single.read<String>('owner_user_id'), 'account-A');
      expect(orders.single.read<String>('notes'), 'preserve-order');

      final operations = await upgraded
          .customSelect(
            'SELECT id, owner_user_id, payload_json FROM sync_operations '
            "WHERE id = 'sync-before-v16';",
          )
          .get();

      expect(operations, hasLength(1));
      expect(operations.single.read<String>('owner_user_id'), 'account-A');
      expect(
        operations.single.read<String>('payload_json'),
        '{"preserve":true}',
      );

      await upgraded.customStatement(
        'INSERT INTO cart_active_selection_records '
        '(owner_user_id, cart_id, updated_at) '
        'VALUES (?, ?, ?);',
        ['account-A', 'cart-a', timestamp],
      );

      await upgraded.customStatement(
        'INSERT INTO cart_active_selection_records '
        '(owner_user_id, cart_id, updated_at) '
        'VALUES (?, ?, ?);',
        ['account-B', 'cart-b', timestamp],
      );

      final foreignKeyErrors = await upgraded
          .customSelect('PRAGMA foreign_key_check;')
          .get();

      expect(foreignKeyErrors, isEmpty);
    } finally {
      await upgraded.close();
    }

    // Reopening must retain the newly saved active-cart choices.
    final reopened = AppDatabase.forTesting(NativeDatabase(file));

    try {
      final selections = await reopened
          .customSelect(
            'SELECT owner_user_id, cart_id '
            'FROM cart_active_selection_records '
            'ORDER BY owner_user_id;',
          )
          .get();

      expect(selections, hasLength(2));
      expect(selections[0].read<String>('owner_user_id'), 'account-A');
      expect(selections[0].read<String>('cart_id'), 'cart-a');
      expect(selections[1].read<String>('owner_user_id'), 'account-B');
      expect(selections[1].read<String>('cart_id'), 'cart-b');

      final integrity = await reopened
          .customSelect('PRAGMA integrity_check;')
          .getSingle();

      expect(integrity.read<String>('integrity_check'), 'ok');
    } finally {
      await reopened.close();
    }
  });
}
