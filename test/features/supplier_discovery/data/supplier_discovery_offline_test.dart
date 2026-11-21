import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbytk/core/database/app_database.dart';
import 'package:talbytk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbytk/features/auth/domain/services/account_session_fence.dart';
import 'package:talbytk/features/supplier_discovery/data/datasources/local/supplier_discovery_local_datasource.dart';
import 'package:talbytk/features/supplier_discovery/data/datasources/remote/supplier_discovery_remote_datasource.dart';
import 'package:talbytk/features/supplier_discovery/data/repositories/supplier_discovery_repository_impl.dart';
import 'package:talbytk/features/supplier_discovery/domain/entities/supplier_candidate_entity.dart';
import 'package:talbytk_api/talbytk_api.dart';

void main() {
  late AppDatabase database;
  late SupplierDiscoveryLocalDataSource local;
  late _Remote remote;
  const userId = 'user-a';
  late AuthSessionEntity session;
  late SupplierDiscoveryRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    local = SupplierDiscoveryLocalDataSource(database);
    remote = _Remote();
    session = _session(userId);
    repository = SupplierDiscoveryRepositoryImpl(
      remote,
      AccountSessionFence(() => session),
    );
  });
  tearDown(() => database.close());

  test(
    'network failure never exposes a supplier list from before market isolation',
    () async {
      final online = await repository.getSuppliers();
      expect(online.single.isFromCache, isFalse);

      remote.error = _error(DioExceptionType.connectionError);
      await local.replace(
        userId: userId,
        suppliers: const [SupplierCandidateEntity(id: 'old', name: 'Old')],
      );

      await expectLater(
        repository.getSuppliers(),
        throwsA(isA<DioException>()),
      );

      session = _session('user-b');
      await expectLater(
        repository.getSuppliers(),
        throwsA(isA<DioException>()),
      );
    },
  );

  test('an empty server response returns an empty supplier list', () async {
    await repository.getSuppliers();
    remote.suppliers = BuiltList<SupplierSummaryResource>();
    expect(await repository.getSuppliers(), isEmpty);
    remote.error = _error(DioExceptionType.connectionError);
    await expectLater(repository.getSuppliers(), throwsA(isA<DioException>()));
  });

  test('authentication rejection does not expose cached suppliers', () async {
    await repository.getSuppliers();
    remote.error = DioException(
      requestOptions: RequestOptions(path: '/api/v1/suppliers'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/api/v1/suppliers'),
        statusCode: 401,
      ),
    );
    await expectLater(repository.getSuppliers(), throwsA(isA<DioException>()));
  });

  test(
    'local snapshot is available through a new data source instance',
    () async {
      await local.replace(
        userId: userId,
        suppliers: const [SupplierCandidateEntity(id: 'a', name: 'A')],
      );
      final reopened = SupplierDiscoveryLocalDataSource(database);
      expect((await reopened.readSnapshot(userId: userId)).single.id, 'a');
    },
  );
}

DioException _error(DioExceptionType type) => DioException(
  requestOptions: RequestOptions(path: '/api/v1/suppliers'),
  type: type,
);

final class _Remote implements SupplierDiscoveryRemoteDataSource {
  BuiltList<SupplierSummaryResource> suppliers = BuiltList([
    SupplierSummaryResource(
      (builder) => builder
        ..id = 'supplier-a'
        ..name = 'Supplier A',
    ),
  ]);
  Object? error;

  @override
  Future<BuiltList<SupplierSummaryResource>> index() async {
    if (error != null) throw error!;
    return suppliers;
  }
}

AuthSessionEntity _session(String id) => AuthSessionEntity(
  user: AuthUserEntity(
    id: id,
    username: id,
    displayName: id,
    status: 'active',
    lastLoginAt: null,
    contacts: const [],
  ),
);
