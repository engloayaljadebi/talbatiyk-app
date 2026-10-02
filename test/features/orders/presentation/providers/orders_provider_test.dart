import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk/features/auth/domain/usecases/auth_usecase.dart';
import 'package:talbatiyk/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talbatiyk/features/auth/presentation/providers/auth_providers.dart';
import 'package:talbatiyk/features/auth/presentation/states/auth_state.dart';
import 'package:talbatiyk/features/orders/presentation/providers/orders_provider.dart';

void main() {
  group('orderIdTransitionRegistryProvider lifecycle', () {
    test('clears registered transitions when user logs out', () async {
      final fakeRepo = _FakeAuthRepository();
      final authController = AuthController(
        AuthUseCase(fakeRepo),
        autoRestore: false,
      );

      const user = AuthUserEntity(
        id: 'user-1',
        username: 'user1',
        displayName: 'User 1',
        status: 'active',
        lastLoginAt: null,
        contacts: [],
      );
      const session = AuthSessionEntity(user: user);

      authController.state = const AuthState(
        status: AuthStatus.authenticated,
        session: session,
      );

      final container = ProviderContainer(
        overrides: [authProvider.overrideWith((ref) => authController)],
      );
      addTearDown(container.dispose);

      final registry = container.read(orderIdTransitionRegistryProvider);

      // Register a transition
      registry.registerTransition(
        localOrderId: 'local-order-1',
        serverOrderId: '550e8400-e29b-41d4-a716-446655440000',
      );
      expect(
        registry.resolve('local-order-1'),
        '550e8400-e29b-41d4-a716-446655440000',
      );

      // Simulate sign out
      authController.state = const AuthState(
        status: AuthStatus.unauthenticated,
        session: null,
      );
      authController.notifyListeners();

      // Verify registry was cleared automatically on logout
      expect(registry.resolve('local-order-1'), 'local-order-1');
    });

    test(
      'clears registered transitions when authenticated user changes',
      () async {
        final fakeRepo = _FakeAuthRepository();
        final authController = AuthController(
          AuthUseCase(fakeRepo),
          autoRestore: false,
        );

        const user1 = AuthUserEntity(
          id: 'user-1',
          username: 'user1',
          displayName: 'User 1',
          status: 'active',
          lastLoginAt: null,
          contacts: [],
        );
        const session1 = AuthSessionEntity(user: user1);

        authController.state = const AuthState(
          status: AuthStatus.authenticated,
          session: session1,
        );

        final container = ProviderContainer(
          overrides: [authProvider.overrideWith((ref) => authController)],
        );
        addTearDown(container.dispose);

        final registry = container.read(orderIdTransitionRegistryProvider);

        registry.registerTransition(
          localOrderId: 'local-order-user1',
          serverOrderId: '550e8400-e29b-41d4-a716-446655440001',
        );

        // User 2 logs in
        const user2 = AuthUserEntity(
          id: 'user-2',
          username: 'user2',
          displayName: 'User 2',
          status: 'active',
          lastLoginAt: null,
          contacts: [],
        );
        const session2 = AuthSessionEntity(user: user2);

        authController.state = const AuthState(
          status: AuthStatus.authenticated,
          session: session2,
        );
        authController.notifyListeners();

        // Verify registry was cleared to prevent session leakage
        expect(registry.resolve('local-order-user1'), 'local-order-user1');
      },
    );
  });
}

final class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthUserEntity> getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<AuthSessionEntity> login({
    required String login,
    required String password,
    required String deviceName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthSessionEntity?> restoreSession() async => null;

  @override
  Future<void> logout() async {}
}
