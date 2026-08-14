import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for BusinessApi
void main() {
  final instance = TalbatiykApi().getBusinessApi();

  group(BusinessApi, () {
    // إرجاع جميع الأنشطة التي لدى المستخدم الحالي عضوية نشطة فيها
    //
    //Future<BusinessIndex200Response> businessIndex() async
    test('test businessIndex', () async {
      // TODO
    });

    // قراءة نشاط واحد بشرط أن تكون للمستخدم الحالي عضوية نشطة فيه
    //
    // عند عدم وجود النشاط أو عدم امتلاك العضوية سيعيد BusinessQueryService استجابة 404.
    //
    //Future<BusinessStore201Response> businessShow(String business) async
    test('test businessShow', () async {
      // TODO
    });

    // إنشاء نشاط تجاري جديد للمستخدم الحالي
    //
    //Future<BusinessStore201Response> businessStore(CreateBusinessRequest createBusinessRequest) async
    test('test businessStore', () async {
      // TODO
    });

    // تعديل البيانات الأساسية لنشاط تجاري
    //
    // يسمح بالتعديل فقط للمستخدم الذي: - لديه عضوية active. - يحمل دور owner أو manager.  BusinessAccessService يتولى التحقق من الصلاحيات.
    //
    //Future<BusinessStore201Response> businessUpdate(String business, { UpdateBusinessRequest updateBusinessRequest }) async
    test('test businessUpdate', () async {
      // TODO
    });

  });
}
