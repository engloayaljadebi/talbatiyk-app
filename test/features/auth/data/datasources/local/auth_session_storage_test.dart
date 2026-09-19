/*
|--------------------------------------------------------------------------
| Verified Auth Session Storage Tests
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - اختبار حفظ Verified Session.
| - اختبار استعادة Session محفوظة.
| - اختبار عدم وجود Session.
| - اختبار حذف Session.
| - اختبار التعامل مع JSON تالف.
| - اختبار رفض Cache Version غير مدعوم.
|
| الهدف:
| التأكد أن VerifiedAuthSessionStorageImpl يستطيع حفظ واستعادة
| آخر Session موثقة من Laravel بشكل صحيح وآمن.
|
| ملاحظة:
| نستخدم FakeSecureKeyValueStore بدل Secure Storage الحقيقي
| حتى تكون الاختبارات سريعة ومعزولة ولا تعتمد على الجهاز.
|
*/

import 'package:flutter_test/flutter_test.dart';

import 'package:talbatiyk/features/auth/data/datasources/local/auth_session_storage.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_token_storage.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';

void main() {
  /*
   * نجمع جميع اختبارات VerifiedAuthSessionStorageImpl
   * داخل group واحد حتى تظهر النتائج بشكل منظم
   * عند تشغيل flutter test.
   */
  group('VerifiedAuthSessionStorageImpl', () {
    /*
     * Fake Secure Store يمثل التخزين الآمن أثناء الاختبار.
     *
     * بدل الكتابة فعليًا في flutter_secure_storage،
     * نخزن القيم داخل Map في الذاكرة فقط.
     */
    late FakeSecureKeyValueStore secureStore;

    /*
     * الكلاس الحقيقي الذي نريد اختباره.
     */
    late VerifiedAuthSessionStorageImpl sessionStorage;

    /*
     * setUp تعمل قبل كل test.
     *
     * ننشئ Storage جديدًا لكل اختبار حتى لا تؤثر
     * بيانات اختبار سابق على الاختبار التالي.
     */
    setUp(() {
      secureStore = FakeSecureKeyValueStore();

      /*
       * نمرر Fake Store إلى التنفيذ الحقيقي.
       *
       * بهذه الطريقة نحن نختبر منطق
       * VerifiedAuthSessionStorageImpl نفسه،
       * بدون الاعتماد على Secure Storage الحقيقي.
       */
      sessionStorage = VerifiedAuthSessionStorageImpl(secureStore);
    });

    test('saves and restores verified session', () async {
      /*
       * ننشئ Session كاملة ببيانات ثابتة
       * لاستخدامها كقيمة اختبار.
       */
      final AuthSessionEntity session = _createSession();

      /*
       * نحفظ Session في Storage.
       *
       * التنفيذ الحقيقي يفترض أن يقوم بتحويل
       * Domain Entity إلى JSON ثم تخزينها.
       */
      await sessionStorage.saveVerifiedSession(session);

      /*
       * نقرأ Session مرة أخرى.
       *
       * الهدف هو التأكد أن:
       *
       * Domain Entity
       *      ↓
       * JSON
       *      ↓
       * Secure Store
       *      ↓
       * JSON Decode
       *      ↓
       * AuthSessionEntity
       *
       * تعمل بدون فقدان البيانات.
       */
      final AuthSessionEntity? restored = await sessionStorage
          .readVerifiedSession();

      /*
       * يجب أن نحصل على Session فعلية،
       * وليس null.
       */
      expect(restored, isNotNull);

      /*
       * نتأكد أن User ID بقي كما هو
       * بعد Serialization / Deserialization.
       */
      expect(restored!.user.id, session.user.id);

      /*
       * التحقق من username.
       */
      expect(restored.user.username, session.user.username);

      /*
       * التحقق من displayName.
       */
      expect(restored.user.displayName, session.user.displayName);

      /*
       * التحقق من حالة المستخدم.
       */
      expect(restored.user.status, session.user.status);

      /*
       * نتأكد أن DateTime تم حفظه واستعادته
       * بنفس القيمة.
       */
      expect(restored.user.lastLoginAt, session.user.lastLoginAt);

      /*
       * المستخدم التجريبي لديه Contact واحد فقط.
       */
      expect(restored.user.contacts, hasLength(1));

      /*
       * نتأكد أن قيمة Contact محفوظة بشكل صحيح.
       */
      expect(restored.user.contacts.single.value, 'test@example.com');

      /*
       * نتأكد كذلك من أن verifiedAt
       * تم تحويله من وإلى JSON بدون فقدان القيمة.
       */
      expect(
        restored.user.contacts.single.verifiedAt,
        DateTime.utc(2026, 8, 1),
      );
    });

    test('returns null when no verified session exists', () async {
      /*
       * لم نحفظ أي Session قبل القراءة.
       *
       * لذلك يجب أن يعيد Storage:
       *
       * null
       *
       * ولا يجب أن يرمي Exception.
       */
      expect(await sessionStorage.readVerifiedSession(), isNull);
    });

    test('deletes verified session', () async {
      /*
       * نحفظ Session أولًا حتى يكون لدينا
       * شيء يمكن حذفه.
       */
      await sessionStorage.saveVerifiedSession(_createSession());

      /*
       * نحذف Verified Session.
       */
      await sessionStorage.deleteVerifiedSession();

      /*
       * بعد الحذف يجب ألا توجد Session
       * قابلة للاستعادة.
       */
      expect(await sessionStorage.readVerifiedSession(), isNull);
    });

    test('rejects and removes corrupted cache', () async {
      /*
       * هنا لا نستخدم saveVerifiedSession عمدًا.
       *
       * نكتب مباشرة داخل Fake Secure Store
       * قيمة JSON تالفة.
       *
       * هذا يحاكي حالات مثل:
       *
       * - تلف البيانات المحلية.
       * - كتابة غير مكتملة.
       * - Cache قديمة أو غير صالحة.
       */
      await secureStore.write(
        key: 'talbatiyk.auth.verified_session',
        value: '{invalid-json',
      );

      /*
       * عند محاولة قراءة JSON التالف،
       * نتوقع FormatException.
       *
       * هذا يثبت أن Storage لا يعامل
       * البيانات التالفة كأنها Session صحيحة.
       */
      await expectLater(
        sessionStorage.readVerifiedSession(),
        throwsA(isA<FormatException>()),
      );

      /*
       * بعد اكتشاف Cache التالفة،
       * يجب أن يقوم Storage بحذفها.
       *
       * لذلك القراءة الثانية يجب أن تعيد null
       * بدل إعادة نفس الخطأ مرة أخرى.
       */
      expect(await sessionStorage.readVerifiedSession(), isNull);
    });

    test('rejects unsupported cache version', () async {
      /*
       * نخزن JSON صحيح من ناحية Syntax،
       * لكنه يحتوي على Version غير مدعوم.
       *
       * version = 999
       *
       * هذا يحاكي حالة وجود Cache مكتوبة
       * بواسطة Schema مختلف أو إصدار غير معروف.
       */
      await secureStore.write(
        key: 'talbatiyk.auth.verified_session',
        value: '{"version":999,"user":{}}',
      );

      /*
       * يجب أن يرفض Storage هذه البيانات
       * لأنها لا تتوافق مع Cache Schema
       * الذي يعرف التطبيق كيفية قراءته.
       */
      await expectLater(
        sessionStorage.readVerifiedSession(),
        throwsA(isA<FormatException>()),
      );

      /*
       * البيانات غير المدعومة يجب حذفها
       * بعد اكتشافها.
       *
       * لذلك القراءة التالية تعيد null.
       */
      expect(await sessionStorage.readVerifiedSession(), isNull);
    });
  });
}

/*
|--------------------------------------------------------------------------
| Test Fixture
|--------------------------------------------------------------------------
|
| هذه الدالة تنشئ AuthSessionEntity ثابتة للاختبارات.
|
| بدل تكرار نفس بيانات المستخدم في كل test،
| نضعها في Helper واحد.
|
*/
AuthSessionEntity _createSession() {
  return AuthSessionEntity(
    user: AuthUserEntity(
      /*
       * معرف المستخدم التجريبي.
       */
      id: 'user-1',

      /*
       * اسم المستخدم.
       */
      username: 'test_user',

      /*
       * الاسم المعروض للمستخدم.
       */
      displayName: 'Test User',

      /*
       * حالة الحساب.
       */
      status: 'active',

      /*
       * نستخدم DateTime.utc حتى تكون نتيجة الاختبار
       * ثابتة ولا تتأثر بالـ Time Zone المحلي للجهاز.
       */
      lastLoginAt: DateTime.utc(2026, 8, 11),

      /*
       * نضيف Contact واحدًا لاختبار أن
       * Nested Entities يتم حفظها واستعادتها أيضًا.
       */
      contacts: <AuthContactEntity>[
        AuthContactEntity(
          id: 'contact-1',
          type: 'email',
          value: 'test@example.com',
          isPrimary: true,

          /*
           * تاريخ توثيق البريد الإلكتروني.
           *
           * نختبره لاحقًا للتأكد من أن DateTime
           * داخل Contact يتم Serialize/Deserialize
           * بصورة صحيحة.
           */
          verifiedAt: DateTime.utc(2026, 8, 1),
        ),
      ],
    ),
  );
}

/*
|--------------------------------------------------------------------------
| Fake Secure Key Value Store
|--------------------------------------------------------------------------
|
| Fake implementation لعقد SecureKeyValueStore.
|
| الهدف:
| عدم استخدام flutter_secure_storage الحقيقي
| داخل Unit Tests.
|
| التخزين هنا يتم داخل Map في الذاكرة:
|
| key -> value
|
| وكل Test يحصل على instance جديدة من هذا الكلاس
| عن طريق setUp().
|
*/
final class FakeSecureKeyValueStore implements SecureKeyValueStore {
  /*
   * تمثل التخزين المحلي المؤقت أثناء الاختبار.
   */
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    /*
     * محاكاة كتابة قيمة داخل Secure Storage.
     */
    _values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    /*
     * إذا كان المفتاح موجودًا نعيد قيمته.
     *
     * إذا لم يكن موجودًا فإن Map تعيد null،
     * وهو نفس السلوك المطلوب من Storage abstraction.
     */
    return _values[key];
  }

  @override
  Future<void> delete({required String key}) async {
    /*
     * محاكاة حذف قيمة من Secure Storage.
     *
     * remove آمنة حتى إذا لم يكن المفتاح موجودًا.
     */
    _values.remove(key);
  }

  @override
  Future<bool> containsKey({required String key}) async {
    /*
     * التحقق هل يوجد المفتاح في التخزين.
     */
    return _values.containsKey(key);
  }
}
