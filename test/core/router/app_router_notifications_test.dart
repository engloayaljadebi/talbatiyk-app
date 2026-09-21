import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/router/app_router.dart';
import 'package:talbatiyk/core/router/route_names.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk/features/auth/presentation/pages/login_page.dart';
import 'package:talbatiyk/features/auth/presentation/providers/auth_providers.dart';

void main() {
  const user = AuthUserEntity(
    id: '11111111-1111-4111-8111-111111111111',
    username: 'notification_user',
    displayName: 'Notification User',
    status: 'active',
    lastLoginAt: null,
    contacts: <AuthContactEntity>[],
  );

  const session = AuthSessionEntity(user: user);

  Future<void> pumpFrames(WidgetTester tester) async {
    await tester.pump();

    for (var index = 0; index < 12; index++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets(
    'authenticated notifications route receives current auth user id',
    (tester) async {
      String? routedUserId;

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(restoreResult: session),
          ),
          mainRoutePageFactoryProvider.overrideWithValue(
            () => const _TestMainPage(),
          ),
          notificationsRoutePageFactoryProvider.overrideWithValue((userId) {
            routedUserId = userId;

            return _TestNotificationsPage(userId: userId);
          }),
        ],
      );

      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await pumpFrames(tester);

      expect(find.byType(_TestMainPage), findsOneWidget);

      router.go(RouteNames.notifications);

      await pumpFrames(tester);

      expect(find.byType(_TestNotificationsPage), findsOneWidget);

      expect(routedUserId, user.id);

      expect(find.text('notifications-user:${user.id}'), findsOneWidget);
    },
  );

  testWidgets('unauthenticated user cannot remain on notifications route', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(restoreResult: null),
        ),
        mainRoutePageFactoryProvider.overrideWithValue(
          () => const _TestMainPage(),
        ),
        notificationsRoutePageFactoryProvider.overrideWithValue(
          (userId) => _TestNotificationsPage(userId: userId),
        ),
      ],
    );

    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await pumpFrames(tester);

    expect(find.byType(LoginPage), findsOneWidget);

    router.go(RouteNames.notifications);

    await pumpFrames(tester);

    expect(find.byType(LoginPage), findsOneWidget);

    expect(find.byType(_TestNotificationsPage), findsNothing);
  });
}

final class _TestMainPage extends StatelessWidget {
  const _TestMainPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('test-main'));
  }
}

final class _TestNotificationsPage extends StatelessWidget {
  const _TestNotificationsPage({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text('notifications-user:$userId'));
  }
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.restoreResult});

  final AuthSessionEntity? restoreResult;

  @override
  Future<AuthSessionEntity?> restoreSession() async {
    return restoreResult;
  }

  @override
  Future<AuthSessionEntity> login({
    required String login,
    required String password,
    required String deviceName,
  }) {
    throw StateError('Unexpected login in router test.');
  }

  @override
  Future<AuthUserEntity> getCurrentUser() {
    throw StateError('Unexpected getCurrentUser in router test.');
  }

  @override
  Future<void> logout() async {}
}
