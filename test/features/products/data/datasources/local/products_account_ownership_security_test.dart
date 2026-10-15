import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/services/account_session_fence.dart';
import 'package:talbatiyk/features/products/data/datasources/local/products_local_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';

const _key = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';

const _product = ProductModel(
  id: '11111111-1111-4111-8111-111111111111',
  supplierId: '22222222-2222-4222-8222-222222222222',
  supplierName: 'Shared Business',
  name: 'Account A Private Product',
  price: 1500,
  imageUrl: '',
  serverVersion: 1,
  category: 'Electronics',
  brand: 'Talbatiyk',
  isAvailable: true,
  quantity: 3,
);

AuthSessionEntity _session(String userId) {
  return AuthSessionEntity(
    user: AuthUserEntity(
      id: userId,
      username: userId,
      displayName: userId,
      status: 'active',
      lastLoginAt: null,
      contacts: const <AuthContactEntity>[],
    ),
  );
}

void main() {
  late AppDatabase database;
  late ProductsLocalDataSource source;
  late AuthSessionEntity? currentSession;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());

    currentSession = _session('account-A');

    final fence = AccountSessionFence(() => currentSession);

    source = ProductsLocalDataSource(database, sessionFence: fence);
  });

  tearDown(() async {
    await database.close();
  });

  test('account B cannot read account A management product cache', () async {
    await source.upsertSyncedProduct(_product);

    expect(await source.getProducts(), hasLength(1));

    // Both users may have access to the same business.
    // Local account-owned cache must still be isolated.
    currentSession = _session('account-B');

    final visible = await source.getProducts();

    expect(
      visible,
      isEmpty,
      reason: 'Account B must not receive A private local products.',
    );

    currentSession = _session('account-A');

    expect(await source.getProducts(), hasLength(1));
  });

  test('account B cannot recover account A publish attempt', () async {
    await source.preparePublishAttempt(product: _product, idempotencyKey: _key);

    expect(await source.getRetryablePublishAttempts(), hasLength(1));

    currentSession = _session('account-B');

    final attempts = await source.getRetryablePublishAttempts();

    expect(
      attempts,
      isEmpty,
      reason: 'Account B must not replay account A publication.',
    );

    currentSession = _session('account-A');

    expect(await source.getRetryablePublishAttempts(), hasLength(1));
  });

  test('account B cannot delete account A durable publish attempt', () async {
    await source.preparePublishAttempt(product: _product, idempotencyKey: _key);

    currentSession = _session('account-B');

    await expectLater(
      source.completePublishAttempt(_key),
      throwsA(isA<StateError>()),
    );

    currentSession = _session('account-A');

    final retained = await source.getRetryablePublishAttempts();

    expect(
      retained,
      hasLength(1),
      reason: 'A durable attempt must survive a foreign mutation.',
    );
  });

  test('account B cannot update account A stored product', () async {
    await source.upsertSyncedProduct(_product);

    currentSession = _session('account-B');

    await expectLater(
      source.updateProduct(_product),
      throwsA(isA<StateError>()),
    );

    currentSession = _session('account-A');

    final products = await source.getProducts();
    expect(products, hasLength(1));
    expect(products.single.name, _product.name);
  });

  test('account B cannot delete account A stored product', () async {
    await source.upsertSyncedProduct(_product);

    currentSession = _session('account-B');

    await source.deleteProduct(_product.id);

    currentSession = _session('account-A');

    final products = await source.getProducts();
    expect(
      products,
      hasLength(1),
      reason: 'Account B must not delete or hide A product.',
    );
  });

  test('account B reconciliation cannot erase account A cache', () async {
    await source.upsertSyncedProduct(_product);

    currentSession = _session('account-B');

    await source.reconcileBusinessProducts(
      businessId: _product.supplierId,
      serverProducts: const <ProductModel>[],
    );

    currentSession = _session('account-A');

    expect(
      await source.getProducts(),
      hasLength(1),
      reason: 'Reconciliation must not delete another account cache.',
    );
  });

  test('account B cannot mark account A publish attempt for retry', () async {
    await source.preparePublishAttempt(product: _product, idempotencyKey: _key);

    currentSession = _session('account-B');

    await expectLater(
      source.markPublishAttemptRetry(
        idempotencyKey: _key,
        attempts: 1,
        error: StateError('Network failure'),
        nextAttemptAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
      ),
      throwsA(isA<StateError>()),
    );

    currentSession = _session('account-A');

    expect(await source.getRetryablePublishAttempts(), hasLength(1));
  });

  test('account B cannot permanently fail account A publish attempt', () async {
    await source.preparePublishAttempt(product: _product, idempotencyKey: _key);

    currentSession = _session('account-B');

    await expectLater(
      source.markPublishAttemptPermanentFailure(
        idempotencyKey: _key,
        attempts: 1,
        error: const FormatException('Invalid response'),
      ),
      throwsA(isA<StateError>()),
    );

    currentSession = _session('account-A');

    expect(await source.getRetryablePublishAttempts(), hasLength(1));
  });
  test('logged out user cannot inspect supplier product cache', () async {
    await source.upsertSyncedProduct(_product);

    currentSession = null;

    await expectLater(source.getProducts(), throwsA(isA<StateError>()));
  });

  test('logged out user cannot inspect durable publishing payload', () async {
    await source.preparePublishAttempt(product: _product, idempotencyKey: _key);

    currentSession = null;

    await expectLater(
      source.getRetryablePublishAttempts(),
      throwsA(isA<StateError>()),
    );
  });
}
