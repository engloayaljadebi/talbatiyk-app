/*
|--------------------------------------------------------------------------
| Auth Mapper
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - تحويل UserResource المولد من OpenAPI إلى AuthUserEntity.
| - تحويل UserResourceContactsInner إلى AuthContactEntity.
| - تحويل AuthRegister201ResponseData إلى AuthSessionEntity.
| - تحويل تواريخ API النصية إلى DateTime.
|
| الهدف:
| منع تسريب أنواع OpenAPI المولدة إلى Domain أو Presentation.
|
*/

import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

/// تحويل وسيلة التواصل المولدة من OpenAPI إلى Domain Entity.
extension UserResourceContactsInnerAuthMapper on UserResourceContactsInner {
  AuthContactEntity toDomain() {
    return AuthContactEntity(
      id: id,
      type: type,
      value: value,
      isPrimary: isPrimary,
      verifiedAt: _parseNullableDateTime(verifiedAt),
    );
  }
}

/// تحويل المستخدم المولد من OpenAPI إلى Domain Entity.
extension UserResourceAuthMapper on UserResource {
  AuthUserEntity toDomain() {
    final apiContacts = contacts;

    return AuthUserEntity(
      id: id,
      username: username,
      displayName: displayName,
      status: status,
      lastLoginAt: _parseNullableDateTime(lastLoginAt),
      contacts: apiContacts == null
          ? const <AuthContactEntity>[]
          : apiContacts
                .cast<UserResourceContactsInner>()
                .map((contact) => contact.toDomain())
                .toList(growable: false),
    );
  }
}

/// تحويل استجابة جلسة تسجيل الدخول إلى Domain Entity.
///
/// لا ننقل Access Token إلى Domain؛
/// Repository سيحفظه مباشرة داخل Secure Storage.
extension AuthRegister201ResponseDataAuthMapper on AuthRegister201ResponseData {
  AuthSessionEntity toDomain() {
    return AuthSessionEntity(user: user.toDomain());
  }
}

/// يحول تاريخ ISO-8601 القادم من Laravel إلى DateTime.
///
/// null يبقى null.
/// أما التاريخ غير الصالح فيؤدي إلى FormatException حتى نكتشف
/// أي مخالفة في عقد API بدل إخفائها داخل التطبيق.
DateTime? _parseNullableDateTime(String? value) {
  if (value == null) {
    return null;
  }

  return DateTime.parse(value);
}
