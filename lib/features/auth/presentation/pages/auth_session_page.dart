/*
|--------------------------------------------------------------------------
| Auth Session Page
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - عرض حالة فحص الجلسة عند تشغيل التطبيق.
| - عرض مؤشر تحميل أثناء restoreSession.
| - عرض خطأ مع زر إعادة المحاولة عند تعذر التحقق من الجلسة.
|
| ملاحظة:
| الانتقال إلى Login أو MainPage يتم من GoRouter وليس من هذه الصفحة.
|
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../states/auth_state.dart';

final class AuthSessionPage extends ConsumerWidget {
  const AuthSessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(authProvider);
    final state = controller.state;

    final hasFailure = state.status == AuthStatus.failure;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: hasFailure
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_outlined, size: 52),
                      const SizedBox(height: 20),
                      Text(
                        state.errorMessage ?? 'تعذر التحقق من جلسة المستخدم.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: state.isBusy
                            ? null
                            : controller.retryRestoreSession,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('جارٍ التحقق من الجلسة...'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
