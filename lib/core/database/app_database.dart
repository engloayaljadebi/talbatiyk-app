import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class ProductRecords extends Table {
  TextColumn get id => text()();

  TextColumn get supplierId => text()();

  TextColumn get supplierName => text()();

  TextColumn get name => text()();

  TextColumn get category => text().withDefault(const Constant(''))();

  TextColumn get brand => text().withDefault(const Constant(''))();

  TextColumn get description => text().withDefault(const Constant(''))();

  RealColumn get price => real()();

  IntColumn get quantity => integer().withDefault(const Constant(0))();

  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();

  RealColumn get discount => real().withDefault(const Constant(0))();

  RealColumn get rating => real().withDefault(const Constant(0))();

  TextColumn get colorsJson => text().withDefault(const Constant('[]'))();

  TextColumn get localImagePath => text().nullable()();

  TextColumn get remoteImageUrl => text().nullable()();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendingCreate'))();

  TextColumn get syncError => text().nullable()();

  IntColumn get syncAttempts => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncOperations extends Table {
  TextColumn get id => text()();

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  TextColumn get operation => text()();

  TextColumn get payloadJson => text()();

  IntColumn get attempts => integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();

  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [ProductRecords, SyncOperations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'talbatiyk'));

  /// مُنشئ مخصص للاختبارات يسمح باستخدام قاعدة بيانات مؤقتة.
  AppDatabase.forTesting(super.e);
  @override
  int get schemaVersion => 1;
}
