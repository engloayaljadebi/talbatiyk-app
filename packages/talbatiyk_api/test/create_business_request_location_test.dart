import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

// tests for CreateBusinessRequestLocation
void main() {
  final instance = CreateBusinessRequestLocationBuilder();
  // TODO add properties to the builder and call build()

  group(CreateBusinessRequestLocation, () {
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // String type
    test('to test the property `type`', () async {
      // TODO
    });

    // Laravel يتحقق أن القيمة اسم Timezone صالح. مثال: Asia/Aden
    // String timezone
    test('to test the property `timezone`', () async {
      // TODO
    });

    // ISO 3166-1 alpha-2 اليمن: YE
    // String countryCode
    test('to test the property `countryCode`', () async {
      // TODO
    });

    // String administrativeArea
    test('to test the property `administrativeArea`', () async {
      // TODO
    });

    // String locality
    test('to test the property `locality`', () async {
      // TODO
    });

    // String district
    test('to test the property `district`', () async {
      // TODO
    });

    // String streetAddress
    test('to test the property `streetAddress`', () async {
      // TODO
    });

    // String addressNotes
    test('to test the property `addressNotes`', () async {
      // TODO
    });

    // إذا تم إرسال أحد الإحداثيين يجب إرسال الآخر أيضًا. PostgreSQL لديه كذلك CHECK constraints، لكننا نرفض الخطأ مبكرًا من طبقة API.
    // num latitude
    test('to test the property `latitude`', () async {
      // TODO
    });

    // num longitude
    test('to test the property `longitude`', () async {
      // TODO
    });

  });
}
