import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for BusinessLocationApi
void main() {
  final instance = TalbatiykApi().getBusinessLocationApi();

  group(BusinessLocationApi, () {
    // حذف موقع حذفًا منطقيًا
    //
    // الموقع الرئيسي لا يمكن حذفه قبل تعيين موقع رئيسي آخر.
    //
    //Future businessLocationDestroy(String business, String location) async
    test('test businessLocationDestroy', () async {
      // TODO
    });

    // عرض جميع مواقع النشاط
    //
    // أي عضو active يستطيع القراءة.
    //
    //Future<BusinessLocationIndex200Response> businessLocationIndex(String business) async
    test('test businessLocationIndex', () async {
      // TODO
    });

    // تعيين موقع باعتباره الموقع الرئيسي
    //
    //Future<BusinessLocationStore201Response> businessLocationSetPrimary(String business, String location) async
    test('test businessLocationSetPrimary', () async {
      // TODO
    });

    // عرض موقع واحد تابع للنشاط
    //
    //Future<BusinessLocationStore201Response> businessLocationShow(String business, String location) async
    test('test businessLocationShow', () async {
      // TODO
    });

    // إنشاء موقع جديد
    //
    // owner أو manager فقط.
    //
    //Future<BusinessLocationStore201Response> businessLocationStore(String business, CreateBusinessLocationRequest createBusinessLocationRequest) async
    test('test businessLocationStore', () async {
      // TODO
    });

    // تعديل موقع موجود
    //
    // owner أو manager فقط.
    //
    //Future<BusinessLocationStore201Response> businessLocationUpdate(String business, String location, { UpdateBusinessLocationRequest updateBusinessLocationRequest }) async
    test('test businessLocationUpdate', () async {
      // TODO
    });

  });
}
