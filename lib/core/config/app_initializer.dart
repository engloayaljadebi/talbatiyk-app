import '../di/injection_container.dart';

class AppInitializer {
  static Future<void> initialize() async {
    await configureDependencies();
  }
}
