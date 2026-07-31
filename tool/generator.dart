import 'generators/project_generator.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print("""
الاستخدام:

dart run tool/generator.dart all

""");

    return;
  }

  if (args.contains("all")) {
    ProjectGenerator.generate();
  }
}
