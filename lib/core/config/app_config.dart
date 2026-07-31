import 'flavors.dart';

class AppConfig {
  static late FlavorConfig flavor;

  static void initialize(FlavorConfig config) {
    flavor = config;
  }

  static String get appName => flavor.appName;

  static String get apiUrl => flavor.apiUrl;
}
