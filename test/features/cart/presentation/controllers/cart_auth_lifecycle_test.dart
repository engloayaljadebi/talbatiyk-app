import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk/features/auth/domain/usecases/auth_usecase.dart';
import 'package:talbatiyk/features/auth/presentation/providers/auth_providers.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  test('account switching preserves each cart and pending writes', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = _FakeAuthRepository();

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        authUseCaseProvider.overrideWithValue(AuthUseCase(repository)),
      ],
    );

    final subscription = container.listen(
      cartProvider,
      (previous, next) {},
      fireImmediately: true,
    );

    addTearDown(() async {
      subscription.close();
      container.dispose();
      await database.close();
    });

    final auth = container.read(authProvider);

    await Future<void>.delayed(Duration.zero);

    expect(auth.state.isAuthenticated, isFalse);
    expect(container.read(cartProvider).isEmpty, isTrue);

    expect(
      await auth.login(
        login: 'account-A',
        password: 'test',
        deviceName: 'test',
      ),
      isTrue,
    );

    final cartA = container.read(cartProvider);
    await cartA.ready;

    expect(cartA.addProduct(_product), CartAddResult.added);
    expect(cartA.addProduct(_product), CartAddResult.added);

    // Switch accounts before explicitly flushing A's writes.
    await auth.logout();

    final guestCart = container.read(cartProvider);
    expect(guestCart.isEmpty, isTrue);
    expect(identical(guestCart, cartA), isFalse);

    expect(
      await auth.login(
        login: 'account-B',
        password: 'test',
        deviceName: 'test',
      ),
      isTrue,
    );

    final cartB = container.read(cartProvider);
    await cartB.ready;

    expect(identical(cartA, cartB), isFalse);
    expect(cartB.isEmpty, isTrue);

    expect(cartB.addProduct(_product), CartAddResult.added);

    await Future.wait([cartA.flushPersistence(), cartB.flushPersistence()]);

    expect(cartB.quantityOf(_product.id), 1);

    await auth.logout();

    expect(
      await auth.login(
        login: 'account-A',
        password: 'test',
        deviceName: 'test',
      ),
      isTrue,
    );

    final restoredA = container.read(cartProvider);
    await restoredA.ready;

    expect(restoredA.quantityOf(_product.id), 2);

    // A profile refresh with the same owner must not recreate the cart.
    await auth.refreshCurrentUser();

    expect(identical(container.read(cartProvider), restoredA), isTrue);

    final foreignKeyErrors = await database
        .customSelect('PRAGMA foreign_key_check;')
        .get();

    expect(foreignKeyErrors, isEmpty);
  });
}

const _product = ProductEntity(
  id: 'same-product',
  supplierId: 'supplier-1',
  supplierName: 'Supplier',
  name: 'Product',
  price: 1500,
  imageUrl: '',
  category: 'Test',
  brand: 'Test',
  isAvailable: true,
);

final class _FakeAuthRepository implements AuthRepository {
  AuthUserEntity? _current;

  @override
  Future<AuthSessionEntity?> restoreSession() async => null;

  @override
  Future<AuthSessionEntity> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    _current = AuthUserEntity(
      id: login,
      username: login,
      displayName: login,
      status: 'active',
      lastLoginAt: null,
      contacts: const [],
    );

    return AuthSessionEntity(user: _current!);
  }

  @override
  Future<void> logout() async {
    _current = null;
  }

  @override
  Future<AuthUserEntity> getCurrentUser() async {
    final current = _current;
    if (current == null) throw StateError('No authenticated user');
    return current;
  }

  @override
  Future<AuthUserEntity> updateProfile({
    String? username,
    String? displayName,
  }) => getCurrentUser();

  @override
  Future<List<({String id, String name})>>
  fetchRegistrationCategories() async => [];

  @override
  Future<AuthSessionEntity> registerFromMobile(
    Map<String, Object?> payload,
  ) async {
    throw UnimplementedError();
  }
}
