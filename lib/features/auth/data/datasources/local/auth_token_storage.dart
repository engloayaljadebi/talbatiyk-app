/*
|--------------------------------------------------------------------------
| Auth Token Storage
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - تعريف عقد تخزين Access Token.
| - عزل flutter_secure_storage عن بقية طبقة Auth.
| - حفظ Sanctum Token بشكل آمن.
| - قراءة التوكن عند تشغيل التطبيق.
| - حذف التوكن عند تسجيل الخروج.
| - معرفة ما إذا كان هناك Token محفوظ.
|
| الهدف:
| بقية التطبيق لا تعتمد مباشرة على flutter_secure_storage.
|
*/

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// واجهة عامة لتخزين القيم الحساسة.
///
/// وجود هذه الطبقة يمنع ربط Auth مباشرة بحزمة خارجية،
/// ويسهل استبدال طريقة التخزين أو اختبارها مستقبلًا.
abstract interface class SecureKeyValueStore {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

  Future<void> delete({required String key});

  Future<bool> containsKey({required String key});
}

/// تنفيذ التخزين الآمن باستخدام flutter_secure_storage.
final class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  FlutterSecureKeyValueStore({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }

  @override
  Future<bool> containsKey({required String key}) {
    return _storage.containsKey(key: key);
  }
}

/// العقد المسؤول عن Access Token الخاص بالمصادقة.
abstract interface class AuthTokenStorage {
  /// يحفظ Sanctum Access Token.
  Future<void> saveAccessToken(String token);

  /// يعيد التوكن المحفوظ أو null إذا لم توجد جلسة.
  Future<String?> readAccessToken();

  /// يحذف Access Token.
  Future<void> deleteAccessToken();

  /// يتحقق من وجود Access Token محفوظ.
  Future<bool> hasAccessToken();
}

/// تنفيذ تخزين Token باستخدام SecureKeyValueStore.
final class AuthTokenStorageImpl implements AuthTokenStorage {
  AuthTokenStorageImpl(this._storage);

  final SecureKeyValueStore _storage;

  /// اسم المفتاح داخل Secure Storage.
  ///
  /// نستخدم اسمًا ثابتًا ومحددًا للتطبيق حتى لا يتعارض
  /// مع مفاتيح أخرى مستقبلًا.
  static const String _accessTokenKey = 'talbatiyk.auth.access_token';

  @override
  Future<void> saveAccessToken(String token) async {
    final normalizedToken = token.trim();

    if (normalizedToken.isEmpty) {
      throw ArgumentError.value(
        token,
        'token',
        'لا يمكن حفظ Access Token فارغ.',
      );
    }

    await _storage.write(key: _accessTokenKey, value: normalizedToken);
  }

  @override
  Future<String?> readAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return token;
  }

  @override
  Future<void> deleteAccessToken() {
    return _storage.delete(key: _accessTokenKey);
  }

  @override
  Future<bool> hasAccessToken() {
    return _storage.containsKey(key: _accessTokenKey);
  }
}
