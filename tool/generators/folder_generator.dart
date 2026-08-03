import 'dart:io';

class FolderGenerator {
  static void createCore() {
    final folders = [
      "lib/core/config",
      "lib/core/constants",
      "lib/core/theme",
      "lib/core/network",
      "lib/core/database",
      "lib/core/storage",
      "lib/core/router",
      "lib/core/services",
      "lib/core/utils",
      "lib/core/errors",
      "lib/core/di",

      "lib/shared/widgets",
      "lib/shared/components",
      "lib/shared/models",
      "lib/shared/dialogs",
    ];

    for (var folder in folders) {
      Directory(folder).createSync(recursive: true);
    }

    print("✔ Core Generated");
  }
}
