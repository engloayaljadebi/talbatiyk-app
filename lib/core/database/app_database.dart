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

  /// Primary supplier location governorate returned by Laravel.
  TextColumn get supplierGovernorate => text().nullable()();

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

  TextColumn get aggregateStatus =>
      text().withDefault(const Constant('pending_responses'))();

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

/// Durable identity for one logical online Product publication.
///
/// This is intentionally separate from SyncOperations:
/// Product Publishing is online-first and must never create a parallel
/// product:create Outbox mutation.
abstract final class ProductPublishAttemptStatuses {
  static const String pending = 'pending';
  static const String retrying = 'retrying';
  static const String permanentFailure = 'permanent_failure';
}

class ProductPublishAttemptRecords extends Table {
  TextColumn get idempotencyKey => text()();

  /// Temporary client-side identity of the logical publication.
  TextColumn get clientProductId => text()();

  TextColumn get supplierId => text()();
  TextColumn get supplierName => text()();

  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get brand => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();

  RealColumn get price => real()();
  IntColumn get quantity => integer()();
  BoolColumn get isAvailable => boolean()();

  /// Persisted local image path is needed so a retry after process restart
  /// sends the same image content again.
  TextColumn get localImagePath => text().nullable()();

  TextColumn get status => text().withDefault(
    const Constant(ProductPublishAttemptStatuses.pending),
  )();

  IntColumn get attempts => integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();

  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  TextColumn get serverProductId => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {idempotencyKey};

  @override
  List<Set<Column>> get uniqueKeys => [
    {clientProductId},
  ];
}

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

/// Server-owned notification snapshot isolated by authenticated user.
class NotificationRecords extends Table {
  TextColumn get userId => text()();

  TextColumn get id => text()();

  TextColumn get type => text()();

  TextColumn get title => text()();

  TextColumn get body => text()();

  TextColumn get dataJson => text().withDefault(const Constant('{}'))();

  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  DateTimeColumn get readAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {userId, id};
}

@DriftDatabase(
  tables: [
    ProductRecords,
    ProductPublishAttemptRecords,
    ProductDiscoveryRecords,
    OrderRecords,
    OrderItemRecords,
    CartItemRecords,
    NotificationRecords,
    SyncOperations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'talbatiyk'));

  /// Test-only constructor that accepts an in-memory database executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createSupplierDiscoveryCache();
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
        if (from < 6) {
          await m.addColumn(orderRecords, orderRecords.aggregateStatus);
        }
        if (from < 7) {
          await m.createTable(notificationRecords);
        } else if (from < 8) {
          // Repair historical v7 databases that already report schema
          // version 7 but are missing NotificationRecords.
          final existingNotificationTables = await customSelect(
            "SELECT 1 FROM sqlite_master "
            "WHERE type = 'table' "
            "AND name = 'notification_records' "
            "LIMIT 1;",
          ).get();

          if (existingNotificationTables.isEmpty) {
            await m.createTable(notificationRecords);
          }
        }
        if (from < 9) {
          await _createSupplierDiscoveryCache();
        }

        /*
         * Historical v10:
         * persist the supplier governorate in the customer Product Discovery
         * snapshot without rebuilding or replacing that snapshot.
         */
        if (from < 10) {
          await _ensureProductDiscoveryGovernorateColumn(m);
        }

        /*
         * Historical v11:
         * durable online Product publication attempts.
         *
         * Governorate repair is deliberately repeated here so a development
         * database that temporarily reported v10 with the publish-attempt
         * table but without supplier_governorate is repaired forward-only.
         */
        if (from < 11) {
          await _ensureProductDiscoveryGovernorateColumn(m);
          await _ensureProductPublishAttemptTable(m);
        }
      },
    );
  }

  Future<void> _ensureProductDiscoveryGovernorateColumn(Migrator m) async {
    /*
     * Historical databases and test fixtures may legitimately lack the
     * Product Discovery table.
     *
     * In that case create the current table forward-only instead of issuing
     * ALTER TABLE against a non-existent table.
     */
    final existingTables = await customSelect(
      "SELECT 1 FROM sqlite_master "
      "WHERE type = 'table' "
      "AND name = 'product_discovery_records' "
      "LIMIT 1;",
    ).get();

    if (existingTables.isEmpty) {
      await m.createTable(productDiscoveryRecords);

      return;
    }

    /*
     * Existing Product Discovery data must be preserved.
     * Only add the v10 governorate column when it is missing.
     */
    final columns = await customSelect(
      "PRAGMA table_info('product_discovery_records')",
    ).get();

    final hasGovernorate = columns.any(
      (row) => row.data['name'] == 'supplier_governorate',
    );

    if (!hasGovernorate) {
      await m.addColumn(
        productDiscoveryRecords,
        productDiscoveryRecords.supplierGovernorate,
      );
    }
  }

  Future<void> _ensureProductPublishAttemptTable(Migrator m) async {
    final existingTables = await customSelect(
      "SELECT 1 FROM sqlite_master "
      "WHERE type = 'table' "
      "AND name = 'product_publish_attempt_records' "
      "LIMIT 1;",
    ).get();

    if (existingTables.isEmpty) {
      await m.createTable(productPublishAttemptRecords);
    }
  }

  /// A server snapshot scoped to the user; the generated Drift schema stays
  /// unchanged because this table is accessed through parameterized SQL.
  Future<void> _createSupplierDiscoveryCache() => customStatement('''
    CREATE TABLE IF NOT EXISTS supplier_discovery_cache (
      user_id TEXT NOT NULL,
      supplier_id TEXT NOT NULL,
      name TEXT NOT NULL,
      PRIMARY KEY (user_id, supplier_id)
    )
  ''');
}
