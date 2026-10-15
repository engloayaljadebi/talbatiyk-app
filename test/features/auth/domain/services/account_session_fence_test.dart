import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/services/account_session_fence.dart';

void main() {
  group('AccountSessionFence', () {
    test('rejects operations without an authenticated session', () {
      final fence = AccountSessionFence(() => null);

      expect(fence.capture, throwsStateError);
    });

    test('rejects a session with an empty account identifier', () {
      final session = _session('   ');
      final fence = AccountSessionFence(() => session);

      expect(fence.capture, throwsStateError);
    });

    test('invalidates account A lease when account B signs in', () {
      AuthSessionEntity? active = _session('account-A');

      final fence = AccountSessionFence(() => active);
      final lease = fence.capture();

      expect(lease.ownerUserId, 'account-A');
      expect(lease.isCurrent, isTrue);

      active = _session('account-B');

      expect(lease.isCurrent, isFalse);
      expect(lease.ensureCurrent, throwsStateError);
    });

    test('invalidates a lease immediately after logout', () {
      AuthSessionEntity? active = _session('account-A');

      final fence = AccountSessionFence(() => active);
      final lease = fence.capture();

      active = null;

      expect(lease.isCurrent, isFalse);
      expect(lease.ensureCurrent, throwsStateError);
    });

    test('old lease remains invalid after A to B to A', () {
      AuthSessionEntity? active = _session('account-A');

      final fence = AccountSessionFence(() => active);
      final oldLease = fence.capture();

      active = _session('account-B');
      active = _session('account-A');

      expect(oldLease.ownerUserId, 'account-A');
      expect(oldLease.isCurrent, isFalse);
      expect(oldLease.ensureCurrent, throwsStateError);

      final newLease = fence.capture();

      expect(newLease.ownerUserId, 'account-A');
      expect(newLease.isCurrent, isTrue);
    });

    test('replacing a session invalidates its old lease', () {
      AuthSessionEntity? active = _session('account-A');

      final fence = AccountSessionFence(() => active);
      final oldLease = fence.capture();

      active = _session('account-A');

      expect(oldLease.isCurrent, isFalse);
      expect(oldLease.ensureCurrent, throwsStateError);
      expect(fence.capture().isCurrent, isTrue);
    });
  });
}

AuthSessionEntity _session(String userId) {
  return AuthSessionEntity(
    user: AuthUserEntity(
      id: userId,
      username: 'test-user',
      displayName: 'Test User',
      status: 'active',
      lastLoginAt: null,
      contacts: const <AuthContactEntity>[],
    ),
  );
}
