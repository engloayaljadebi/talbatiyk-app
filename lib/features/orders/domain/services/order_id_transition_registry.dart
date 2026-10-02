/// سجل إدارة انتقال معرّفات الطلبيات من المعرّف المؤقت المحلي
/// إلى المعرّف النهائي المعتمد من الخادم (UUID).
///
/// يسمح لواجهات المستخدم (مثل تفاصيل الطلبية) بربط الطلب المحلي
/// بالطلب المعتمد تلقائياً فور اكتمال المزامنة مع الخادم.
final class OrderIdTransitionRegistry {
  OrderIdTransitionRegistry();

  final Map<String, String> _transitions = <String, String>{};

  /// يسجل الانتقال من معرّف محلي مؤقت إلى معرّف الخادم النهائي.
  void registerTransition({
    required String localOrderId,
    required String serverOrderId,
  }) {
    final String trimmedLocal = localOrderId.trim();
    final String trimmedServer = serverOrderId.trim();

    if (trimmedLocal.isEmpty || trimmedServer.isEmpty) {
      return;
    }

    _transitions[trimmedLocal] = trimmedServer;
  }

  /// يرجع المعرّف النهائي للطلبية إذا تم تسجيل انتقال لها،
  /// أو يرجع نفس المعرّف المطلوب إذا لم يوجد انتقال مسجل.
  String resolve(String id) {
    final String trimmed = id.trim();
    if (trimmed.isEmpty) {
      return id;
    }

    return _transitions[trimmed] ?? trimmed;
  }

  /// يمسح جميع التحويلات المسجلة.
  void clear() {
    _transitions.clear();
  }
}
