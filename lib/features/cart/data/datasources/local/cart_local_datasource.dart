import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../products/domain/entities/products_entity.dart';
import '../../../domain/entities/cart_item_entity.dart';

final class CartLocalDataSource {
  CartLocalDataSource(this.database, {String? ownerUserId})
    : _ownerUserId = ownerUserId?.trim();

  final AppDatabase database;
  final String? _ownerUserId;

  String? get _owner {
    final owner = _ownerUserId;
    if (owner == null || owner.isEmpty) {
      return null;
    }
    return owner;
  }

  Future<String> _findOrCreateCart(String owner) async {
    final existing =
        await (database.select(database.cartRecords)
              ..where((table) => table.ownerUserId.equals(owner))
              ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
            .get();

    if (existing.isNotEmpty) {
      return existing.first.id;
    }

    final id = const Uuid().v4();
    final now = DateTime.now().toUtc();

    await database
        .into(database.cartRecords)
        .insert(
          CartRecordsCompanion.insert(
            id: id,
            ownerUserId: Value(owner),
            name: 'طلبية المحل',
            createdAt: now,
            updatedAt: now,
          ),
        );

    return id;
  }

  /// Returns only carts belonging to the authenticated account.
  /// Does not create or activate a cart.
  Future<List<({String id, String name})>> listCarts() async {
    final owner = _owner;

    if (owner == null) {
      return const [];
    }

    final rows =
        await (database.select(database.cartRecords)
              ..where((table) => table.ownerUserId.equals(owner))
              ..orderBy([
                (table) => OrderingTerm.asc(table.createdAt),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();

    return List<({String id, String name})>.unmodifiable(
      rows.map((cart) => (id: cart.id, name: cart.name)),
    );
  }

  /// Creates a named cart for the current authenticated account.
  /// Does not modify the currently selected cart.
  Future<({String id, String name})> createCart(String name) async {
    final owner = _owner;

    if (owner == null) {
      throw StateError('Cannot create a cart without authenticated ownership.');
    }

    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Cart name is required.');
    }

    if (normalizedName.runes.length > 60) {
      throw ArgumentError.value(
        name,
        'name',
        'Cart name must not exceed 60 characters.',
      );
    }

    return database.transaction(() async {
      final existing = await (database.select(
        database.cartRecords,
      )..where((table) => table.ownerUserId.equals(owner))).get();

      final duplicate = existing.any(
        (cart) =>
            cart.name.trim().toLowerCase() == normalizedName.toLowerCase(),
      );

      if (duplicate) {
        throw StateError(
          'A cart with this name already exists for this account.',
        );
      }

      final cartId = const Uuid().v4();
      final now = DateTime.now().toUtc();

      await database
          .into(database.cartRecords)
          .insert(
            CartRecordsCompanion.insert(
              id: cartId,
              ownerUserId: Value(owner),
              name: normalizedName,
              createdAt: now,
              updatedAt: now,
            ),
          );

      return (id: cartId, name: normalizedName);
    });
  }

  /// Creates a named cart and activates it in one database transaction.
  ///
  /// The previous cart and its contents remain unchanged.
  Future<({String id, String name})> createCartAndActivate(String name) async {
    final owner = _owner;

    if (owner == null) {
      throw StateError('Cannot create a cart without authenticated ownership.');
    }

    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Cart name is required.');
    }

    if (normalizedName.runes.length > 60) {
      throw ArgumentError.value(
        name,
        'name',
        'Cart name must not exceed 60 characters.',
      );
    }

    return database.transaction(() async {
      final existing = await (database.select(
        database.cartRecords,
      )..where((table) => table.ownerUserId.equals(owner))).get();

      final duplicate = existing.any(
        (cart) =>
            cart.name.trim().toLowerCase() == normalizedName.toLowerCase(),
      );

      if (duplicate) {
        throw StateError(
          'A cart with this name already exists for this account.',
        );
      }

      final cartId = const Uuid().v4();
      final now = DateTime.now().toUtc();

      await database
          .into(database.cartRecords)
          .insert(
            CartRecordsCompanion.insert(
              id: cartId,
              ownerUserId: Value(owner),
              name: normalizedName,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await database
          .into(database.cartActiveSelectionRecords)
          .insertOnConflictUpdate(
            CartActiveSelectionRecordsCompanion.insert(
              ownerUserId: owner,
              cartId: cartId,
              updatedAt: now,
            ),
          );

      return (id: cartId, name: normalizedName);
    });
  }

  /// Finds a cart only when it belongs to this authenticated account.
  /// A missing or foreign cart is never activated or modified.
  Future<({String id, String name})?> getOwnedCart(String cartId) async {
    final owner = _owner;
    final id = cartId.trim();

    if (owner == null || id.isEmpty) {
      return null;
    }

    final cart =
        await (database.select(database.cartRecords)..where(
              (table) => table.id.equals(id) & table.ownerUserId.equals(owner),
            ))
            .getSingleOrNull();

    if (cart == null) {
      return null;
    }

    return (id: cart.id, name: cart.name);
  }

  /// Returns the current account's saved active cart, if still owned.
  /// Reading does not create, select, or modify any cart.
  Future<({String id, String name})?> getActiveCart() async {
    final owner = _owner;

    if (owner == null) {
      return null;
    }

    final selection = await (database.select(
      database.cartActiveSelectionRecords,
    )..where((table) => table.ownerUserId.equals(owner))).getSingleOrNull();

    if (selection == null) {
      return null;
    }

    // Defend against a stale or incorrectly assigned selection.
    return getOwnedCart(selection.cartId);
  }

  /// Saves the active cart only after verifying account ownership.
  /// Does not modify the selected cart's contents.
  Future<({String id, String name})> setActiveCart(String cartId) async {
    final owner = _owner;

    if (owner == null) {
      throw StateError('Cannot select a cart without authenticated ownership.');
    }

    final normalizedId = cartId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(cartId, 'cartId', 'Cart ID is required.');
    }

    return database.transaction(() async {
      final ownedCart = await getOwnedCart(normalizedId);

      if (ownedCart == null) {
        throw StateError(
          'Cart does not exist or does not belong to this account.',
        );
      }

      await database
          .into(database.cartActiveSelectionRecords)
          .insertOnConflictUpdate(
            CartActiveSelectionRecordsCompanion.insert(
              ownerUserId: owner,
              cartId: ownedCart.id,
              updatedAt: DateTime.now().toUtc(),
            ),
          );

      return ownedCart;
    });
  }

  /// Resolves a cart ID for one future read or write operation.
  ///
  /// Callers must retain the returned ID instead of resolving it
  /// again when an asynchronous operation eventually executes.
  /// This method does not change the saved active selection.
  Future<String?> resolveCurrentCartId() async {
    final owner = _owner;

    if (owner == null) {
      return null;
    }

    final active = await getActiveCart();

    if (active != null) {
      return active.id;
    }

    return _findOrCreateCart(owner);
  }

  /// Legacy entry point. Its selection behavior is unchanged in this step.
  Future<List<CartItemEntity>> getItems() async {
    final owner = _owner;

    if (owner == null) {
      return const <CartItemEntity>[];
    }

    final cartId = await _findOrCreateCart(owner);
    return getItemsForCart(cartId);
  }

  /// Reads catalog items from exactly one owned cart.
  /// The active selection is not read or modified here.
  Future<List<CartItemEntity>> getItemsForCart(String cartId) async {
    if (_owner == null) {
      throw StateError('Cannot read a cart without authenticated ownership.');
    }

    final ownedCart = await getOwnedCart(cartId);

    if (ownedCart == null) {
      throw StateError(
        'Cart does not exist or does not belong to this account.',
      );
    }

    return _readCartItemsForCart(ownedCart.id);
  }

  /// Reads catalog and manual items from exactly one owned cart.
  Future<List<CartItemEntity>> _readCartItemsForCart(String cartId) async {
    final query = database.select(database.cartItemRecords)
      ..where((table) => table.cartId.equals(cartId))
      ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]);

    final records = await query.get();
    final items = <CartItemEntity>[];

    for (final record in records) {
      if (record.kind == 'manual') {
        items.add(
          CartItemEntity.manual(
            id: record.id,
            name: record.productName,
            unitPrice: record.price,
            quantity: record.cartQuantity,
            unit: record.unit,
            note: record.note,
          ),
        );

        continue;
      }

      if (record.kind != 'catalog' || record.productId == null) {
        continue;
      }

      items.add(
        CartItemEntity(
          product: ProductEntity(
            id: record.productId!,
            supplierId: record.supplierId,
            supplierName: record.supplierName,
            name: record.productName,
            price: record.price,
            imageUrl: record.imageUrl,
            localImagePath: record.localImagePath,
            category: record.category,
            brand: record.brand,
            isAvailable: record.isAvailable,
            description: record.description,
            colors: _decodeColors(record.colorsJson),
            quantity: record.productQuantity,
            discount: record.discount,
            rating: record.rating,
            syncStatus: _decodeSyncStatus(record.syncStatus),
            syncError: record.syncError,
            createdAt: record.productCreatedAt?.toUtc(),
            updatedAt: record.productUpdatedAt?.toUtc(),
          ),
          quantity: record.cartQuantity,
        ),
      );
    }

    return List<CartItemEntity>.unmodifiable(items);
  }

  /// Legacy entry point: retains the previous default-cart behavior.
  Future<void> replaceItems(List<CartItemEntity> items) async {
    final owner = _owner;

    if (owner == null) {
      throw StateError(
        'Cannot persist a cart without authenticated ownership.',
      );
    }

    final now = DateTime.now().toUtc();

    await database.transaction(() async {
      final cartId = await _findOrCreateCart(owner);
      await _replaceCatalogItemsForCart(cartId, items, now);
    });
  }

  /// Writes catalog items to one explicitly identified, owned cart.
  /// The active selection is never consulted while this write executes.
  Future<void> replaceItemsForCart(
    String cartId,
    List<CartItemEntity> items,
  ) async {
    if (_owner == null) {
      throw StateError(
        'Cannot persist a cart without authenticated ownership.',
      );
    }

    final normalizedId = cartId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(cartId, 'cartId', 'Cart ID is required.');
    }

    final now = DateTime.now().toUtc();

    await database.transaction(() async {
      final ownedCart = await getOwnedCart(normalizedId);

      if (ownedCart == null) {
        throw StateError(
          'Cart does not exist or does not belong to this account.',
        );
      }

      await _replaceCatalogItemsForCart(ownedCart.id, items, now);
    });
  }

  /// Replaces the complete cart snapshot, including catalog and manual items.
  /// Only the explicitly identified owned cart is modified.
  Future<void> replaceAllItemsForCart(
    String cartId,
    List<CartItemEntity> items,
  ) async {
    if (_owner == null) {
      throw StateError(
        'Cannot persist a cart without authenticated ownership.',
      );
    }

    final normalizedId = cartId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(cartId, 'cartId', 'Cart ID is required.');
    }

    final now = DateTime.now().toUtc();

    await database.transaction(() async {
      final ownedCart = await getOwnedCart(normalizedId);

      if (ownedCart == null) {
        throw StateError(
          'Cart does not exist or does not belong to this account.',
        );
      }

      await _replaceAllItemsForCart(ownedCart.id, items, now);
    });
  }

  /// Shared catalog-only persistence. Caller must verify ownership
  /// and open a database transaction before invoking this helper.
  Future<void> _replaceCatalogItemsForCart(
    String cartId,
    List<CartItemEntity> items,
    DateTime now,
  ) async {
    final existing =
        await (database.select(database.cartItemRecords)..where(
              (table) =>
                  table.cartId.equals(cartId) & table.kind.equals('catalog'),
            ))
            .get();

    // Preserve stable IDs for products that remain in this cart.
    final existingIds = <String, String>{
      for (final record in existing)
        if (record.productId != null) record.productId!: record.id,
    };

    // Delete only catalog entries of the selected cart.
    // Never delete manual items or another cart's entries.
    await (database.delete(database.cartItemRecords)..where(
          (table) => table.cartId.equals(cartId) & table.kind.equals('catalog'),
        ))
        .go();

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final product = item.product;

      await database
          .into(database.cartItemRecords)
          .insert(
            CartItemRecordsCompanion.insert(
              id: existingIds[product.id] ?? const Uuid().v4(),
              cartId: cartId,
              kind: const Value('catalog'),
              productId: Value(product.id),
              supplierId: Value(product.supplierId),
              supplierName: Value(product.supplierName),
              productName: product.name,
              price: product.price,
              imageUrl: Value(product.imageUrl),
              localImagePath: Value(product.localImagePath),
              category: Value(product.category),
              brand: Value(product.brand),
              isAvailable: Value(product.isAvailable),
              description: Value(product.description),
              colorsJson: Value(jsonEncode(product.colors)),
              productQuantity: Value(product.quantity),
              discount: Value(product.discount),
              rating: Value(product.rating),
              syncStatus: Value(product.syncStatus.name),
              syncError: Value(product.syncError),
              productCreatedAt: Value(product.createdAt?.toUtc()),
              productUpdatedAt: Value(product.updatedAt?.toUtc()),
              cartQuantity: item.quantity,
              sortOrder: index,
              updatedAt: now,
            ),
          );
    }
  }

  /// Writes every item type in one transaction.
  /// Caller must verify ownership and open a database transaction.
  Future<void> _replaceAllItemsForCart(
    String cartId,
    List<CartItemEntity> items,
    DateTime now,
  ) async {
    final existing = await (database.select(
      database.cartItemRecords,
    )..where((table) => table.cartId.equals(cartId))).get();

    final existingCatalogIds = <String, String>{
      for (final record in existing)
        if (record.kind == 'catalog' && record.productId != null)
          record.productId!: record.id,
    };

    String manualIdFor(CartItemEntity item) {
      final explicitId = item.manualId?.trim();

      if (explicitId != null && explicitId.isNotEmpty) {
        return explicitId;
      }

      return item.product.id.trim();
    }

    // Validate the entire snapshot before deleting anything.
    final seenCatalogIds = <String>{};
    final seenManualIds = <String>{};
    final seenRowIds = <String>{};

    for (final item in items) {
      if (item.quantity < 1) {
        throw ArgumentError('Cart item quantity must be positive.');
      }

      if (item.isManual) {
        final manualId = manualIdFor(item);

        if (manualId.isEmpty) {
          throw ArgumentError('Manual item ID is required.');
        }

        if (!seenManualIds.add(manualId)) {
          throw ArgumentError('Duplicate manual item ID: $manualId');
        }

        if (!seenRowIds.add(manualId)) {
          throw ArgumentError('Duplicate cart row ID: $manualId');
        }

        final price = item.unitPrice;

        if (!price.isFinite || price < 0) {
          throw ArgumentError('Manual item price is invalid.');
        }
      } else {
        final productId = item.product.id;

        if (productId.trim().isEmpty) {
          throw ArgumentError('Catalog product ID is required.');
        }

        if (!seenCatalogIds.add(productId)) {
          throw ArgumentError('Duplicate catalog product ID: $productId');
        }

        final rowId = existingCatalogIds[productId] ?? const Uuid().v4();

        if (!seenRowIds.add(rowId)) {
          throw ArgumentError('Duplicate cart row ID: $rowId');
        }
      }
    }

    // Delete entries from this cart only.
    await (database.delete(
      database.cartItemRecords,
    )..where((table) => table.cartId.equals(cartId))).go();

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final product = item.product;

      if (item.isManual) {
        final manualId = manualIdFor(item);

        await database
            .into(database.cartItemRecords)
            .insert(
              CartItemRecordsCompanion.insert(
                id: manualId,
                cartId: cartId,
                kind: const Value('manual'),
                productId: const Value<String?>(null),
                supplierId: const Value(''),
                supplierName: const Value(''),
                productName: product.name,
                price: product.price,
                imageUrl: const Value(''),
                localImagePath: const Value<String?>(null),
                category: const Value(''),
                brand: const Value(''),
                isAvailable: const Value(true),
                description: const Value(''),
                colorsJson: const Value('[]'),
                productQuantity: const Value(0),
                discount: const Value(0),
                rating: const Value(0),
                syncStatus: const Value('synced'),
                syncError: const Value<String?>(null),
                productCreatedAt: const Value<DateTime?>(null),
                productUpdatedAt: const Value<DateTime?>(null),
                cartQuantity: item.quantity,
                sortOrder: index,
                updatedAt: now,
                unit: Value(item.unit),
                note: Value(item.note),
              ),
            );

        continue;
      }

      await database
          .into(database.cartItemRecords)
          .insert(
            CartItemRecordsCompanion.insert(
              id: existingCatalogIds[product.id] ?? const Uuid().v4(),
              cartId: cartId,
              kind: const Value('catalog'),
              productId: Value(product.id),
              supplierId: Value(product.supplierId),
              supplierName: Value(product.supplierName),
              productName: product.name,
              price: product.price,
              imageUrl: Value(product.imageUrl),
              localImagePath: Value(product.localImagePath),
              category: Value(product.category),
              brand: Value(product.brand),
              isAvailable: Value(product.isAvailable),
              description: Value(product.description),
              colorsJson: Value(jsonEncode(product.colors)),
              productQuantity: Value(product.quantity),
              discount: Value(product.discount),
              rating: Value(product.rating),
              syncStatus: Value(product.syncStatus.name),
              syncError: Value(product.syncError),
              productCreatedAt: Value(product.createdAt?.toUtc()),
              productUpdatedAt: Value(product.updatedAt?.toUtc()),
              cartQuantity: item.quantity,
              sortOrder: index,
              updatedAt: now,
            ),
          );
    }
  }

  List<String> _decodeColors(String value) {
    try {
      final decoded = jsonDecode(value);

      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } catch (_) {
      // Invalid optional metadata must not prevent restoration.
    }
    return const [];
  }

  ProductSyncStatus _decodeSyncStatus(String value) {
    for (final status in ProductSyncStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
    return ProductSyncStatus.synced;
  }
}
