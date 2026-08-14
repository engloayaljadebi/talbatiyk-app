import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for AuthApi
void main() {
  final instance = TalbatiykApi().getAuthApi();

  group(AuthApi, () {
    // تسجيل الدخول
    //
    //Future<AuthRegister201Response> authLogin(LoginRequest loginRequest) async
    test('test authLogin', () async {
      // TODO
    });

    // تسجيل خروج الجهاز الحالي فقط
    //
    //Future<AuthLogout200Response> authLogout() async
    test('test authLogout', () async {
      // TODO
    });

    // بيانات المستخدم الحالي
    //
    //Future<AuthMe200Response> authMe() async
    test('test authMe', () async {
      // TODO
    });

    // إنشاء حساب جديد
    //
    //Future<AuthRegister201Response> authRegister(RegisterRequest registerRequest) async
    test('test authRegister', () async {
      // TODO
    });

  });
}
