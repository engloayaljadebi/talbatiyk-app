import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for BusinessContactApi
void main() {
  final instance = TalbatiykApi().getBusinessContactApi();

  group(BusinessContactApi, () {
    // حذف وسيلة اتصال عامة
    //
    //Future businessContactDestroyBusiness(String business, String contact) async
    test('test businessContactDestroyBusiness', () async {
      // TODO
    });

    // حذف وسيلة اتصال خاصة بفرع
    //
    //Future businessContactDestroyLocation(String business, String location, String contact) async
    test('test businessContactDestroyLocation', () async {
      // TODO
    });

    // عرض وسائل الاتصال العامة للنشاط
    //
    //Future<BusinessContactIndexBusiness200Response> businessContactIndexBusiness(String business) async
    test('test businessContactIndexBusiness', () async {
      // TODO
    });

    // عرض وسائل الاتصال الخاصة بفرع
    //
    //Future<BusinessContactIndexBusiness200Response> businessContactIndexLocation(String business, String location) async
    test('test businessContactIndexLocation', () async {
      // TODO
    });

    // تعيين وسيلة اتصال عامة كوسيلة رئيسية من نوعها
    //
    //Future<BusinessContactStoreBusiness201Response> businessContactSetPrimaryBusiness(String business, String contact) async
    test('test businessContactSetPrimaryBusiness', () async {
      // TODO
    });

    // تعيين وسيلة اتصال فرع كوسيلة رئيسية من نوعها
    //
    //Future<BusinessContactStoreBusiness201Response> businessContactSetPrimaryLocation(String business, String location, String contact) async
    test('test businessContactSetPrimaryLocation', () async {
      // TODO
    });

    // عرض وسيلة اتصال عامة واحدة
    //
    //Future<BusinessContactStoreBusiness201Response> businessContactShowBusiness(String business, String contact) async
    test('test businessContactShowBusiness', () async {
      // TODO
    });

    // عرض وسيلة اتصال خاصة بفرع
    //
    //Future<BusinessContactStoreBusiness201Response> businessContactShowLocation(String business, String location, String contact) async
    test('test businessContactShowLocation', () async {
      // TODO
    });

    // إنشاء وسيلة اتصال عامة
    //
    //Future<BusinessContactStoreBusiness201Response> businessContactStoreBusiness(String business, CreateBusinessContactRequest createBusinessContactRequest) async
    test('test businessContactStoreBusiness', () async {
      // TODO
    });

    // إنشاء وسيلة اتصال خاصة بفرع
    //
    //Future<BusinessContactStoreBusiness201Response> businessContactStoreLocation(String business, String location, CreateBusinessContactRequest createBusinessContactRequest) async
    test('test businessContactStoreLocation', () async {
      // TODO
    });

    // تعديل وسيلة اتصال عامة
    //
    //Future<BusinessContactStoreBusiness201Response> businessContactUpdateBusiness(String business, String contact, { UpdateBusinessContactRequest updateBusinessContactRequest }) async
    test('test businessContactUpdateBusiness', () async {
      // TODO
    });

    // تعديل وسيلة اتصال خاصة بفرع
    //
    //Future<BusinessContactStoreBusiness201Response> businessContactUpdateLocation(String business, String location, String contact, { UpdateBusinessContactRequest updateBusinessContactRequest }) async
    test('test businessContactUpdateLocation', () async {
      // TODO
    });

  });
}
