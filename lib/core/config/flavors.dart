import 'env.dart';

class FlavorConfig {
  final Environment environment;

  final String appName;

  final String apiUrl;

  const FlavorConfig({
    required this.environment,
    required this.appName,
    required this.apiUrl,
  });

  static FlavorConfig development = const FlavorConfig(
    environment: Environment.development,
    appName: "Talbytk Dev",
    apiUrl: "https://dev-api.talbytk.com",
  );

  static FlavorConfig production = const FlavorConfig(
    environment: Environment.production,
    appName: "Talbytk",
    apiUrl: "https://api.talbytk.com",
  );
}
