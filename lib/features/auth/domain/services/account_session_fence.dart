import '../entities/auth_entity.dart';

/// Captures one authenticated session without exposing the access token.
///
/// Callers must verify the lease after asynchronous boundaries and
/// immediately before acting on account-owned data.
final class AccountSessionFence {
  AccountSessionFence(this._readAuthenticatedSession);

  final AuthSessionEntity? Function() _readAuthenticatedSession;

  AccountSessionLease capture() {
    final session = _readAuthenticatedSession();

    if (session == null || session.user.id.trim().isEmpty) {
      throw StateError('An authenticated account is required.');
    }

    return AccountSessionLease._(
      fence: this,
      session: session,
      ownerUserId: session.user.id.trim(),
    );
  }
}

/// Immutable snapshot of one authentication session.
///
/// A different session object invalidates this lease, even if the
/// user signs back into the same account later.
final class AccountSessionLease {
  AccountSessionLease._({
    required AccountSessionFence fence,
    required AuthSessionEntity session,
    required this.ownerUserId,
  }) : _fence = fence,
       _session = session;

  final AccountSessionFence _fence;
  final AuthSessionEntity _session;

  final String ownerUserId;

  bool get isCurrent => identical(_fence._readAuthenticatedSession(), _session);

  void ensureCurrent() {
    if (!isCurrent) {
      throw StateError('Authentication session changed during this operation.');
    }
  }
}
