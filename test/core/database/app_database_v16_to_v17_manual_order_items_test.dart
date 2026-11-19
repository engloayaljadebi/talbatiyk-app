import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';

void main() {
  test('v16 to v17 keeps order items and allows manual order items', () async {
    final directory = await Directory.systemTemp.createTemp(
      'talbatiyk-v16-v17-',
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
        DateTime.utc(2026, 11, 19, 12).millisecondsSinceEpoch ~/ 1000;

    // Build a v16-equivalent fixture from the current schema: restore the
    // old order_item_records shape (required product/supplier) and set
    // user_version to 16 before reopening.
    final original = AppDatabase.forTesting(NativeDatabase(file));

    try {
      await original.customStatement('DROP TABLE order_item_records;');

      await original.customStatement(
        'CREATE TABLE order_item_records ('
        'id TEXT NOT NULL PRIMARY KEY, '
        'order_id TEXT NOT NULL REFERENCES order_records (id) '
        'ON DELETE CASCADE, '
        'product_id TEXT NOT NULL, '
        'supplier_id TEXT NOT NULL, '
        "supplier_name TEXT NOT NULL DEFAULT '', "
        'product_name TEXT NOT NULL, '
        'unit_price REAL NOT NULL, '
        'quantity INTEGER NOT NULL, '
        "image_url TEXT NOT NULL DEFAULT ''"
        ');',
      );

      await original.customStatement(
        'INSERT INTO order_records '
        '(id, owner_user_id, status, notes, created_at, updated_at) '
        "VALUES ('order-before-v17', 'account-A', 'pending', "
        "'preserve-order', $timestamp, $timestamp);",
      );

      await original.customStatement(
        'INSERT INTO order_item_records '
        '(id, order_id, product_id, supplier_id, supplier_name, '
        'product_name, unit_price, quantity, image_url) '
        "VALUES ('item-old', 'order-before-v17', 'product-1', 'supplier-1', "
        "'Supplier One', 'Old Product', 125.5, 3, 'image.png');",
      );

      await original.customStatement('PRAGMA user_version = 16;');
    } finally {
      await original.close();
    }

    final upgraded = AppDatabase.forTesting(NativeDatabase(file));

    try {
      expect(upgraded.schemaVersion, 17);

      final oldRows = await upgraded
          .customSelect(
            "SELECT * FROM order_item_records WHERE id = 'item-old';",
          )
          .get();

      expect(oldRows, hasLength(1));

      final old = oldRows.single.data;

      expect(old['order_id'], 'order-before-v17');
      expect(old['product_id'], 'product-1');
      expect(old['supplier_id'], 'supplier-1');
      expect(old['supplier_name'], 'Supplier One');
      expect(old['product_name'], 'Old Product');
      expect(old['unit_price'], 125.5);
      expect(old['quantity'], 3);
      expect(old['image_url'], 'image.png');
      expect(old['item_type'], 'catalog');
      expect(old['unit'], isNull);
      expect(old['note'], isNull);

      // A manual item has no catalog product and no supplier.
      await upgraded.customStatement(
        'INSERT INTO order_item_records '
        '(id, order_id, product_id, supplier_id, supplier_name, '
        'product_name, unit_price, quantity, image_url, '
        'item_type, unit, note) '
        "VALUES ('item-manual', 'order-before-v17', NULL, NULL, '', "
        "'Typed item', 50.0, 4, '', 'manual', 'box', 'Any brand');",
      );

      final manualRows = await upgraded
          .customSelect(
            "SELECT * FROM order_item_records WHERE id = 'item-manual';",
          )
          .get();

      expect(manualRows, hasLength(1));

      final manual = manualRows.single.data;

      expect(manual['product_id'], isNull);
      expect(manual['supplier_id'], isNull);
      expect(manual['item_type'], 'manual');
      expect(manual['unit'], 'box');
      expect(manual['note'], 'Any brand');
      expect(manual['unit_price'], 50.0);
      expect(manual['quantity'], 4);

      final orders = await upgraded
          .customSelect(
            "SELECT notes FROM order_records WHERE id = 'order-before-v17';",
          )
          .get();

      expect(orders.single.data['notes'], 'preserve-order');

      final foreignKeyProblems = await upgraded
          .customSelect('PRAGMA foreign_key_check;')
          .get();

      expect(foreignKeyProblems, isEmpty);

      final version = await upgraded
          .customSelect('PRAGMA user_version;')
          .getSingle();

      expect(version.read<int>('user_version'), 17);
    } finally {
      await upgraded.close();
    }
  });
}
