import 'generators/feature_generator.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print("❌ اكتب اسم Feature");

    return;
  }

  final feature = args[0];

  String state = "default";

  if (args.contains("--riverpod")) {
    state = "riverpod";
  }

  if (args.contains("--bloc")) {
    state = "bloc";
  }

  FeatureGenerator.createFeature(feature, state);

  print("");
  print("==============================");
  print("✅ Feature Created: $feature");
  print("State Management: $state");
  print("==============================");
}
