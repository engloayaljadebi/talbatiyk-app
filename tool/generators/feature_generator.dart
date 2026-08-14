// ignore_for_file: avoid_print

import 'dart:io';

import 'file_generator.dart';
import 'template_generator.dart';

class FeatureGenerator {
  static void createFeature(String name, String stateManagement) {
    final feature = name.toLowerCase();

    // ===============================
    // Folders
    // ===============================

    final folders = [
      // DATA
      "lib/features/$feature/data/datasources/local",
      "lib/features/$feature/data/datasources/remote",
      "lib/features/$feature/data/models",
      "lib/features/$feature/data/dto",
      "lib/features/$feature/data/mappers",
      "lib/features/$feature/data/repositories",

      // DOMAIN
      "lib/features/$feature/domain/entities",
      "lib/features/$feature/domain/repositories",
      "lib/features/$feature/domain/usecases",
      "lib/features/$feature/domain/services",

      // PRESENTATION
      "lib/features/$feature/presentation/pages",
      "lib/features/$feature/presentation/widgets",
      "lib/features/$feature/presentation/dialogs",
      "lib/features/$feature/presentation/controllers",
      "lib/features/$feature/presentation/state",
      "lib/features/$feature/presentation/viewmodels",
      "lib/features/$feature/presentation/bindings",
    ];

    // State Management

    if (stateManagement == "riverpod") {
      folders.add("lib/features/$feature/presentation/providers");
    }

    if (stateManagement == "bloc") {
      folders.add("lib/features/$feature/presentation/bloc");
    }

    // إنشاء المجلدات

    for (final folder in folders) {
      Directory(folder).createSync(recursive: true);
    }

    // ===============================
    // DATA FILES
    // ===============================

    FileGenerator.createFile(
      "lib/features/$feature/data/models/${feature}_model.dart",
      TemplateGenerator.model(capitalize(feature)),
    );

    FileGenerator.createFile(
      "lib/features/$feature/data/dto/${feature}_dto.dart",
      TemplateGenerator.dto(capitalize(feature)),
    );

    FileGenerator.createFile(
      "lib/features/$feature/data/mappers/${feature}_mapper.dart",
      TemplateGenerator.mapper(capitalize(feature)),
    );

    FileGenerator.createFile(
      "lib/features/$feature/data/datasources/local/${feature}_local_datasource.dart",
      TemplateGenerator.datasource(capitalize(feature), "Local"),
    );

    FileGenerator.createFile(
      "lib/features/$feature/data/datasources/remote/${feature}_remote_datasource.dart",
      TemplateGenerator.datasource(capitalize(feature), "Remote"),
    );

    FileGenerator.createFile(
      "lib/features/$feature/data/repositories/${feature}_repository_impl.dart",
      TemplateGenerator.repositoryImpl(capitalize(feature)),
    );

    // ===============================
    // DOMAIN FILES
    // ===============================

    FileGenerator.createFile(
      "lib/features/$feature/domain/entities/${feature}_entity.dart",
      TemplateGenerator.entity(capitalize(feature)),
    );

    FileGenerator.createFile(
      "lib/features/$feature/domain/repositories/${feature}_repository.dart",
      TemplateGenerator.repository(capitalize(feature)),
    );

    FileGenerator.createFile(
      "lib/features/$feature/domain/usecases/${feature}_usecase.dart",
      TemplateGenerator.usecase(capitalize(feature)),
    );

    FileGenerator.createFile(
      "lib/features/$feature/domain/services/${feature}_service.dart",
      TemplateGenerator.service(capitalize(feature)),
    );

    // ===============================
    // PRESENTATION
    // ===============================

    FileGenerator.createFile(
      "lib/features/$feature/presentation/pages/${feature}_page.dart",
      TemplateGenerator.page(capitalize(feature)),
    );

    FileGenerator.createFile(
      "lib/features/$feature/presentation/widgets/${feature}_widget.dart",
      TemplateGenerator.widget(capitalize(feature)),
    );

    FileGenerator.createFile(
      "lib/features/$feature/presentation/controllers/${feature}_controller.dart",
      TemplateGenerator.controller(capitalize(feature)),
    );

    FileGenerator.createFile(
      "lib/features/$feature/presentation/state/${feature}_state.dart",
      TemplateGenerator.state(capitalize(feature)),
    );

    FileGenerator.createFile(
      "lib/features/$feature/presentation/viewmodels/${feature}_viewmodel.dart",
      TemplateGenerator.viewmodel(capitalize(feature)),
    );

    FileGenerator.createFile(
      "lib/features/$feature/presentation/bindings/${feature}_binding.dart",
      TemplateGenerator.binding(capitalize(feature)),
    );

    // Riverpod

    if (stateManagement == "riverpod") {
      FileGenerator.createFile(
        "lib/features/$feature/presentation/providers/${feature}_provider.dart",
        TemplateGenerator.provider(capitalize(feature)),
      );
    }

    // Bloc

    if (stateManagement == "bloc") {
      FileGenerator.createFile(
        "lib/features/$feature/presentation/bloc/${feature}_bloc.dart",
        TemplateGenerator.bloc(capitalize(feature)),
      );
    }

    print("✔ $feature generated successfully");
  }

  static String capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
}
