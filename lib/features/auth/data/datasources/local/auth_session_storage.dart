import 'dart:convert';

import '../../../domain/entities/auth_entity.dart';
import 'auth_token_storage.dart';

/// يخزن آخر جلسة مستخدم تم التحقق منها فعليًا من الخادم.
///
/// لا يحتوي هذا التخزين على Access Token.
/// التوكن يبقى مسؤولية AuthTokenStorage وحده.
abstract interface class VerifiedAuthSessionStorage {
  Future<void> saveVerifiedSession(AuthSessionEntity session);

  Future<AuthSessionEntity?> readVerifiedSession();

  Future<void> deleteVerifiedSession();
}

final class VerifiedAuthSessionStorageImpl
    implements VerifiedAuthSessionStorage {
  VerifiedAuthSessionStorageImpl(this._storage);

  final SecureKeyValueStore _storage;

  static const String _verifiedSessionKey = 'talbatiyk.auth.verified_session';

  static const int _schemaVersion = 1;

  @override
  Future<void> saveVerifiedSession(AuthSessionEntity session) async {
    final String encoded = jsonEncode(<String, Object?>{
      'version': _schemaVersion,
      'user': _encodeUser(session.user),
    });

    await _storage.write(key: _verifiedSessionKey, value: encoded);
  }

  @override
  Future<AuthSessionEntity?> readVerifiedSession() async {
    final String? raw = await _storage.read(key: _verifiedSessionKey);

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final Object? decoded = jsonDecode(raw);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid verified auth session payload.');
      }

      if (decoded['version'] != _schemaVersion) {
        throw const FormatException(
          'Unsupported verified auth session version.',
        );
      }

      final Object? rawUser = decoded['user'];

      if (rawUser is! Map<String, dynamic>) {
        throw const FormatException('Verified auth session has no valid user.');
      }

      return AuthSessionEntity(user: _decodeUser(rawUser));
    } catch (error, stackTrace) {
      // Corrupted cache must never authenticate a user.
      try {
        await deleteVerifiedSession();
      } catch (_) {
        // Preserve the original corruption error.
      }

      if (error is FormatException) {
        Error.throwWithStackTrace(error, stackTrace);
      }

      Error.throwWithStackTrace(
        const FormatException('Invalid verified auth session cache.'),
        stackTrace,
      );
    }
  }

  @override
  Future<void> deleteVerifiedSession() {
    return _storage.delete(key: _verifiedSessionKey);
  }

  Map<String, Object?> _encodeUser(AuthUserEntity user) {
    return <String, Object?>{
      'id': user.id,
      'username': user.username,
      'displayName': user.displayName,
      'status': user.status,
      'lastLoginAt': user.lastLoginAt?.toUtc().toIso8601String(),
      'contacts': user.contacts
          .map(
            (AuthContactEntity contact) => <String, Object?>{
              'id': contact.id,
              'type': contact.type,
              'value': contact.value,
              'isPrimary': contact.isPrimary,
              'verifiedAt': contact.verifiedAt?.toUtc().toIso8601String(),
            },
          )
          .toList(growable: false),
    };
  }

  AuthUserEntity _decodeUser(Map<String, dynamic> json) {
    final Object? rawContacts = json['contacts'];

    if (rawContacts is! List) {
      throw const FormatException('Verified auth user has invalid contacts.');
    }

    return AuthUserEntity(
      id: _requiredString(json, 'id'),
      username: _requiredString(json, 'username'),
      displayName: _requiredString(json, 'displayName'),
      status: _requiredString(json, 'status'),
      lastLoginAt: _nullableDateTime(json['lastLoginAt']),
      contacts: rawContacts
          .map((Object? rawContact) {
            if (rawContact is! Map<String, dynamic>) {
              throw const FormatException('Invalid verified auth contact.');
            }

            final Object? rawIsPrimary = rawContact['isPrimary'];

            if (rawIsPrimary is! bool) {
              throw const FormatException(
                'Verified auth contact has invalid isPrimary.',
              );
            }

            return AuthContactEntity(
              id: _requiredString(rawContact, 'id'),
              type: _requiredString(rawContact, 'type'),
              value: _requiredString(rawContact, 'value'),
              isPrimary: rawIsPrimary,
              verifiedAt: _nullableDateTime(rawContact['verifiedAt']),
            );
          })
          .toList(growable: false),
    );
  }

  String _requiredString(Map<String, dynamic> json, String key) {
    final Object? value = json[key];

    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Verified auth session has invalid $key.');
    }

    return value;
  }

  DateTime? _nullableDateTime(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Verified auth session has invalid date.');
    }

    return DateTime.parse(value).toUtc();
  }
}
