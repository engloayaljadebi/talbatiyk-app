import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class ProductRecords extends Table {
  TextColumn get id => text()();

  /// NULL identifies historical records with unknown ownership.
  TextColumn get ownerUserId => text().nullable()();

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

  /// Last optimistic-concurrency version confirmed by Laravel.
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendingCreate'))();

  TextColumn get syncError => text().nullable()();

  IntColumn get syncAttempts => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Server product IDs may be cached separately for different accounts.
  /// Historical NULL-owner records are preserved but remain unclaimed.
  @override
  List<Set<Column>> get uniqueKeys => [
    {ownerUserId, id},
  ];
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

  /// Null is reserved for legacy records with unknown ownership.
  TextColumn get ownerUserId => text().nullable()();

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

/// A locally stored named cart.
///
/// NULL ownership is reserved for legacy carts whose owner
/// cannot be established safely during migration.
class CartRecords extends Table {
  TextColumn get id => text()();

  TextColumn get ownerUserId => text().nullable()();

  TextColumn get name => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One locally selected cart per authenticated account.
class CartActiveSelectionRecords extends Table {
  TextColumn get ownerUserId => text()();

  TextColumn get cartId =>
      text().references(CartRecords, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {ownerUserId};
}

class CartItemRecords extends Table {
  TextColumn get id => text()();

  TextColumn get cartId =>
      text().references(CartRecords, #id, onDelete: KeyAction.cascade)();

  TextColumn get kind => text().withDefault(const Constant('catalog'))();

  TextColumn get productId => text().nullable()();

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

  TextColumn get unit => text().nullable()();

  TextColumn get note => text().nullable()();

  @override
  List<String> get customConstraints => [
    "CHECK (kind IN ('catalog', 'manual'))",
  ];

  @override
  Set<Column<Object>> get primaryKey => {id};
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

  /// NULL identifies historical attempts with unknown ownership.
  TextColumn get ownerUserId => text().nullable()();

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
    {ownerUserId, clientProductId},
  ];
}

abstract final class SyncOperationStatuses {
  static const String pending = 'pending';
  static const String retrying = 'retrying';
  static const String permanentFailure = 'permanent_failure';
}

class SyncOperations extends Table {
  TextColumn get id => text()();

  /// Null is reserved for legacy records with unknown ownership.
  TextColumn get ownerUserId => text().nullable()();

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
    CartRecords,
    CartActiveSelectionRecords,
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
  int get schemaVersion => 16;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createSupplierDiscoveryCache();

        await customStatement('''
          CREATE UNIQUE INDEX cart_catalog_product_unique
          ON cart_item_records(cart_id, product_id)
          WHERE kind = 'catalog' AND product_id IS NOT NULL;
        ''');

        await customStatement('''
          CREATE INDEX cart_items_sort_index
          ON cart_item_records(cart_id, sort_order);
        ''');
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

        if (from < 12) {
          await _ensureProductServerVersionColumn(m);
        }

        if (from < 13) {
          // Preserve legacy records without assigning an owner.
          await m.addColumn(orderRecords, orderRecords.ownerUserId);
          await m.addColumn(syncOperations, syncOperations.ownerUserId);
        }

        if (from < 14) {
          // Rebuild both tables to update identity constraints.
          // Historical rows retain NULL ownership.
          await m.alterTable(
            TableMigration(
              productRecords,
              newColumns: [productRecords.ownerUserId],
            ),
          );

          await m.alterTable(
            TableMigration(
              productPublishAttemptRecords,
              newColumns: [productPublishAttemptRecords.ownerUserId],
            ),
          );
        }

        if (from < 15 && to >= 15) {
          await _migrateCartTablesToV15(m);
        }
        if (from < 16 && to >= 16) {
          await _ensureCartActiveSelectionTable(m);
        }
      },
    );
  }

  /// Converts the legacy single cart into the v15 multi-cart schema.
  /// Existing orders and sync operations are not modified.
  /// Creates the active-cart selection table when upgrading to v16.
  /// Handles historical test fixtures that already have this table.
  Future<void> _ensureCartActiveSelectionTable(Migrator m) async {
    final existing = await customSelect(
      "SELECT 1 FROM sqlite_master "
      "WHERE type = 'table' "
      "AND name = 'cart_active_selection_records' "
      "LIMIT 1;",
    ).get();

    if (existing.isEmpty) {
      await m.createTable(cartActiveSelectionRecords);
    }
  }

  Future<void> _migrateCartTablesToV15(Migrator m) async {
    final existingTables = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name IN ('cart_records', 'cart_item_records');",
    ).get();

    final names = existingTables.map((row) => row.read<String>('name')).toSet();

    final hasCarts = names.contains('cart_records');
    final hasItems = names.contains('cart_item_records');

    if (hasItems) {
      final columns = await customSelect(
        "PRAGMA table_info('cart_item_records');",
      ).get();

      final columnNames = columns
          .map((row) => row.read<String>('name'))
          .toSet();

      final isV15 = columnNames.containsAll({
        'id',
        'cart_id',
        'kind',
        'product_id',
        'unit',
        'note',
      });

      if (isV15) {
        if (!hasCarts) {
          final count = await customSelect(
            'SELECT COUNT(*) AS item_count FROM cart_item_records;',
          ).getSingle();

          if (count.read<int>('item_count') != 0) {
            throw StateError(
              'V15 cart items exist without their parent cart table.',
            );
          }

          await m.createTable(cartRecords);
        }

        await _ensureV15CartIndexes();
        return;
      }

      if (!columnNames.contains('product_id') ||
          columnNames.contains('cart_id')) {
        throw StateError('Unsupported historical cart schema.');
      }
    } else {
      if (!hasCarts) {
        await m.createTable(cartRecords);
      }

      await m.createTable(cartItemRecords);
      await _ensureV15CartIndexes();
      return;
    }

    if (hasCarts) {
      throw StateError('Unexpected cart_records table with legacy cart items.');
    }
    await customStatement('''
      CREATE TABLE cart_records (
        id TEXT NOT NULL PRIMARY KEY,
        owner_user_id TEXT,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    // Unknown legacy ownership must remain unclaimed.
    // Create the historical cart only when legacy items exist.
    await customStatement('''
      INSERT INTO cart_records (
        id, owner_user_id, name, created_at, updated_at
      )
      SELECT
        'legacy-v14-unclaimed',
        NULL,
        'السلة السابقة',
        MIN(updated_at),
        MAX(updated_at)
      FROM cart_item_records
      HAVING COUNT(*) > 0;
    ''');

    await customStatement('''
      CREATE TABLE cart_item_records_v15 (
        id TEXT NOT NULL PRIMARY KEY,
        cart_id TEXT NOT NULL REFERENCES cart_records(id)
          ON DELETE CASCADE,
        kind TEXT NOT NULL DEFAULT 'catalog',
        product_id TEXT,
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
        updated_at INTEGER NOT NULL,
        unit TEXT,
        note TEXT,
        CHECK (kind IN ('catalog', 'manual'))
      );
    ''');

    // Preserve every existing column and its stored value.
    await customStatement('''
      INSERT INTO cart_item_records_v15 (
        id, cart_id, kind, product_id,
        supplier_id, supplier_name, product_name,
        price, image_url, local_image_path,
        category, brand, is_available, description,
        colors_json, product_quantity, discount,
        rating, sync_status, sync_error,
        product_created_at, product_updated_at,
        cart_quantity, sort_order, updated_at
      )
      SELECT
        'legacy-catalog:' || product_id,
        'legacy-v14-unclaimed',
        'catalog',
        product_id,
        supplier_id, supplier_name, product_name,
        price, image_url, local_image_path,
        category, brand, is_available, description,
        colors_json, product_quantity, discount,
        rating, sync_status, sync_error,
        product_created_at, product_updated_at,
        cart_quantity, sort_order, updated_at
      FROM cart_item_records;
    ''');

    await customStatement('DROP TABLE cart_item_records;');

    await customStatement('''
      ALTER TABLE cart_item_records_v15
      RENAME TO cart_item_records;
    ''');

    await customStatement('''
      CREATE UNIQUE INDEX cart_catalog_product_unique
      ON cart_item_records(cart_id, product_id)
      WHERE kind = 'catalog' AND product_id IS NOT NULL;
    ''');

    await customStatement('''
      CREATE INDEX cart_items_sort_index
      ON cart_item_records(cart_id, sort_order);
    ''');
  }

  Future<void> _ensureV15CartIndexes() async {
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS cart_catalog_product_unique
      ON cart_item_records(cart_id, product_id)
      WHERE kind = 'catalog' AND product_id IS NOT NULL;
    ''');

    await customStatement('''
      CREATE INDEX IF NOT EXISTS cart_items_sort_index
      ON cart_item_records(cart_id, sort_order);
    ''');
  }

  Future<void> _ensureProductServerVersionColumn(Migrator m) async {
    /*
     * Historical databases and migration fixtures may legitimately predate
     * ProductRecords entirely. Never issue ALTER TABLE against a missing table.
     */
    final existingTables = await customSelect(
      "SELECT 1 FROM sqlite_master "
      "WHERE type = 'table' "
      "AND name = 'product_records' "
      "LIMIT 1;",
    ).get();

    if (existingTables.isEmpty) {
      await m.createTable(productRecords);

      return;
    }

    /*
     * Forward-only and restart-safe: transitional databases may already contain
     * the v12 column even while reporting an older user_version.
     */
    final columns = await customSelect(
      "PRAGMA table_info('product_records');",
    ).get();

    final hasServerVersion = columns.any(
      (row) => row.data['name'] == 'server_version',
    );

    if (!hasServerVersion) {
      await m.addColumn(productRecords, productRecords.serverVersion);
    }

    /*
     * Laravel introduced Product.version with default 1 in this rollout.
     * Only rows representing products that already exist on the server receive
     * that baseline. A local pending create has no server concurrency token.
     *
     * If the real server has already advanced beyond 1, the first mutation is
     * rejected with HTTP 409 rather than silently overwriting newer data.
     */
    await customStatement(
      "UPDATE product_records SET server_version = 1 "
      "WHERE server_version IS NULL "
      "AND sync_status IN ('synced', 'pendingUpdate', 'pendingDelete');",
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
