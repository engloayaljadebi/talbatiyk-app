import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/supplier_discovery/data/datasources/local/supplier_discovery_local_datasource.dart';
import 'package:talbatiyk/features/supplier_discovery/data/datasources/remote/supplier_discovery_remote_datasource.dart';
import 'package:talbatiyk/features/supplier_discovery/data/repositories/supplier_discovery_repository_impl.dart';
import 'package:talbatiyk/features/supplier_discovery/domain/entities/supplier_candidate_entity.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

void main() {
  late AppDatabase database;
  late SupplierDiscoveryLocalDataSource local;
  late _Remote remote;
  late String userId;
  late SupplierDiscoveryRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    local = SupplierDiscoveryLocalDataSource(database);
    remote = _Remote();
    userId = 'user-a';
    repository = SupplierDiscoveryRepositoryImpl(
      remote,
      localDataSource: local,
      currentUserId: () => userId,
    );
  });
  tearDown(() => database.close());

  test(
    'online snapshot survives a network failure and is scoped by user',
    () async {
      final online = await repository.getSuppliers();
      expect(online.single.isFromCache, isFalse);

      remote.error = _error(DioExceptionType.connectionError);
      final offline = await repository.getSuppliers();
      expect(offline.single.id, 'supplier-a');
      expect(offline.single.isFromCache, isTrue);

      userId = 'user-b';
      await expectLater(
        repository.getSuppliers(),
        throwsA(isA<DioException>()),
      );
    },
  );

  test('authoritative empty response clears old snapshot', () async {
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
