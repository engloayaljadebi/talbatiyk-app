/*
|--------------------------------------------------------------------------
| Auth Token Storage Tests
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - اختبار حفظ Access Token.
| - اختبار قراءة Access Token.
| - اختبار حذف Access Token.
| - اختبار التحقق من وجود Token.
| - اختبار تنظيف المسافات حول Token قبل الحفظ.
| - اختبار رفض Token الفارغ.
|
| نستخدم Fake Storage داخل الذاكرة حتى لا تعتمد الاختبارات
| على Android Keystore أو Windows Credential Storage.
|
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_token_storage.dart';

void main() {
  group('AuthTokenStorageImpl', () {
    late FakeSecureKeyValueStore secureStore;
    late AuthTokenStorageImpl tokenStorage;

    setUp(() {
      secureStore = FakeSecureKeyValueStore();
      tokenStorage = AuthTokenStorageImpl(secureStore);
    });

    test('saveAccessToken stores token securely', () async {
      await tokenStorage.saveAccessToken('test-access-token');

      expect(await tokenStorage.readAccessToken(), 'test-access-token');

      expect(await tokenStorage.hasAccessToken(), isTrue);
    });

    test('saveAccessToken trims surrounding whitespace', () async {
      await tokenStorage.saveAccessToken('   test-access-token   ');

      expect(await tokenStorage.readAccessToken(), 'test-access-token');
    });

    test('readAccessToken returns null when token does not exist', () async {
      expect(await tokenStorage.readAccessToken(), isNull);

      expect(await tokenStorage.hasAccessToken(), isFalse);
    });

    test('deleteAccessToken removes stored token', () async {
      await tokenStorage.saveAccessToken('test-access-token');

      expect(await tokenStorage.hasAccessToken(), isTrue);

      await tokenStorage.deleteAccessToken();

      expect(await tokenStorage.readAccessToken(), isNull);

      expect(await tokenStorage.hasAccessToken(), isFalse);
    });

    test('saveAccessToken rejects empty token', () async {
      expect(() => tokenStorage.saveAccessToken('   '), throwsArgumentError);

      expect(await tokenStorage.hasAccessToken(), isFalse);
    });
  });
}

/// تخزين وهمي داخل الذاكرة لاستخدامه في الاختبارات.
///
/// الهدف هو اختبار AuthTokenStorageImpl نفسه دون الاعتماد
/// على Platform Channels الخاصة بـ flutter_secure_storage.
final class FakeSecureKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
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
