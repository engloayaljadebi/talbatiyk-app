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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/core/network/network_providers.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_token_storage.dart';
import 'package:talbatiyk/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:talbatiyk/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:talbatiyk/features/auth/domain/usecases/auth_usecase.dart';
import 'package:talbatiyk/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talbatiyk/features/auth/presentation/providers/auth_providers.dart';
import 'package:talbatiyk/features/auth/presentation/states/auth_state.dart';

void main() {
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
