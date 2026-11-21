/*
|--------------------------------------------------------------------------
| Auth Providers
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - توفير AuthRemoteDataSource.
| - توفير Secure Token Storage.
| - توفير Verified Auth Session Storage.
| - توفير AuthRepository.
| - توفير AuthUseCase.
| - توفير AuthController للواجهة.
|
| التسلسل المعماري:
|
| GeneratedApiClient
|       ↓
| AuthRemoteDataSource
|       ↓
| AuthRepository
|       ├── AuthTokenStorage
|       └── VerifiedAuthSessionStorage
|       ↓
| AuthUseCase
|       ↓
| AuthController
|       ↓
| UI
|
*/

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talbytk/core/network/network_providers.dart';

import '../../data/datasources/local/auth_session_storage.dart';
import '../../data/datasources/local/auth_token_storage.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecase.dart';
import '../controllers/auth_controller.dart';

final _authSessionExpiryProvider = Provider<StreamController<void>>((ref) {
  final events = StreamController<void>.broadcast(sync: true);
  ref.onDispose(events.close);
  return events;
});

/// يوفر مصدر المصادقة البعيد المرتبط بعميل OpenAPI.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(generatedApiClientProvider);
  final events = ref.watch(_authSessionExpiryProvider);

  apiClient.onSessionExpired = () => events.add(null);
  ref.onDispose(() => apiClient.onSessionExpired = null);

  return AuthRemoteDataSourceImpl(apiClient);
});

/// يوفر التخزين الآمن منخفض المستوى.
final secureKeyValueStoreProvider = Provider<SecureKeyValueStore>((ref) {
  return FlutterSecureKeyValueStore();
});

/// يوفر تخزين Access Token الخاص بالمصادقة.
final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  final SecureKeyValueStore secureStorage = ref.watch(
    secureKeyValueStoreProvider,
  );

  return AuthTokenStorageImpl(secureStorage);
});

/// يوفر آخر جلسة مصادقة تم التحقق منها من الخادم.
final verifiedAuthSessionStorageProvider = Provider<VerifiedAuthSessionStorage>(
  (ref) {
    final SecureKeyValueStore secureStorage = ref.watch(
      secureKeyValueStoreProvider,
    );

    return VerifiedAuthSessionStorageImpl(secureStorage);
  },
);

/// يربط Remote API والتخزين الآمن بطبقة Domain.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(authTokenStorageProvider),
    verifiedSessionStorage: ref.watch(verifiedAuthSessionStorageProvider),
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
  final controller = AuthController(ref.watch(authUseCaseProvider));
  final events = ref.watch(_authSessionExpiryProvider);

  final subscription = events.stream.listen((_) {
    final tokenStorage = ref.read(authTokenStorageProvider);
    final sessionStorage = ref.read(verifiedAuthSessionStorageProvider);

    controller.handleSessionExpired(() async {
      try {
        await tokenStorage.deleteAccessToken();
      } finally {
        await sessionStorage.deleteVerifiedSession();
      }
    });
  });
  ref.onDispose(subscription.cancel);

  return controller;
});
