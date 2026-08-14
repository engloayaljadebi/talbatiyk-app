/*
|--------------------------------------------------------------------------
| Auth Controller
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - إدارة حالة المصادقة داخل واجهة التطبيق.
| - استعادة الجلسة عند تشغيل التطبيق.
| - تنفيذ تسجيل الدخول.
| - تنفيذ تسجيل الخروج.
| - تحويل نجاح أو فشل العمليات إلى AuthState مناسب للواجهة.
|
| قواعد التصميم:
| - Controller لا يعرف Dio أو Laravel أو Secure Storage.
| - يتعامل فقط مع AuthUseCase.
| - Access Token لا يصل إلى Presentation.
|
*/

import 'package:flutter/foundation.dart';

import '../../domain/usecases/auth_usecase.dart';
import '../states/auth_state.dart';

/// يدير حالة المصادقة التي تعتمد عليها واجهة التطبيق.
final class AuthController extends ChangeNotifier {
  AuthController(this._useCase, {bool autoRestore = true}) {
    if (autoRestore) {
      restoreSession();
    }
  }

  final AuthUseCase _useCase;

  /// الحالة الحالية للمصادقة.
  AuthState state = const AuthState();

  /// يحاول استعادة الجلسة المحفوظة عند تشغيل التطبيق.
  Future<void> restoreSession() async {
    state = state.copyWith(
      status: AuthStatus.restoring,
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      final session = await _useCase.restoreSession();

      if (session == null) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearSession: true,
          clearErrorMessage: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          clearErrorMessage: true,
        );
      }
    } catch (_) {
      /*
       * لا نحول خطأ استعادة الجلسة مباشرة إلى unauthenticated.
       *
       * قد يكون Access Token ما زال صالحًا، لكن الجهاز بلا إنترنت.
       * لذلك نحافظ على حالة failure حتى تستطيع الواجهة عرض إعادة المحاولة.
       */
      state = state.copyWith(
        status: AuthStatus.failure,
        clearSession: true,
        errorMessage: 'تعذر التحقق من جلسة المستخدم. حاول مرة أخرى.',
      );
    }

    notifyListeners();
  }

  /// يسجل دخول المستخدم.
  Future<bool> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      clearSession: true,
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      final session = await _useCase.login(
        login: login,
        password: password,
        deviceName: deviceName,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        clearErrorMessage: true,
      );

      notifyListeners();

      return true;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.failure,
        clearSession: true,
        errorMessage: 'تعذر تسجيل الدخول. تحقق من البيانات وحاول مرة أخرى.',
      );

      notifyListeners();

      return false;
    }
  }

  /// يسجل خروج المستخدم من الجهاز الحالي.
  Future<void> logout() async {
    state = state.copyWith(
      status: AuthStatus.signingOut,
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      await _useCase.logout();

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearSession: true,
        clearErrorMessage: true,
      );
    } catch (_) {
      /*
       * Repository يحذف الجلسة المحلية حتى لو فشل الاتصال بالخادم.
       * لذلك المستخدم يعتبر مسجل الخروج من هذا الجهاز.
       */
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearSession: true,
        errorMessage:
            'تم تسجيل الخروج من الجهاز، لكن تعذر إنهاء الجلسة على الخادم.',
      );
    }

    notifyListeners();
  }

  /// يعيد محاولة التحقق من الجلسة الحالية.
  Future<void> retryRestoreSession() {
    return restoreSession();
  }
}
