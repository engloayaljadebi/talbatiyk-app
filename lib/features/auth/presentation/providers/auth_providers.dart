/*
|--------------------------------------------------------------------------
| Auth Providers
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - توفير AuthRemoteDataSource.
| - توفير Secure Token Storage.
| - توفير AuthRepository.
| - توفير AuthUseCase.
| - توفير AuthController للواجهة.
|
| التدفق:
|
| GeneratedApiClient
|       ↓
| AuthRemoteDataSource
|       ↓
| AuthRepository ← Secure Token Storage
|       ↓
| AuthUseCase
|       ↓
| AuthController
|       ↓
| UI
|
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talbatiyk/core/network/network_providers.dart';

import '../../data/datasources/local/auth_token_storage.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecase.dart';
import '../controllers/auth_controller.dart';

/// يوفر مصدر المصادقة البعيد المرتبط بعميل OpenAPI.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(generatedApiClientProvider);

  return AuthRemoteDataSourceImpl(apiClient);
});

/// يوفر التخزين الآمن منخفض المستوى.
final secureKeyValueStoreProvider = Provider<SecureKeyValueStore>((ref) {
  return FlutterSecureKeyValueStore();
});

/// يوفر تخزين Access Token الخاص بالمصادقة.
final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  final secureStorage = ref.watch(secureKeyValueStoreProvider);

  return AuthTokenStorageImpl(secureStorage);
});

/// يربط Remote API والتخزين الآمن بطبقة Domain.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(authTokenStorageProvider),
  );
});

/// يوفر عمليات المصادقة التي تستطيع الواجهة تنفيذها.
final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  return AuthUseCase(ref.watch(authRepositoryProvider));
});

/// يدير حالة المصادقة داخل التطبيق.
///
/// AuthController سيبدأ تلقائيًا بمحاولة restoreSession()
/// عند أول استخدام للـProvider.
final authProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(ref.watch(authUseCaseProvider));
});
