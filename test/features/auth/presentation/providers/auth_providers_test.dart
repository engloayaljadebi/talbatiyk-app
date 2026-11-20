/*
|--------------------------------------------------------------------------
| Auth Providers Tests
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - التحقق من بناء سلسلة اعتماد Auth عبر Riverpod.
| - استبدال GeneratedApiClient بعنوان اختباري.
| - استبدال Secure Storage بتخزين وهمي.
| - التأكد من تشغيل restoreSession تلقائيًا.
| - التأكد من الانتقال إلى unauthenticated عند عدم وجود Token.
|
| الهدف:
| إثبات أن Wiring الحقيقي يعمل دون شبكة أو Platform Channels.
|
*/

import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/datasources/remote/orders_remote_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';
import 'package:talbatiyk/features/orders/data/sync/orders_sync_coordinator.dart';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/core/network/network_providers.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_token_storage.dart';
import 'package:talbatiyk/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:talbatiyk/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/usecases/auth_usecase.dart';
import 'package:talbatiyk/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talbatiyk/features/auth/presentation/providers/account_session_fence_provider.dart';
import 'package:talbatiyk/features/auth/presentation/providers/auth_providers.dart';
import 'package:talbatiyk/features/auth/presentation/states/auth_state.dart';

void main() {
  test(
    'expired session preserves queued order until its owner signs in again',
    () async {
      final api = GeneratedApiClient.create(baseUrl: 'http://localhost/api/v1');
      final adapter = _OrderSessionJourneyAdapter();
      api.client.dio.httpClientAdapter = adapter;
      addTearDown(() => api.client.dio.close(force: true));

      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final container = ProviderContainer(
        overrides: [
          generatedApiClientProvider.overrideWithValue(api),
          secureKeyValueStoreProvider.overrideWithValue(
            FakeSecureKeyValueStore(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authProvider);
      await Future<void>.delayed(Duration.zero);

      Future<void> signIn(String account) async {
        adapter.loginAccount = account;
        expect(
          await controller.login(
            login: account,
            password: 'test-password',
            deviceName: 'test-device',
          ),
          isTrue,
        );
        expect(controller.state.user?.id, account);
      }

      await signIn('account-a');

      final fence = container.read(accountSessionFenceProvider);
      final local = OrdersLocalDataSource(database, sessionFence: fence);
      final coordinator = OrdersSyncCoordinator(
        database: database,
        sessionFence: fence,
        localDataSource: local,
        remoteDataSource: OrdersRemoteDataSource(generatedApiClient: api),
      );

      await local.createOrder(
        CreateOrderModel(
          supplierIds: const ['supplier-1'],
          items: const [
            OrderItemModel(
              productId: 'product-1',
              productName: 'Test product',
              unitPrice: 100,
              quantity: 1,
              supplierId: 'supplier-1',
              supplierName: 'Test supplier',
            ),
          ],
        ),
      );

      final outbox = database.select(database.syncOperations);
      final queued = await outbox.getSingle();
      expect(queued.ownerUserId, 'account-a');

      await coordinator.syncPendingOrders();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(await outbox.getSingle(), queued);
      expect(adapter.orderTokens, ['Bearer token-account-a']);
      final originalKey = adapter.orderKeys.single;
      expect(originalKey, isNotEmpty);

      await signIn('account-b');
      expect(await local.getOrders(), isEmpty);
      await coordinator.syncPendingOrders();
      expect(adapter.orderTokens, hasLength(1));
      expect(await outbox.getSingle(), queued);

      await signIn('account-a');
      await coordinator.syncPendingOrders();

      expect(adapter.orderTokens, [
        'Bearer token-account-a',
        'Bearer token-account-a',
      ]);
      expect(adapter.orderKeys, [originalKey, originalKey]);
      expect(await outbox.get(), isEmpty);
      expect((await local.getOrders()).single.id, 'server-order-1');
    },
  );

  test('protected HTTP 401 clears the saved auth session', () async {
    final api = GeneratedApiClient.create(baseUrl: 'http://localhost/api/v1');
    final adapter = _AuthExpiryAdapter();
    api.client.dio.httpClientAdapter = adapter;
    addTearDown(() => api.client.dio.close(force: true));

    final container = ProviderContainer(
      overrides: [
        generatedApiClientProvider.overrideWithValue(api),
        secureKeyValueStoreProvider.overrideWithValue(
          FakeSecureKeyValueStore(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(authProvider);
    await Future<void>.delayed(Duration.zero);

    final tokenStorage = container.read(authTokenStorageProvider);
    final sessionStorage = container.read(verifiedAuthSessionStorageProvider);

    await tokenStorage.saveAccessToken('fake-expiring-token');
    await controller.restoreSession();

    expect(controller.state.status, AuthStatus.authenticated);
    expect(await sessionStorage.readVerifiedSession(), isNotNull);

    await expectLater(
      api.getJsonAuthenticated(path: '/protected-test'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status code',
          401,
        ),
      ),
    );

    await Future<void>.delayed(Duration.zero);

    expect(controller.state.status, AuthStatus.unauthenticated);
    expect(controller.state.session, isNull);
    expect(await tokenStorage.readAccessToken(), isNull);
    expect(await sessionStorage.readVerifiedSession(), isNull);
    expect(adapter.paths, ['/api/v1/auth/me', '/api/v1/protected-test']);
  });

  test(
    'auth providers build dependency chain and restore empty session',
    () async {
      final secureStorage = FakeSecureKeyValueStore();

      final container = ProviderContainer(
        overrides: [
          /*
           * لا نستخدم API_BASE_URL الحقيقي داخل الاختبار.
           *
           * لن يتم إجراء HTTP Request لأن Fake Storage
           * لا يحتوي على Access Token.
           */
          generatedApiClientProvider.overrideWithValue(
            GeneratedApiClient.create(baseUrl: 'http://127.0.0.1:8000/api/v1'),
          ),

          /*
           * يمنع flutter_secure_storage من استخدام
           * Platform Channels أثناء Unit Test.
           */
          secureKeyValueStoreProvider.overrideWithValue(secureStorage),
        ],
      );

      addTearDown(container.dispose);

      // التأكد من بناء Remote DataSource الحقيقي.
      expect(
        container.read(authRemoteDataSourceProvider),
        isA<AuthRemoteDataSourceImpl>(),
      );

      // التأكد من بناء Repository الحقيقي.
      expect(container.read(authRepositoryProvider), isA<AuthRepositoryImpl>());

      // التأكد من بناء UseCase الحقيقي.
      expect(container.read(authUseCaseProvider), isA<AuthUseCase>());

      // إنشاء Controller من Riverpod.
      final controller = container.read(authProvider);

      expect(controller, isA<AuthController>());

      /*
       * AuthController يبدأ restoreSession تلقائيًا.
       *
       * أثناء أول لحظة سيكون restoring.
       */
      expect(controller.state.status, AuthStatus.restoring);

      /*
       * نعطي Future الخاصة بقراءة التخزين فرصة للانتهاء.
       */
      await Future<void>.delayed(Duration.zero);

      // لا يوجد Token محفوظ، لذلك لا توجد جلسة.
      expect(controller.state.status, AuthStatus.unauthenticated);

      expect(controller.state.session, isNull);

      expect(controller.state.isAuthenticated, isFalse);

      expect(secureStorage.readCalled, isTrue);
    },
  );
  test(
    'session fence uses authenticated state and rejects signing out',
    () async {
      final container = ProviderContainer(
        overrides: [
          generatedApiClientProvider.overrideWithValue(
            GeneratedApiClient.create(baseUrl: 'http://127.0.0.1:8000/api/v1'),
          ),
          secureKeyValueStoreProvider.overrideWithValue(
            FakeSecureKeyValueStore(),
          ),
        ],
      );

      addTearDown(container.dispose);

      final controller = container.read(authProvider);

      // No stored token: no network request is performed.
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isAuthenticated, isFalse);

      final fence = container.read(accountSessionFenceProvider);

      expect(fence.capture, throwsStateError);

      const sessionA = AuthSessionEntity(
        user: AuthUserEntity(
          id: 'account-A',
          username: 'user-a',
          displayName: 'Account A',
          status: 'active',
          lastLoginAt: null,
          contacts: <AuthContactEntity>[],
        ),
      );

      // Inject a controlled authenticated state for this integration test.
      controller.state = const AuthState(
        status: AuthStatus.authenticated,
        session: sessionA,
      );

      final leaseA = fence.capture();

      expect(leaseA.ownerUserId, 'account-A');
      expect(leaseA.isCurrent, isTrue);

      // AuthController retains the session object temporarily
      // when sign-out begins. It must already be considered invalid.
      controller.state = const AuthState(
        status: AuthStatus.signingOut,
        session: sessionA,
      );

      expect(leaseA.isCurrent, isFalse);
      expect(leaseA.ensureCurrent, throwsStateError);
      expect(fence.capture, throwsStateError);

      const sessionB = AuthSessionEntity(
        user: AuthUserEntity(
          id: 'account-B',
          username: 'user-b',
          displayName: 'Account B',
          status: 'active',
          lastLoginAt: null,
          contacts: <AuthContactEntity>[],
        ),
      );

      controller.state = const AuthState(
        status: AuthStatus.authenticated,
        session: sessionB,
      );

      expect(leaseA.isCurrent, isFalse);

      final leaseB = fence.capture();

      expect(leaseB.ownerUserId, 'account-B');
      expect(leaseB.isCurrent, isTrue);
    },
  );
}

/// تخزين وهمي بسيط لاختبارات Riverpod.
///
/// يمنع الاختبار من الاعتماد على flutter_secure_storage الحقيقي.
final class FakeSecureKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  bool readCalled = false;

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    readCalled = true;

    return _values[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _values.containsKey(key);
  }
}

final class _AuthExpiryAdapter implements HttpClientAdapter {
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    paths.add(path);
    final isProfile = path == '/api/v1/auth/me';

    return ResponseBody.fromString(
      isProfile
          ? '{"data":{"id":"auth-test-user","username":"tester",'
                '"display_name":"Test User","status":"active",'
                '"last_login_at":null,"contacts":[]}}'
          : '{"message":"Unauthenticated."}',
      isProfile ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

final class _OrderSessionJourneyAdapter implements HttpClientAdapter {
  String loginAccount = 'account-a';
  final orderTokens = <String>[];
  final orderKeys = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    const headers = {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    };

    if (options.method == 'POST' && options.uri.path == '/api/v1/auth/login') {
      final account = loginAccount;
      return ResponseBody.fromString(
        '{"data":{"user":{"id":"$account","username":"$account",'
        '"display_name":"Test User","status":"active","contacts":[]},'
        '"access_token":"token-$account","token_type":"Bearer"}}',
        200,
        headers: headers,
      );
    }

    if (options.method == 'POST' && options.uri.path == '/api/v1/orders') {
      String header(String name) => options.headers.entries
          .singleWhere((entry) => entry.key.toLowerCase() == name)
          .value
          .toString();

      orderTokens.add(header('authorization'));
      orderKeys.add(header('idempotency-key'));

      if (orderTokens.length == 1) {
        return ResponseBody.fromString(
          '{"message":"Unauthenticated."}',
          401,
          headers: headers,
        );
      }

      return ResponseBody.fromString(
        '{"data":{"id":"server-order-1","status":"pending",'
        '"aggregate_status":"pending_responses","items":[],'
        '"created_at":"2026-11-21T00:00:00Z"}}',
        201,
        headers: headers,
      );
    }

    throw StateError(
      'Unexpected test request: ${options.method} ${options.uri}',
    );
  }

  @override
  void close({bool force = false}) {}
}
