import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// يوفر اتصالًا واحدًا بقاعدة البيانات المحلية لجميع أجزاء التطبيق.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  /// يغلق اتصال قاعدة البيانات عند التخلص من الـProvider.
  ref.onDispose(database.close);

  return database;
});
