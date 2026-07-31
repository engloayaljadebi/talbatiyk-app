class AuthGuard {
  static bool isLoggedIn = false;

  static bool canAccess() {
    return isLoggedIn;
  }
}
