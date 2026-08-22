import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for SupplierFollowApi
void main() {
  final instance = TalbatiykApi().getSupplierFollowApi();

  group(SupplierFollowApi, () {
    // إلغاء متابعة المورد
    //
    // العملية idempotent؛ إلغاء متابعة غير موجودة لا يعتبر خطأ.
    //
    //Future<SupplierFollowShow200Response> supplierFollowDestroy(String business) async
    test('test supplierFollowDestroy', () async {
      // TODO
    });

    // حالة متابعة المستخدم الحالي للمورد
    //
    //Future<SupplierFollowShow200Response> supplierFollowShow(String business) async
    test('test supplierFollowShow', () async {
      // TODO
    });

    // متابعة المورد
    //
    // العملية idempotent؛ تكرار الطلب لا ينشئ علاقة ثانية.
    //
    //Future<SupplierFollowShow200Response> supplierFollowStore(String business) async
    test('test supplierFollowStore', () async {
      // TODO
    });

  });
}
