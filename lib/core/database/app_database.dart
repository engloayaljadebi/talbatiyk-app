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

/// Server-owned snapshot used only by customer Product Discovery.
///
/// This table is deliberately separate from ProductRecords because supplier
/// product management has independent pending/outbox semantics.
class ProductDiscoveryRecords extends Table {
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

  TextColumn get remoteImageUrl => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class OrderRecords extends Table {
  TextColumn get id => text()();

  TextColumn get status => text().withDefault(const Constant('pending'))();

  TextColumn get notes => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class OrderItemRecords extends Table {
  TextColumn get id => text()();

  TextColumn get orderId =>
      text().references(OrderRecords, #id, onDelete: KeyAction.cascade)();

  TextColumn get productId => text()();

  TextColumn get supplierId => text()();

  TextColumn get supplierName => text().withDefault(const Constant(''))();

  TextColumn get productName => text()();

  RealColumn get unitPrice => real()();

  IntColumn get quantity => integer()();

  TextColumn get imageUrl => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CartItemRecords extends Table {
  TextColumn get productId => text()();

  TextColumn get supplierId => text().withDefault(const Constant(''))();

  TextColumn get supplierName => text().withDefault(const Constant(''))();

  TextColumn get productName => text()();

  RealColumn get price => real()();

  TextColumn get imageUrl => text().withDefault(const Constant(''))();

  TextColumn get localImagePath => text().nullable()();

  TextColumn get category => text().withDefault(const Constant(''))();

  TextColumn get brand => text().withDefault(const Constant(''))();

  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();

  TextColumn get description => text().withDefault(const Constant(''))();

  TextColumn get colorsJson => text().withDefault(const Constant('[]'))();

  IntColumn get productQuantity => integer().withDefault(const Constant(0))();

  RealColumn get discount => real().withDefault(const Constant(0))();

  RealColumn get rating => real().withDefault(const Constant(0))();

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  TextColumn get syncError => text().nullable()();

  DateTimeColumn get productCreatedAt => dateTime().nullable()();

  DateTimeColumn get productUpdatedAt => dateTime().nullable()();

  IntColumn get cartQuantity => integer()();

  IntColumn get sortOrder => integer()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {productId};
}

/// الحالات الأساسية لدورة حياة عملية الـOutbox.
///
/// هذه القيم تخص المزامنة فقط ولا تمثل الحالة التجارية للـOrder.
abstract final class SyncOperationStatuses {
  static const String pending = 'pending';
  static const String retrying = 'retrying';
  static const String permanentFailure = 'permanent_failure';
}

class SyncOperations extends Table {
  TextColumn get id => text()();

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  TextColumn get operation => text()();

  TextColumn get payloadJson => text()();

  /// يحدد هل العملية تنتظر أول محاولة، تحتاج Retry، أو توقفت نهائيًا.
  ///
  /// permanentFailure لا يعني حذف البيانات؛ بل يمنع إعادة المحاولة التلقائية
  /// مع الاحتفاظ بالـpayload والخطأ للتحليل أو المعالجة اليدوية لاحقًا.
  TextColumn get status =>
      text().withDefault(const Constant(SyncOperationStatuses.pending))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();

  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    ProductRecords,
    ProductDiscoveryRecords,
    OrderRecords,
    OrderItemRecords,
    CartItemRecords,
    SyncOperations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'talbatiyk'));

  /// Test-only constructor that accepts an in-memory database executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(orderRecords);
          await m.createTable(orderItemRecords);
        }

        if (from < 3) {
          await m.createTable(productDiscoveryRecords);
        }

        if (from < 4) {
          await m.createTable(cartItemRecords);
        }
        if (from < 5) {
          // كل عمليات Outbox القديمة تعتبر pending افتراضيًا.
          // الإضافة Forward-Only وتحافظ على البيانات الموجودة بدون إعادة إنشاء الجدول.
          await m.addColumn(syncOperations, syncOperations.status);
        }
      },
    );
  }
}
