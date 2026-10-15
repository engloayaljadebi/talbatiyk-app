import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/account_session_fence.dart';
import 'auth_providers.dart';

/// Reads the live authentication state whenever a lease is checked.
///
/// Do not capture a static user ID or a cached AuthSessionEntity here.
/// A signing-out, failed, or replaced session must be rejected.
final accountSessionFenceProvider = Provider<AccountSessionFence>((ref) {
  return AccountSessionFence(() {
    final state = ref.read(authProvider).state;

    if (!state.isAuthenticated) {
      return null;
    }

    return state.session;
  });
});
