import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:talbatiyk/core/database/app_database.dart';

void main() {
  group('AppDatabase v7 repair migration', () {
    test('repairs v7 missing notification_records without data loss', () async {
      final Directory directory = await Directory.systemTemp.createTemp(
        'talbatiyk-v7-repair-',
      );

      addTearDown(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });

      final File file = File(
        '${directory.path}${Platform.pathSeparator}repair.sqlite',
      );

      await _createBrokenV7Fixture(file);

      expect(_readUserVersion(file), 7);
      expect(_tableExists(file, 'notification_records'), isFalse);

      final AppDatabase database = AppDatabase.forTesting(NativeDatabase(file));

      try {
        final notifications = await database
            .select(database.notificationRecords)
            .get();

        final operations = await database.select(database.syncOperations).get();

        expect(database.schemaVersion, 11);
        expect(notifications, isEmpty);

        expect(operations, hasLength(1));
        expect(operations.single.id, 'runtime-repair-sentinel');
        expect(operations.single.entityId, 'preserved-order');
        expect(operations.single.payloadJson, '{"preserve":true}');
      } finally {
        await database.close();
      }

      expect(_readUserVersion(file), 11);
      expect(_tableExists(file, 'notification_records'), isTrue);
    });

    test('upgrades healthy v7 without losing existing notifications', () async {
      final Directory directory = await Directory.systemTemp.createTemp(
        'talbatiyk-v7-healthy-',
      );

      addTearDown(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });

      final File file = File(
        '${directory.path}${Platform.pathSeparator}healthy.sqlite',
      );

      await _createHealthyV7Fixture(file);

      expect(_readUserVersion(file), 7);
      expect(_tableExists(file, 'notification_records'), isTrue);

      final AppDatabase database = AppDatabase.forTesting(NativeDatabase(file));

      try {
        final notifications = await database
            .select(database.notificationRecords)
            .get();

        expect(database.schemaVersion, 11);
        expect(notifications, hasLength(1));
        expect(notifications.single.userId, 'existing-user');
        expect(notifications.single.id, 'existing-notification');
      } finally {
        await database.close();
      }

      expect(_readUserVersion(file), 11);
      expect(_tableExists(file, 'notification_records'), isTrue);
    });
  });
}

Future<void> _createBrokenV7Fixture(File file) async {
  await _bootstrapCurrentDatabase(file);

  final sqlite.Database raw = sqlite.sqlite3.open(file.path);

  try {
    raw.execute('DROP TABLE notification_records;');
    raw.execute('PRAGMA user_version = 7;');

    if (_userVersion(raw) != 7) {
      throw StateError('Broken fixture must be user_version 7.');
    }

    if (_tableExistsInDatabase(raw, 'notification_records')) {
      throw StateError('Broken fixture must not contain notification_records.');
    }
  } finally {
    raw.close();
  }
}

Future<void> _createHealthyV7Fixture(File file) async {
  await _bootstrapCurrentDatabase(file, insertNotification: true);

  final sqlite.Database raw = sqlite.sqlite3.open(file.path);

  try {
    raw.execute('PRAGMA user_version = 7;');

    if (_userVersion(raw) != 7) {
      throw StateError('Healthy fixture must be user_version 7.');
    }

    if (!_tableExistsInDatabase(raw, 'notification_records')) {
      throw StateError('Healthy fixture must contain notification_records.');
    }
  } finally {
    raw.close();
  }
}

Future<void> _bootstrapCurrentDatabase(
  File file, {
  bool insertNotification = false,
}) async {
  final AppDatabase database = AppDatabase.forTesting(NativeDatabase(file));

  try {
    await database.select(database.syncOperations).get();

    await database
        .into(database.syncOperations)
        .insert(
          SyncOperationsCompanion.insert(
            id: 'runtime-repair-sentinel',
            entityType: 'order',
            entityId: 'preserved-order',
            operation: 'create',
            payloadJson: '{"preserve":true}',
            createdAt: DateTime.utc(2026, 9, 22),
          ),
        );

    if (insertNotification) {
      await database
          .into(database.notificationRecords)
          .insert(
            NotificationRecordsCompanion.insert(
              userId: 'existing-user',
              id: 'existing-notification',
              type: 'fixture',
              title: 'Existing',
              body: 'Preserve me',
              createdAt: DateTime.utc(2026, 9, 22),
              updatedAt: DateTime.utc(2026, 9, 22),
            ),
          );
    }
  } finally {
    await database.close();
  }
}

int _readUserVersion(File file) {
  final sqlite.Database database = sqlite.sqlite3.open(file.path);

  try {
    return _userVersion(database);
  } finally {
    database.close();
  }
}

int _userVersion(sqlite.Database database) {
  final rows = database.select('PRAGMA user_version;');

  if (rows.length != 1) {
    throw StateError('Expected exactly one user_version row.');
  }

  final Object? value = rows.single['user_version'];

  if (value is! int) {
    throw StateError('Expected integer user_version.');
  }

  return value;
}

bool _tableExists(File file, String tableName) {
  final sqlite.Database database = sqlite.sqlite3.open(file.path);

  try {
    return _tableExistsInDatabase(database, tableName);
  } finally {
    database.close();
  }
}

bool _tableExistsInDatabase(sqlite.Database database, String tableName) {
  final rows = database.select(
    "SELECT name FROM sqlite_master "
    "WHERE type = 'table' AND name = ?;",
    <Object?>[tableName],
  );

  return rows.isNotEmpty;
}
