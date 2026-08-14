import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

// tests for CreateBusinessRequest
void main() {
  final instance = CreateBusinessRequestBuilder();
  // TODO add properties to the builder and call build()

  group(CreateBusinessRequest, () {
    // ---------------------------------------------------------------- بيانات النشاط الأساسية ----------------------------------------------------------------
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // String legalName
    test('to test the property `legalName`', () async {
      // TODO
    });

    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // ---------------------------------------------------------------- قدرات النشاط ---------------------------------------------------------------- مثال:  capabilities: - supplier - shop  لا نقبل قدرة متوقفة retired_at.
    // BuiltList<String> capabilities
    test('to test the property `capabilities`', () async {
      // TODO
    });

    // CreateBusinessRequestLocation location
    test('to test the property `location`', () async {
      // TODO
    });

    // CreateBusinessRequestContact contact
    test('to test the property `contact`', () async {
      // TODO
    });

  });
}
