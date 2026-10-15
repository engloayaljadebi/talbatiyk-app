import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/services/account_session_fence.dart';

/// A fixed, explicit test identity for pre-existing single-account tests.
///
/// Never use in production. Cross-account security tests must use
/// independently controlled identities instead of this helper.
const String legacyOrderTestUserId = 'legacy-test-account';

AccountSessionFence createLegacyOrderTestFence() {
  final session = AuthSessionEntity(
    user: AuthUserEntity(
      id: legacyOrderTestUserId,
      username: 'legacy-test-user',
      displayName: 'Legacy Test User',
      status: 'active',
      lastLoginAt: null,
      contacts: const <AuthContactEntity>[],
    ),
  );

  return AccountSessionFence(() => session);
}
