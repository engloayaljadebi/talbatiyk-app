import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/config/app_initializer.dart';
import 'core/config/app_config.dart';
import 'core/config/flavors.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer.initialize();

  AppConfig.initialize(
    FlavorConfig.development,
  );

  runApp(
    const TalbytkApp(),
  );
}
